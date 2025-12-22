import 'dart:io';
import 'package:master_mind/models/profile_model.dart';
import 'package:master_mind/repository/profileRepo/profile_repo.dart';
import 'package:master_mind/providers/base_provider.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';

class ProfileProvider extends BaseProvider {
  final ProfileRepository _repository;
  ProfileModel? _profile;
  bool _isUploadingProfileImage = false;

  ProfileProvider({required ProfileRepository repository})
      : _repository = repository;

  ProfileModel? get profile => _profile;
  bool get isUploadingProfileImage => _isUploadingProfileImage;

  Future<void> loadProfile() async {
    await executeAsync(
      () async {
        final profile = await _repository.getProfile();
        _profile = profile;
        markAsInitialized();
        setSuccessMessage('Profile loaded successfully');
        return profile;
      },
      context: 'loadProfile',
    );
  }

  /// Load profile without using base provider error handling
  Future<ProfileModel?> loadProfileDirectly() async {
    try {
      final profile = await _repository.getProfile();
      _profile = profile;
      markAsInitialized();
      setSuccessMessage('Profile loaded successfully');
      clearError(); // Clear any existing error state
      notifyListeners();
      return profile;
    } catch (e) {
      // Don't set error state, just return null
      return null;
    }
  }

  Future<void> updateProfile(ProfileModel updates) async {
    await executeAsync(
      () async {
        final updatedProfile = await _repository.updateProfile(updates);
        _profile = updatedProfile;
        setSuccessMessage('Profile updated successfully');
        return updatedProfile;
      },
      context: 'updateProfile',
    );
  }

  Future<void> updateProfileImage(File imageFile) async {
    // IMPORTANT:
    // Do NOT block image upload just because some other profile request is in-flight.
    // BaseProvider has a single isLoading flag; if loadProfile() is slow, it can prevent uploads.
    if (_isUploadingProfileImage) {
      setError('Upload already in progress');
      return;
    }

    _isUploadingProfileImage = true;
    clearError();
    notifyListeners();

    print('🔄 ProfileProvider: Starting image upload...');

    try {
      final newImageUrl = await _repository.uploadProfileImage(imageFile);
      print('✅ ProfileProvider: Image uploaded successfully: $newImageUrl');

      if (_profile == null) {
        // If profile isn't loaded yet, still succeed and let caller refresh profile later.
        setSuccessMessage('Profile picture updated successfully');
        return;
      }

      // Cache-bust so the new image is fetched immediately.
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final urlWithTimestamp = newImageUrl.contains('?')
          ? '$newImageUrl&t=$timestamp'
          : '$newImageUrl?t=$timestamp';

      _profile = _profile!.copyWith(imageUrl: urlWithTimestamp);
      notifyListeners();
      setSuccessMessage('Profile picture updated successfully');
    } catch (e) {
      // Convert to a user-friendly error message and store it.
      final msg = ErrorHandler.getErrorMessage(e);
      setError(msg);
      print('❌ ProfileProvider: Image upload failed: $e');
      rethrow;
    } finally {
      _isUploadingProfileImage = false;
      notifyListeners();
    }
  }

  void cancelProfileImageUpload() {
    // Cancel the underlying HTTP request and ensure UI is unlocked.
    _repository.cancelActiveProfileImageUpload();
    _isUploadingProfileImage = false;
    stopLoading();
    setError('Upload cancelled');
  }

  void clearData() {
    _profile = null;
    clearError();
    notifyListeners();
  }

  // Method to force refresh the profile image
  void refreshProfileImage() {
    if (_profile != null && _profile!.imageUrl != null) {
      final imageUrl = _profile!.imageUrl!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecondsSinceEpoch;

      // Create a more aggressive cache-busting URL
      String urlWithTimestamp;
      if (imageUrl.contains('?')) {
        urlWithTimestamp =
            '$imageUrl&t=$timestamp&r=$random&_cb=${timestamp}_$random';
      } else {
        urlWithTimestamp =
            '$imageUrl?t=$timestamp&r=$random&_cb=${timestamp}_$random';
      }

      print(
          '🔄 ProfileProvider: Refreshing image URL with aggressive cache-busting');
      print('🔄 Original URL: $imageUrl');
      print('🔄 New URL: $urlWithTimestamp');

      _profile = _profile!.copyWith(imageUrl: urlWithTimestamp);
      notifyListeners();
      print('✅ ProfileProvider: Image URL refreshed with cache-busting');
    }
  }

  // Method to gently refresh image with cache-busting
  Future<void> forceImageRefresh() async {
    if (_profile != null && _profile!.imageUrl != null) {
      print('🔄 ProfileProvider: Gently refreshing image...');

      // Add a simple timestamp to bust cache
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final urlWithCacheBust = _profile!.imageUrl!.contains('?')
          ? '${_profile!.imageUrl!}&t=$timestamp'
          : '${_profile!.imageUrl!}?t=$timestamp';

      _profile = _profile!.copyWith(imageUrl: urlWithCacheBust);
      notifyListeners();
      print('✅ ProfileProvider: Image refresh completed');
    }
  }

  // Method to manually update profile image URL
  void updateImageUrl(String newImageUrl) {
    if (_profile != null) {
      print('🔄 ProfileProvider: Manually updating image URL: $newImageUrl');
      _profile = _profile!.copyWith(imageUrl: newImageUrl);
      notifyListeners();
      print('✅ ProfileProvider: Image URL updated manually');
    }
  }

  // Method to clear profile image
  void clearProfileImage() {
    if (_profile != null) {
      print('🔄 ProfileProvider: Clearing profile image');
      _profile = _profile!.copyWith(imageUrl: null);
      notifyListeners();
      print('✅ ProfileProvider: Profile image cleared');
    }
  }

  // Method to force profile reload
  Future<void> forceReloadProfile() async {
    print('🔄 ProfileProvider: Force reloading profile...');
    try {
      final updatedProfile = await _repository.getProfile();
      _profile = updatedProfile;
      notifyListeners();
      print('✅ ProfileProvider: Profile force reloaded successfully');
    } catch (e) {
      print('❌ ProfileProvider: Force reload failed: $e');
    }
  }

  @override
  void dispose() {
    _profile = null;
    super.dispose();
  }
}

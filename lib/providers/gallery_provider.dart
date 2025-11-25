import 'package:flutter/material.dart';
import '../models/gallery_model.dart';
import '../repository/gallery/gallery_repository.dart';
import '../repository/Auth_repository.dart';

class GalleryProvider extends ChangeNotifier {
  final GalleryRepository repository;
  final AuthRepository _authRepository = AuthRepository();

  GalleryProvider({required this.repository});

  List<GalleryImage> _images = [];
  List<GalleryImage> _favoriteImages = [];
  List<GalleryImage> _locationImages = [];
  List<GalleryImage> _searchResults = [];

  bool _isLoading = false;
  bool _isUploading = false;
  bool _isFavoritesLoading = false;
  bool _isLocationLoading = false;
  bool _isSearching = false;

  String? _error;
  String? _successMessage;
  String _currentUserId = '';

  // Getters
  List<GalleryImage> get images => _images;
  List<GalleryImage> get favoriteImages => _favoriteImages;
  List<GalleryImage> get locationImages => _locationImages;
  List<GalleryImage> get searchResults => _searchResults;

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isFavoritesLoading => _isFavoritesLoading;
  bool get isLocationLoading => _isLocationLoading;
  bool get isSearching => _isSearching;

  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get hasError => _error != null;
  bool get hasSuccessMessage => _successMessage != null;

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// Load all gallery images
  Future<void> loadGalleryImages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      _images = await repository.fetchGalleryImages(token);
      _successMessage = 'Gallery loaded successfully';
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Upload image from file path
  Future<bool> uploadImage({
    required String filePath,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final newImage = await repository.uploadImage(
        filePath: filePath,
        token: token,
        caption: caption,
        location: location,
        tags: tags,
      );

      // Add to the beginning of the list (most recent first)
      _images.insert(0, newImage);
      _successMessage = 'Image uploaded successfully';

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Upload video from file path
  Future<bool> uploadVideo({
    required String filePath,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    _isUploading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final newVideo = await repository.uploadVideo(
        filePath: filePath,
        token: token,
        caption: caption,
        location: location,
        tags: tags,
      );

      // Add to the beginning of the list (most recent first)
      _images.insert(0, newVideo);
      _successMessage = 'Video uploaded successfully';

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete image
  Future<bool> deleteImage(String imageId) async {
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final success = await repository.deleteImage(imageId, token);
      if (success) {
        _images.removeWhere((image) => image.id == imageId);
        _favoriteImages.removeWhere((image) => image.id == imageId);
        _locationImages.removeWhere((image) => image.id == imageId);
        _searchResults.removeWhere((image) => image.id == imageId);

        _successMessage = 'Image deleted successfully';
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String imageId, bool currentStatus) async {
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final updatedImage =
          await repository.toggleFavorite(imageId, token, !currentStatus);

      // Update in all lists
      _updateImageInLists(updatedImage);

      _successMessage = updatedImage.isFavorite
          ? 'Added to favorites'
          : 'Removed from favorites';
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update image details
  Future<bool> updateImage({
    required String imageId,
    String? caption,
    String? location,
    List<String>? tags,
  }) async {
    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      final updatedImage = await repository.updateImage(
        imageId: imageId,
        token: token,
        caption: caption,
        location: location,
        tags: tags,
      );

      _updateImageInLists(updatedImage);
      _successMessage = 'Image updated successfully';
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Load favorite images
  Future<void> loadFavoriteImages() async {
    _isFavoritesLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      _favoriteImages = await repository.getFavoriteImages(token);
    } catch (e) {
      _error = e.toString();
    }

    _isFavoritesLoading = false;
    notifyListeners();
  }

  /// Load images by location
  Future<void> loadLocationImages(String location) async {
    _isLocationLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      _locationImages = await repository.getImagesByLocation(token, location);
    } catch (e) {
      _error = e.toString();
    }

    _isLocationLoading = false;
    notifyListeners();
  }

  /// Search images
  Future<void> searchImages(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authRepository.getAuthToken();
      if (token == null) {
        throw Exception('Authentication required');
      }

      _searchResults = await repository.searchImages(token, query);
    } catch (e) {
      _error = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// Helper method to update image in all lists
  void _updateImageInLists(GalleryImage updatedImage) {
    // Update in main images list
    final mainIndex = _images.indexWhere((img) => img.id == updatedImage.id);
    if (mainIndex != -1) {
      _images[mainIndex] = updatedImage;
    }

    // Update in favorites list
    final favIndex =
        _favoriteImages.indexWhere((img) => img.id == updatedImage.id);
    if (favIndex != -1) {
      if (updatedImage.isFavorite) {
        _favoriteImages[favIndex] = updatedImage;
      } else {
        _favoriteImages.removeAt(favIndex);
      }
    } else if (updatedImage.isFavorite) {
      _favoriteImages.insert(0, updatedImage);
    }

    // Update in location images list
    final locIndex =
        _locationImages.indexWhere((img) => img.id == updatedImage.id);
    if (locIndex != -1) {
      _locationImages[locIndex] = updatedImage;
    }

    // Update in search results
    final searchIndex =
        _searchResults.indexWhere((img) => img.id == updatedImage.id);
    if (searchIndex != -1) {
      _searchResults[searchIndex] = updatedImage;
    }
  }

  /// Check if image belongs to current user
  bool isMyImage(GalleryImage image) {
    // Since all media comes from events the user participated in,
    // all images belong to the current user
    return true;
  }

  /// Get images grouped by month
  Map<String, List<GalleryImage>> get imagesByMonth {
    final Map<String, List<GalleryImage>> grouped = {};
    for (final image in _images) {
      grouped.putIfAbsent(image.month, () => []).add(image);
    }
    return grouped;
  }

  /// Refresh all data
  Future<void> refreshAllData() async {
    await Future.wait([
      loadGalleryImages(),
      loadFavoriteImages(),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

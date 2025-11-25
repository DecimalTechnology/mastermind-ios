import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:master_mind/models/User_model.dart';
import 'package:master_mind/repository/Auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:master_mind/core/error_handling/error_handling.dart';
import 'package:master_mind/services/auth_token_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final AuthTokenService _authTokenService = AuthTokenService();
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  StreamSubscription<bool>? _authStateSubscription;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository {
    // Listen to auth state changes from token service
    _authStateSubscription =
        _authTokenService.authStateStream.listen((isAuthenticated) {
      if (!isAuthenticated && _user != null) {
        // Token expired, clear user data
        _user = null;
        _error = 'Session expired. Please login again.';
        notifyListeners();
      }
    });
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;

  AuthRepository get authRepository => _authRepository;

  // Check if user data exists in shared preferences (quick check without network calls)
  Future<bool> hasStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      return userDataString != null;
    } catch (e) {
      return false;
    }
  }

  // Get stored user data without validation (for quick access)
  Future<User?> getStoredUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = json.decode(userDataString);

        final user = User.fromJson(userData);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is already authenticated on app start
  Future<void> checkAuthStatus() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Check if user is authenticated using token service
      final isAuthenticated = await _authTokenService.isAuthenticated();

      if (isAuthenticated) {
        // User has valid token, get stored user data
        final storedUser = await getStoredUserData();
        if (storedUser != null) {
          _user = storedUser;
          _error = null;
        } else {
          // No user data but valid token - try to get user from API
          try {
            final user = await _authRepository.getCurrentUser();
            _user = user;
            await _saveUserData(user);
            _error = null;
          } catch (e) {
            // API call failed, but token is valid
            // Keep stored data if available
            _user = storedUser;
            _error = null;
          }
        }
      } else {
        // No valid token, clear user data
        await _clearStoredData();
        _user = null;
        _error = null;
      }
    } catch (e) {
      // Handle authentication errors gracefully
      if (e is AuthenticationException) {
        _error = 'Session expired. Please login again.';
        _user = null;
        await _clearStoredData();
      } else {
        _error = ErrorHandler.getErrorMessage(e);
        _user = null;
      }
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Save user data to shared preferences
  // Future<void> _saveUserData(User user) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userDataString = json.encode(user.toJson());
  //   await prefs.setString('user_data', userDataString);
  //   print('hiiiiiiiiiiii');
  //       await prefs.getString('user_data', userDataString);
  //       pri

  // }
  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert user object to JSON string
    final userDataString = json.encode(user.toJson());

    // Save to SharedPreferences
    await prefs.setString('user_data', userDataString);

    // Optional: Retrieve it again to confirm
  }

  // Clear stored user data
  Future<void> _clearStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _authRepository.login(email, password);

      // Get user data from the response
      if (data['data'] != null && data['data']['user'] != null) {
        _user = User.fromJson(data['data']['user']);

        // Store tokens and user data
        final accessToken = data['data']['accessToken'];
        if (accessToken != null) {
          // Calculate token expiry (assuming 24 hours from now)
          final expiresAt = DateTime.now().add(const Duration(hours: 24));

          await _authTokenService.storeTokens(
            accessToken: accessToken,
            expiresAt: expiresAt,
          );
        }

        // Save user data to shared preferences
        await _saveUserData(_user!);
      }

      _error = null;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required int phoneNumber,
    required String password,
    String? chapterId,
    String? nationId,
    String? regionId,
    String? localId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
        firstName: name.split(' ').first,
        lastName:
            name.split(' ').length > 1 ? name.split(' ').skip(1).join(' ') : '',
        phone: phoneNumber.toString(),
        company: '',
        position: '',
        industry: '',
        region: regionId ?? '',
        chapter: chapterId ?? '',
      );

      // Extract user data from response
      if (response['data'] != null && response['data']['user'] != null) {
        _user = User.fromJson(response['data']['user']);
        await _saveUserData(_user!);
      } else if (response['user'] != null) {
        _user = User.fromJson(response['user']);
        await _saveUserData(_user!);
      } else {
        throw Exception('User data not found in response');
      }

      _error = null;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.logout();
      await _authTokenService.clearTokens();
      await _clearStoredData();
      _user = null;
      _error = null;

      // Clear other providers' data
      _clearAllProvidersData();
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _clearAllProvidersData() {
    // This will be called by the app to clear all provider data
    // We'll implement this through a callback mechanism
  }

  Future<bool> resetPassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success =
          await _authRepository.resetPassword(oldPassword, newPassword);
      if (!success) {
        _error = 'Failed to reset password';
      }
      return success;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.getCurrentUser();
      // Update stored user data
      if (_user != null) {
        await _saveUserData(_user!);
      }
      _error = null;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyEmail(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authRepository.verifyEmail(token);
      if (!success) {
        _error = 'Failed to verify email';
      }
      return success;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resendVerificationEmail() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authRepository.resendVerificationEmail();
      if (!success) {
        _error = 'Failed to resend verification email';
      }
      return success;
    } catch (e) {
      _error = ErrorHandler.getErrorMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

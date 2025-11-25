import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:master_mind/core/error_handling/exceptions/custom_exceptions.dart';
import 'package:master_mind/core/error_handling/handlers/error_handler.dart';

/// Service to handle JWT token management and automatic refresh
class AuthTokenService {
  static final AuthTokenService _instance = AuthTokenService._internal();
  factory AuthTokenService() => _instance;
  AuthTokenService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  // Token keys
  static const String _authTokenKey = 'authToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _tokenExpiryKey = 'tokenExpiry';

  // Token expiration buffer (5 minutes before actual expiry)
  static const Duration _expiryBuffer = Duration(minutes: 5);

  // Stream for authentication state changes
  Stream<bool> get authStateStream => _authStateController.stream;

  // Current token
  String? _currentToken;
  DateTime? _tokenExpiry;
  bool _isRefreshing = false;

  /// Get the current auth token
  Future<String?> getAuthToken() async {
    try {
      // Return cached token if still valid
      if (_currentToken != null && _isTokenValid()) {
        return _currentToken;
      }

      // Get token from storage
      final token = await _storage.read(key: _authTokenKey);
      final expiryString = await _storage.read(key: _tokenExpiryKey);

      if (token == null) {
        _currentToken = null;
        _tokenExpiry = null;
        return null;
      }

      // Parse expiry
      DateTime? expiry;
      if (expiryString != null) {
        expiry = DateTime.tryParse(expiryString);
      }

      _currentToken = token;
      _tokenExpiry = expiry;

      // Check if token is still valid
      if (!_isTokenValid()) {
        await clearTokens();
        return null;
      }

      return _currentToken;
    } catch (e) {
      ErrorHandler.logError(e, null, context: 'AuthTokenService.getAuthToken');
      return null;
    }
  }

  /// Store auth tokens
  Future<void> storeTokens({
    required String accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) async {
    try {
      await _storage.write(key: _authTokenKey, value: accessToken);
      _currentToken = accessToken;

      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
      }

      if (expiresAt != null) {
        await _storage.write(
            key: _tokenExpiryKey, value: expiresAt.toIso8601String());
        _tokenExpiry = expiresAt;
      }

      _authStateController.add(true);
    } catch (e) {
      ErrorHandler.logError(e, null, context: 'AuthTokenService.storeTokens');
      throw CacheException('Failed to store authentication tokens: $e');
    }
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _authTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      await _storage.delete(key: _tokenExpiryKey);

      _currentToken = null;
      _tokenExpiry = null;
      _isRefreshing = false;

      _authStateController.add(false);
    } catch (e) {
      ErrorHandler.logError(e, null, context: 'AuthTokenService.clearTokens');
      throw CacheException('Failed to clear authentication tokens: $e');
    }
  }

  /// Check if current token is valid (not expired)
  bool _isTokenValid() {
    if (_currentToken == null || _tokenExpiry == null) {
      return false;
    }

    // Add buffer to expiry time
    final effectiveExpiry = _tokenExpiry!.subtract(_expiryBuffer);
    return DateTime.now().isBefore(effectiveExpiry);
  }

  /// Check if token needs refresh
  bool needsRefresh() {
    if (_currentToken == null || _tokenExpiry == null) {
      return true;
    }

    // Refresh if token expires within buffer time
    final effectiveExpiry = _tokenExpiry!.subtract(_expiryBuffer);
    return DateTime.now().isAfter(effectiveExpiry);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      ErrorHandler.logError(e, null,
          context: 'AuthTokenService.getRefreshToken');
      return null;
    }
  }

  /// Handle 401 authentication errors
  Future<void> handleAuthError() async {
    if (kDebugMode) {}

    await clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && _isTokenValid();
  }

  /// Get token expiry time
  DateTime? getTokenExpiry() => _tokenExpiry;

  /// Check if currently refreshing token
  bool get isRefreshing => _isRefreshing;

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }
}

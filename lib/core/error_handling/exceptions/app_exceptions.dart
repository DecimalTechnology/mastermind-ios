import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
// Removed unused import
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:master_mind/utils/const.dart';

/// Comprehensive exception handling system covering all app scenarios
class ComprehensiveExceptionHandler {
  static final ComprehensiveExceptionHandler _instance =
      ComprehensiveExceptionHandler._internal();
  factory ComprehensiveExceptionHandler() => _instance;
  ComprehensiveExceptionHandler._internal();

  // ===== 1. NETWORK & API EXCEPTIONS =====

  /// Handle network connectivity issues
  static Future<bool> checkNetworkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // Connectivity check failed, return false
      return false;
    }
  }

  /// Handle API timeout scenarios
  static Future<T?> handleApiTimeout<T>(
    Future<T> Function() apiCall, {
    Duration timeout = const Duration(seconds: 30),
    T? fallbackValue,
    String? context,
  }) async {
    try {
      return await apiCall().timeout(timeout);
    } on TimeoutException catch (e) {
      _logException('API_TIMEOUT', e, context: context);
      return fallbackValue;
    } catch (e) {
      _logException('API_ERROR', e, context: context);
      return fallbackValue;
    }
  }

  /// Handle server errors (5xx, 4xx)
  static String handleServerError(int statusCode, String? responseBody) {
    switch (statusCode) {
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Resource not found. Please check the URL.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Network error occurred. Please check your connection.';
    }
  }

  // ===== 2. DATA & PARSING EXCEPTIONS =====

  /// Safe JSON parsing with error handling
  static T? safeJsonParse<T>(
    String jsonString,
    T Function(Map<String, dynamic>) fromJson, {
    T? fallbackValue,
    String? context,
  }) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return fromJson(json);
    } on FormatException catch (e) {
      print('JSON parsing error in $context: $e');
      _logException('JSON_PARSE_ERROR', e, context: context);
      return fallbackValue;
    } catch (e) {
      print('Data parsing error in $context: $e');
      _logException('DATA_PARSE_ERROR', e, context: context);
      return fallbackValue;
    }
  }

  /// Validate and sanitize input data
  static String sanitizeInput(String? input, {String fallback = ''}) {
    if (input == null || input.trim().isEmpty) return fallback;
    return input.trim();
  }

  /// Safe type conversion
  static T? safeTypeConversion<T>(dynamic value, T Function(dynamic) converter,
      {T? fallback}) {
    try {
      return converter(value);
    } catch (e) {
      print('Type conversion error: $e');
      return fallback;
    }
  }

  // ===== 3. AUTHENTICATION & SECURITY EXCEPTIONS =====

  /// Handle authentication errors
  static String handleAuthError(dynamic error) {
    if (error.toString().contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (error.toString().contains('user_not_found')) {
      return 'User not found. Please check your email.';
    } else if (error.toString().contains('weak_password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.toString().contains('email_already_in_use')) {
      return 'Email is already registered. Please use a different email.';
    } else if (error.toString().contains('expired')) {
      return 'Session expired. Please login again.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }

  /// Handle permission errors
  static Future<bool> checkPermission(PermissionType permission) async {
    try {
      switch (permission) {
        case PermissionType.camera:
          // Implement camera permission check
          return true;
        case PermissionType.location:
          // Implement location permission check
          return true;
        case PermissionType.storage:
          // Implement storage permission check
          return true;
        case PermissionType.contacts:
          // Implement contacts permission check
          return true;
        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  // ===== 4. FILE & STORAGE EXCEPTIONS =====

  /// Safe file operations
  static Future<bool> safeFileOperation(
    Future<void> Function() operation, {
    String? context,
  }) async {
    try {
      await operation();
      return true;
    } on FileSystemException catch (e) {
      print('File system error in $context: $e');
      _logException('FILE_SYSTEM_ERROR', e, context: context);
      return false;
    } catch (e) {
      print('File operation error in $context: $e');
      _logException('FILE_OPERATION_ERROR', e, context: context);
      return false;
    }
  }

  /// Check available storage space
  static Future<bool> checkStorageSpace(
      {int requiredBytes = 1024 * 1024}) async {
    try {
      // Implement storage space check
      return true;
    } catch (e) {
      print('Storage space check failed: $e');
      return false;
    }
  }

  // ===== 5. UI & USER INPUT EXCEPTIONS =====

  /// Validate form inputs
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Phone number is required';
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    if (!phoneRegex.hasMatch(phone)) return 'Please enter a valid phone number';
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  /// Safe navigation
  static Future<void> safeNavigate(
    BuildContext context,
    Widget Function() screenBuilder, {
    String? contextName,
  }) async {
    try {
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screenBuilder()),
        );
      }
    } catch (e) {
      print('Navigation error in $contextName: $e');
      _logException('NAVIGATION_ERROR', e, context: contextName);
      _showErrorSnackBar(context, 'Navigation failed. Please try again.');
    }
  }

  // ===== 6. DEVICE & SYSTEM EXCEPTIONS =====

  /// Check device capabilities
  static Future<bool> checkDeviceCapability(DeviceCapability capability) async {
    try {
      switch (capability) {
        case DeviceCapability.camera:
          // Check camera availability
          return true;
        case DeviceCapability.gps:
          // Check GPS availability
          return true;
        case DeviceCapability.biometric:
          // Check biometric availability
          return true;
        case DeviceCapability.storage:
          // Check storage availability
          return true;
        default:
          return true;
      }
    } catch (e) {
      print('Device capability check failed: $e');
      return false;
    }
  }

  /// Handle low memory scenarios
  static void handleLowMemory() {
    // Clear caches, dispose unused resources
    print('Low memory detected, clearing caches...');
  }

  // ===== 7. THIRD-PARTY LIBRARY EXCEPTIONS =====

  /// Safe SDK operations
  static Future<T?> safeSdkOperation<T>(
    Future<T> Function() sdkCall, {
    T? fallbackValue,
    String? context,
  }) async {
    try {
      return await sdkCall();
    } catch (e) {
      print('SDK error in $context: $e');
      _logException('SDK_ERROR', e, context: context);
      return fallbackValue;
    }
  }

  /// Handle API key errors
  static String handleApiKeyError(dynamic error) {
    if (error.toString().contains('invalid_api_key')) {
      return 'API configuration error. Please contact support.';
    } else if (error.toString().contains('quota_exceeded')) {
      return 'Service quota exceeded. Please try again later.';
    } else {
      return 'Service temporarily unavailable. Please try again.';
    }
  }

  // ===== 8. GENERAL RUNTIME EXCEPTIONS =====

  /// Safe setState operations - removed due to protected member access
  /// Use WidgetsBinding.instance.addPostFrameCallback instead for safe state updates

  /// Safe async operations
  static Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    T? fallbackValue,
    String? context,
  }) async {
    try {
      return await operation();
    } catch (e) {
      print('Async operation error in $context: $e');
      _logException('ASYNC_ERROR', e, context: context);
      return fallbackValue;
    }
  }

  // ===== UTILITY METHODS =====

  /// Log exceptions for debugging
  static void _logException(String type, dynamic error, {String? context}) {
    // Log to console for debugging
    print('[$type] Error in $context: $error');

    // Log to Firebase Crashlytics
    try {
      // Set custom keys for better error tracking
      FirebaseCrashlytics.instance.setCustomKey('error_type', type);
      if (context != null) {
        FirebaseCrashlytics.instance.setCustomKey('error_context', context);
      }

      // Record the error with stack trace
      FirebaseCrashlytics.instance.recordError(
        error,
        StackTrace.current,
        reason: '[$type] Error in $context',
      );
    } catch (e) {
      // Fallback if Crashlytics is not available
      print('Failed to log to Crashlytics: $e');
    }
  }

  /// Show error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kPrimaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show retry dialog
  static Future<bool> showRetryDialog(
    BuildContext context,
    String message, {
    String title = 'Error',
    String retryText = 'Retry',
    String cancelText = 'Cancel',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(retryText),
              ),
            ],
          ),
        ) ??
        false;
  }
}

// ===== ENUMS =====

enum PermissionType {
  camera,
  location,
  storage,
  contacts,
  microphone,
  notifications,
}

enum DeviceCapability {
  camera,
  gps,
  biometric,
  storage,
  bluetooth,
  wifi,
}

enum ExceptionType {
  network,
  api,
  data,
  auth,
  file,
  ui,
  device,
  sdk,
  runtime,
}

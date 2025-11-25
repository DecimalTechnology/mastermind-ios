import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// Removed unused import
import 'dart:convert';
// Removed unused import

class ApiMonitoringService {
  static final ApiMonitoringService _instance =
      ApiMonitoringService._internal();
  factory ApiMonitoringService() => _instance;
  ApiMonitoringService._internal();

  /// Track API call start
  void trackApiCallStart({
    required String endpoint,
    required String method,
    Map<String, dynamic>? requestBody,
    Map<String, String>? queryParams,
  }) {
    try {
      FirebaseCrashlytics.instance.log('API Call Started: $method $endpoint');

      // Add custom keys for better debugging
      FirebaseCrashlytics.instance.setCustomKey('api_endpoint', endpoint);
      FirebaseCrashlytics.instance.setCustomKey('api_method', method);

      if (requestBody != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('api_request_body', jsonEncode(requestBody));
      }

      if (queryParams != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('api_query_params', jsonEncode(queryParams));
      }

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance.log('API Request: $method $endpoint');
    } catch (e) {
      // Don't let Crashlytics errors break the app
      print('Error tracking API call start: $e');
    }
  }

  /// Track API call success
  void trackApiCallSuccess({
    required String endpoint,
    required String method,
    required int statusCode,
    required int responseTimeMs,
    Map<String, dynamic>? responseBody,
  }) {
    try {
      FirebaseCrashlytics.instance
          .log('API Call Success: $method $endpoint - ${statusCode}ms');

      // Add performance metrics
      FirebaseCrashlytics.instance
          .setCustomKey('api_response_time_ms', responseTimeMs);
      FirebaseCrashlytics.instance.setCustomKey('api_status_code', statusCode);

      if (responseBody != null) {
        // Only log response size, not full body to avoid sensitive data
        final responseSize = jsonEncode(responseBody).length;
        FirebaseCrashlytics.instance
            .setCustomKey('api_response_size_bytes', responseSize);
      }

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance
          .log('API Success: $method $endpoint (${statusCode}ms)');
    } catch (e) {
      print('Error tracking API call success: $e');
    }
  }

  /// Track API call error
  void trackApiCallError({
    required String endpoint,
    required String method,
    required int statusCode,
    required String errorMessage,
    required int responseTimeMs,
    Map<String, dynamic>? requestBody,
    Map<String, dynamic>? responseBody,
    StackTrace? stackTrace,
  }) {
    try {
      FirebaseCrashlytics.instance
          .log('API Call Error: $method $endpoint - $statusCode');

      // Add error details
      FirebaseCrashlytics.instance
          .setCustomKey('api_error_status_code', statusCode);
      FirebaseCrashlytics.instance
          .setCustomKey('api_error_message', errorMessage);
      FirebaseCrashlytics.instance
          .setCustomKey('api_response_time_ms', responseTimeMs);

      if (requestBody != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('api_error_request_body', jsonEncode(requestBody));
      }

      if (responseBody != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('api_error_response_body', jsonEncode(responseBody));
      }

      // Record the error with stack trace
      FirebaseCrashlytics.instance.recordError(
        'API Error: $method $endpoint - $errorMessage',
        stackTrace ?? StackTrace.current,
        reason: 'API call failed',
        fatal: false,
      );

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance
          .log('API Error: $method $endpoint ($statusCode)');
    } catch (e) {
      print('Error tracking API call error: $e');
    }
  }

  /// Track network error
  void trackNetworkError({
    required String endpoint,
    required String method,
    required String errorMessage,
    required int responseTimeMs,
    Map<String, dynamic>? requestBody,
    StackTrace? stackTrace,
  }) {
    try {
      FirebaseCrashlytics.instance
          .log('Network Error: $method $endpoint - $errorMessage');

      // Add error details
      FirebaseCrashlytics.instance
          .setCustomKey('network_error_message', errorMessage);
      FirebaseCrashlytics.instance
          .setCustomKey('network_response_time_ms', responseTimeMs);

      if (requestBody != null) {
        FirebaseCrashlytics.instance.setCustomKey(
            'network_error_request_body', jsonEncode(requestBody));
      }

      // Record the error with stack trace
      FirebaseCrashlytics.instance.recordError(
        'Network Error: $method $endpoint - $errorMessage',
        stackTrace ?? StackTrace.current,
        reason: 'Network request failed',
        fatal: false,
      );

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance.log('Network Error: $method $endpoint');
    } catch (e) {
      print('Error tracking network error: $e');
    }
  }

  /// Track authentication error
  void trackAuthError({
    required String endpoint,
    required String method,
    required String errorMessage,
    StackTrace? stackTrace,
  }) {
    try {
      FirebaseCrashlytics.instance
          .log('Auth Error: $method $endpoint - $errorMessage');

      // Add error details
      FirebaseCrashlytics.instance
          .setCustomKey('auth_error_message', errorMessage);

      // Record the error with stack trace
      FirebaseCrashlytics.instance.recordError(
        'Auth Error: $method $endpoint - $errorMessage',
        stackTrace ?? StackTrace.current,
        reason: 'Authentication failed',
        fatal: false,
      );

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance.log('Auth Error: $method $endpoint');
    } catch (e) {
      print('Error tracking auth error: $e');
    }
  }

  /// Track timeout error
  void trackTimeoutError({
    required String endpoint,
    required String method,
    required Duration timeout,
    Map<String, dynamic>? requestBody,
  }) {
    try {
      FirebaseCrashlytics.instance
          .log('Timeout Error: $method $endpoint - ${timeout.inSeconds}s');

      // Add error details
      FirebaseCrashlytics.instance
          .setCustomKey('timeout_duration_seconds', timeout.inSeconds);

      if (requestBody != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('timeout_request_body', jsonEncode(requestBody));
      }

      // Record the error
      FirebaseCrashlytics.instance.recordError(
        'Timeout Error: $method $endpoint - ${timeout.inSeconds}s',
        StackTrace.current,
        reason: 'API request timed out',
        fatal: false,
      );

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance.log('Timeout Error: $method $endpoint');
    } catch (e) {
      print('Error tracking timeout error: $e');
    }
  }

  /// Track validation error
  void trackValidationError({
    required String endpoint,
    required String method,
    required String fieldName,
    required String errorMessage,
    Map<String, dynamic>? requestBody,
  }) {
    try {
      FirebaseCrashlytics.instance.log(
          'Validation Error: $method $endpoint - $fieldName: $errorMessage');

      // Add error details
      FirebaseCrashlytics.instance.setCustomKey('validation_field', fieldName);
      FirebaseCrashlytics.instance
          .setCustomKey('validation_message', errorMessage);

      if (requestBody != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('validation_request_body', jsonEncode(requestBody));
      }

      // Record the error
      FirebaseCrashlytics.instance.recordError(
        'Validation Error: $method $endpoint - $fieldName: $errorMessage',
        StackTrace.current,
        reason: 'Data validation failed',
        fatal: false,
      );

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance.log('Validation Error: $method $endpoint');
    } catch (e) {
      print('Error tracking validation error: $e');
    }
  }

  /// Track parsing error
  void trackParsingError({
    required String endpoint,
    required String method,
    required String errorMessage,
    required String responseBody,
    StackTrace? stackTrace,
  }) {
    try {
      FirebaseCrashlytics.instance
          .log('Parsing Error: $method $endpoint - $errorMessage');

      // Add error details
      FirebaseCrashlytics.instance
          .setCustomKey('parsing_error_message', errorMessage);
      FirebaseCrashlytics.instance
          .setCustomKey('parsing_response_body', responseBody);

      // Record the error with stack trace
      FirebaseCrashlytics.instance.recordError(
        'Parsing Error: $method $endpoint - $errorMessage',
        stackTrace ?? StackTrace.current,
        reason: 'Response parsing failed',
        fatal: false,
      );

      // Add breadcrumb for analytics
      FirebaseCrashlytics.instance.log('Parsing Error: $method $endpoint');
    } catch (e) {
      print('Error tracking parsing error: $e');
    }
  }

  /// Set user context for better error tracking
  void setUserContext({
    String? userId,
    String? userEmail,
    String? userRole,
  }) {
    try {
      if (userId != null) {
        FirebaseCrashlytics.instance.setUserIdentifier(userId);
      }

      if (userEmail != null) {
        FirebaseCrashlytics.instance.setCustomKey('user_email', userEmail);
      }

      if (userRole != null) {
        FirebaseCrashlytics.instance.setCustomKey('user_role', userRole);
      }
    } catch (e) {
      print('Error setting user context: $e');
    }
  }

  /// Clear user context on logout
  void clearUserContext() {
    try {
      FirebaseCrashlytics.instance.setUserIdentifier('');
      FirebaseCrashlytics.instance.setCustomKey('user_email', '');
      FirebaseCrashlytics.instance.setCustomKey('user_role', '');
    } catch (e) {
      print('Error clearing user context: $e');
    }
  }
}

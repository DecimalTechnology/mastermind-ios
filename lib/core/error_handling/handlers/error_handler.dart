import 'package:flutter/material.dart';
import 'package:http/http.dart' as http_client;
import 'package:master_mind/utils/const.dart';
import 'dart:convert';
import 'dart:io';
import '../exceptions/custom_exceptions.dart';

/// Centralized error handling utility
class ErrorHandler {
  static const String _defaultErrorMessage =
      'Something went wrong. Please try again.';
  static const String _networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String _serverErrorMessage =
      'Server error. Please try again later.';
  static const String _timeoutErrorMessage =
      'Request timeout. Please try again.';
  static const String _authErrorMessage =
      'Authentication failed. Please login again.';

  /// Convert any error to a user-friendly message
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      String message = error.message;
      // Remove "Resource not found: " prefix if present
      if (message.startsWith('Resource not found: ')) {
        message = message.substring('Resource not found: '.length);
      }
      return message;
    }

    if (error is http_client.ClientException) {
      return _networkErrorMessage;
    }

    if (error is SocketException) {
      return _networkErrorMessage;
    }

    if (error is FormatException) {
      return 'Invalid data format received from server.';
    }

    if (error is Exception) {
      final errorString = error.toString().toLowerCase();

      if (errorString.contains('timeout')) {
        return _timeoutErrorMessage;
      }

      if (errorString.contains('network') ||
          errorString.contains('connection')) {
        return _networkErrorMessage;
      }

      if (errorString.contains('unauthorized') || errorString.contains('401')) {
        return _authErrorMessage;
      }

      if (errorString.contains('forbidden') || errorString.contains('403')) {
        return 'Access denied. You don\'t have permission for this action.';
      }

      if (errorString.contains('not found') || errorString.contains('404')) {
        return 'The requested resource was not found.';
      }

      if (errorString.contains('server') || errorString.contains('500')) {
        return _serverErrorMessage;
      }
    }

    return _defaultErrorMessage;
  }

  /// Parse HTTP response and throw appropriate exceptions
  static void handleHttpResponse(http_client.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Success
    }

    String errorMessage;
    String? errorCode;

    try {
      final errorData = jsonDecode(response.body);
      errorMessage = errorData['message'] ??
          errorData['error'] ??
          errorData['detail'] ??
          'HTTP ${response.statusCode}';
      errorCode = errorData['code']?.toString();
    } catch (e) {
      errorMessage = 'HTTP ${response.statusCode}';
    }

    switch (response.statusCode) {
      case 400:
        throw ValidationException(errorMessage, code: errorCode);
      case 401:
        throw AuthenticationException(errorMessage, code: errorCode);
      case 403:
        throw PermissionException(errorMessage, code: errorCode);
      case 404:
        throw AppException('Resource not found: $errorMessage',
            code: errorCode);
      case 408:
      case 504:
        throw TimeoutException(errorMessage, code: errorCode);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage,
            code: errorCode, statusCode: response.statusCode);
      default:
        if (response.statusCode >= 500) {
          throw ServerException(errorMessage,
              code: errorCode, statusCode: response.statusCode);
        } else {
          throw AppException(errorMessage, code: errorCode);
        }
    }
  }

  /// Handle network-related errors
  static void handleNetworkError(dynamic error) {
    if (error is SocketException) {
      throw NetworkException('Network connection failed: ${error.message}');
    } else if (error is http_client.ClientException) {
      throw NetworkException('HTTP client error: ${error.message}');
    } else if (error is TimeoutException) {
      throw TimeoutException('Request timed out');
    } else {
      throw NetworkException('Unexpected network error: ${error.toString()}');
    }
  }

  /// Log error for debugging
  static void logError(dynamic error, StackTrace? stack, {String? context}) {
    print('=== ERROR LOG ===');
    print('Context: $context');
    print('Error: $error');
    if (stack != null) {
      print('StackTrace: $stack');
    }
    print('=================');
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kPrimaryColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

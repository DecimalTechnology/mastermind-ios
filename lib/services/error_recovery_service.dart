import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
// Removed unused import
import '../core/error_handling/exceptions/custom_exceptions.dart';
import '../core/error_handling/error_handling.dart';

/// Service for handling error recovery and retry logic
class ErrorRecoveryService {
  static final ErrorRecoveryService _instance =
      ErrorRecoveryService._internal();
  factory ErrorRecoveryService() => _instance;
  ErrorRecoveryService._internal();

  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  /// Execute operation with automatic retry for recoverable errors
  Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = _maxRetries,
    Duration retryDelay = _retryDelay,
    String? context,
    bool showRetryDialog = true,
    BuildContext? dialogContext,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;

        if (_isRecoverableError(e) && attempts < maxRetries) {
          // Log retry attempt
          ErrorHandler.logError(e, StackTrace.current,
              context:
                  '${context ?? 'Operation'} - Retry $attempts/$maxRetries');

          // Wait before retry
          await Future.delayed(retryDelay * attempts);

          // Show retry dialog if requested
          if (showRetryDialog && dialogContext != null) {
            bool shouldRetry = await _showRetryDialog(
              dialogContext,
              ErrorHandler.getErrorMessage(e),
              attempts,
              maxRetries,
            );

            if (!shouldRetry) {
              break;
            }
          }
        } else {
          // Non-recoverable error or max retries reached
          rethrow;
        }
      }
    }

    return null;
  }

  /// Check if error is recoverable (can be retried)
  bool _isRecoverableError(dynamic error) {
    if (error is NetworkException) return true;
    if (error is TimeoutException) return true;
    if (error is ServerException) {
      // Retry for 5xx errors, not 4xx
      return error.statusCode != null && error.statusCode! >= 500;
    }

    // Check error message for network-related keywords
    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('timeout') ||
        errorString.contains('server');
  }

  /// Show retry dialog
  Future<bool> _showRetryDialog(
    BuildContext context,
    String errorMessage,
    int currentAttempt,
    int maxAttempts,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Connection Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(errorMessage),
                  const SizedBox(height: 8),
                  Text(
                    'Attempt $currentAttempt of $maxAttempts',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Retry'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// Handle offline mode gracefully
  Future<T?> executeWithOfflineFallback<T>(
    Future<T> Function() onlineOperation,
    Future<T> Function() offlineOperation, {
    String? context,
  }) async {
    try {
      return await onlineOperation();
    } catch (e) {
      if (_isOfflineError(e)) {
        // Try offline operation
        try {
          return await offlineOperation();
        } catch (offlineError) {
          ErrorHandler.logError(offlineError, StackTrace.current,
              context: '${context ?? 'Operation'} - Offline Fallback Failed');
          rethrow;
        }
      } else {
        rethrow;
      }
    }
  }

  /// Check if error indicates offline state
  bool _isOfflineError(dynamic error) {
    if (error is NetworkException) return true;
    if (error is SocketException) return true;

    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('unreachable');
  }

  /// Get error category for analytics
  String getErrorCategory(dynamic error) {
    if (error is NetworkException) return 'network';
    if (error is AuthenticationException) return 'authentication';
    if (error is ValidationException) return 'validation';
    if (error is ServerException) return 'server';
    if (error is TimeoutException) return 'timeout';
    if (error is PermissionException) return 'permission';
    if (error is CacheException) return 'cache';

    return 'unknown';
  }

  /// Get user-friendly error message with recovery suggestions
  String getRecoveryMessage(dynamic error) {
    final category = getErrorCategory(error);

    switch (category) {
      case 'network':
        return 'Please check your internet connection and try again.';
      case 'authentication':
        return 'Please log in again to continue.';
      case 'validation':
        return 'Please check your input and try again.';
      case 'server':
        return 'Server is temporarily unavailable. Please try again later.';
      case 'timeout':
        return 'Request took too long. Please try again.';
      case 'permission':
        return 'You don\'t have permission for this action.';
      case 'cache':
        return 'Local data is corrupted. Please refresh the app.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}

import 'package:flutter/material.dart';
import '../core/error_handling/error_handling.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Base provider class with common state management functionality
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isInitialized => _isInitialized;
  bool get hasError => _error != null;
  bool get hasSuccessMessage => _successMessage != null;

  /// Execute an async operation with proper error handling
  Future<T?> executeAsync<T>(
    Future<T> Function() operation, {
    String? context,
    bool showErrorSnackBar = false,
    BuildContext? snackBarContext,
  }) async {
    if (_isLoading) {
      // Avoid silently skipping operations (this can look like "API not working")
      // and can cause the UI to show success without doing anything.
      setError('Please wait… another request is already in progress');
      return null;
    }

    try {
      _startLoading();
      final result = await operation();
      _finishLoading();
      return result;
    } catch (e) {
      _handleError(e, context: context);

      if (showErrorSnackBar && snackBarContext != null) {
        ErrorHandler.showErrorSnackBar(
          snackBarContext,
          ErrorHandler.getErrorMessage(e),
        );
      }

      return null;
    }
  }

  /// Execute an async operation that returns a boolean
  Future<bool> executeAsyncBool(
    Future<bool> Function() operation, {
    String? context,
    bool showErrorSnackBar = false,
    BuildContext? snackBarContext,
  }) async {
    final result = await executeAsync(
      operation,
      context: context,
      showErrorSnackBar: showErrorSnackBar,
      snackBarContext: snackBarContext,
    );
    return result ?? false;
  }

  /// Clear all messages (error and success)
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Clear only error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear only success messages
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// Set success message
  void setSuccessMessage(String message) {
    _successMessage = message;
    _error = null;
    notifyListeners();
  }

  /// Set error message
  void setError(String message) {
    _error = message;
    _successMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _isLoading = false;
    _error = null;
    _successMessage = null;
    _isInitialized = false;
    notifyListeners();
  }

  /// Mark as initialized
  void markAsInitialized() {
    _isInitialized = true;
    notifyListeners();
  }

  /// Start loading state
  void _startLoading() {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Finish loading state
  void _finishLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Force-stop loading state (used for user cancellation of long-running operations)
  @protected
  void stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  /// Handle error with proper logging
  void _handleError(dynamic error, {String? context}) {
    final errorMessage = ErrorHandler.getErrorMessage(error);
    _error = errorMessage;
    _isLoading = false;

    // Log error for debugging
    ErrorHandler.logError(error, StackTrace.current, context: context);

    // Log to Firebase Crashlytics
    try {
      FirebaseCrashlytics.instance.setCustomKey('error_type', 'provider_error');
      FirebaseCrashlytics.instance
          .setCustomKey('provider_context', context ?? 'unknown');
      FirebaseCrashlytics.instance
          .setCustomKey('provider_class', runtimeType.toString());

      FirebaseCrashlytics.instance.recordError(
        error,
        StackTrace.current,
        reason: 'Provider error in $context',
      );
    } catch (e) {
      print('Failed to log provider error to Crashlytics: $e');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/const.dart';
import 'dart:async';
// Removed unused import
import 'error_handler.dart';
import '../widgets/error_handler_widget.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Global error handler for the application
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  /// Initialize global error handling
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack,
          context: 'Flutter Framework Error');
    };

    // Handle async errors
    WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
      _logError(error, stack, context: 'Platform Error');
      return true;
    };
  }

  /// Wrap app execution with error handling
  static void runAppWithErrorHandling(VoidCallback appRunner) {
    runZonedGuarded(
      appRunner,
      (error, stack) {
        _logError(error, stack, context: 'Unhandled Async Error');
      },
    );
  }

  /// Log error with context
  static void _logError(dynamic error, StackTrace? stack, {String? context}) {
    ErrorHandler.logError(error, stack, context: context);

    // In production, you would send this to a logging service
    // Example: Firebase Crashlytics, Sentry, etc.
    _sendToLoggingService(error, stack, context);
  }

  /// Send error to logging service (implement based on your logging service)
  static void _sendToLoggingService(
      dynamic error, StackTrace? stack, String? context) {
    try {
      // Set custom keys for better error tracking
      FirebaseCrashlytics.instance
          .setCustomKey('error_context', context ?? 'unknown');
      FirebaseCrashlytics.instance
          .setCustomKey('error_source', 'global_handler');
      FirebaseCrashlytics.instance
          .setCustomKey('error_timestamp', DateTime.now().toIso8601String());

      // Record the error with stack trace
      FirebaseCrashlytics.instance.recordError(
        error,
        stack,
        reason: context ?? 'Unhandled error',
      );

      // Also log to console for debugging
      debugPrint('=== GLOBAL ERROR LOGGED TO CRASHLYTICS ===');
      debugPrint('Context: $context');
      debugPrint('Error: $error');
      debugPrint('==========================================');
    } catch (e) {
      // Fallback if Crashlytics is not available
      debugPrint('Failed to log to Crashlytics: $e');
      debugPrint('=== GLOBAL ERROR (FALLBACK) ===');
      debugPrint('Context: $context');
      debugPrint('Error: $error');
      debugPrint('StackTrace: $stack');
      debugPrint('================================');
    }
  }

  /// Show global error dialog with retry option
  static Future<bool> showErrorDialog(
      BuildContext context, String title, String message,
      {VoidCallback? onRetry}) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message),
                  if (onRetry != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Would you like to retry?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
              actions: [
                if (onRetry != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Cancel'),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    if (onRetry != null) {
                      onRetry();
                    }
                  },
                  child: Text(onRetry != null ? 'Retry' : 'OK'),
                ),
              ],
            );
          },
        ) ??
        false;
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

  /// Handle critical errors that require app restart
  static Future<bool> handleCriticalError(
      BuildContext context, String error) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Critical Error'),
              content: Text(
                  'A critical error occurred: $error\n\nThe app needs to restart.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                  child: const Text('Restart App'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

/// Error boundary widget to catch widget errors
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(String error)? errorBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  String? _error;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception.toString();
      });
      return widget.errorBuilder?.call(_error!) ??
          ErrorHandlerWidget(
            error: _error!,
            onRetry: () {
              setState(() {
                _error = null;
              });
            },
          );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!) ??
          ErrorHandlerWidget(
            error: _error!,
            onRetry: () {
              setState(() {
                _error = null;
              });
            },
          );
    }
    return widget.child;
  }
}

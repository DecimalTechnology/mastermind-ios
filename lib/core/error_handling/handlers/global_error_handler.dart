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
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: kPrimaryColor,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              try {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              } catch (e) {
                debugPrint('Could not hide snackbar: $e');
              }
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('Could not show error snackbar: $message - $e');
    }
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
/// This implementation avoids calling setState during build phase
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
  @override
  void initState() {
    super.initState();
    // Set up a simple error widget builder that doesn't rely on state
    ErrorWidget.builder = (FlutterErrorDetails details) {
      // Log the error but don't try to setState during build
      debugPrint('ErrorBoundary caught error: ${details.exception}');

      // Return a simple error widget wrapped with Directionality for CupertinoApp compatibility
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          color: Colors.white,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    details.exception.toString().length > 100
                        ? '${details.exception.toString().substring(0, 100)}...'
                        : details.exception.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

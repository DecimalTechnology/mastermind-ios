import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/utils/platform_utils.dart';

/// Widget for displaying error states with retry functionality
/// Platform-independent - works with both MaterialApp and CupertinoApp
class ErrorHandlerWidget extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  final String? retryText;
  final String? title;
  final IconData? icon;

  const ErrorHandlerWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.title = 'Error',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap with Directionality to ensure Material widgets work in CupertinoApp
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  _buildRetryButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    if (PlatformUtils.isIOS) {
      return CupertinoButton.filled(
        onPressed: onRetry,
        child: Text(retryText!),
      );
    }
    return ElevatedButton(
      onPressed: onRetry,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 12,
        ),
      ),
      child: Text(retryText!),
    );
  }
}

/// Loading widget for displaying loading states
/// Platform-independent - works with both MaterialApp and CupertinoApp
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message = 'Loading...',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlatformUtils.isIOS
                  ? CupertinoActivityIndicator(
                      radius: 16,
                      color: color ?? kPrimaryColor,
                    )
                  : CircularProgressIndicator(
                      color: color ?? kPrimaryColor,
                    ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 16,
                    color: color ?? Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget for displaying when no data is available
/// Platform-independent - works with both MaterialApp and CupertinoApp
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                if (onAction != null && actionText != null) ...[
                  const SizedBox(height: 24),
                  _buildActionButton(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (PlatformUtils.isIOS) {
      return CupertinoButton.filled(
        onPressed: onAction,
        child: Text(actionText!),
      );
    }
    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 12,
        ),
      ),
      child: Text(actionText!),
    );
  }
}

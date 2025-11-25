import 'package:flutter/material.dart';
// Removed unused import

/// Reusable error display widget
class ErrorHandlerWidget extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;
  final String? title;
  final String? subtitle;
  final bool showRetryButton;

  const ErrorHandlerWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.retryText = 'Retry',
    this.icon = Icons.error_outline,
    this.title,
    this.subtitle,
    this.showRetryButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              title ?? 'Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            if (showRetryButton && onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading widget with optional message
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 32,
            height: size ?? 32,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionText != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// State-aware widget that handles loading, error, and empty states
class StateAwareWidget<T> extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final T? data;
  final bool isEmpty;
  final Widget Function(T data) onData;
  final Widget Function()? onLoading;
  final Widget Function(String error)? onError;
  final Widget Function()? onEmpty;
  final VoidCallback? onRetry;
  final String? loadingMessage;
  final String? emptyTitle;
  final String? emptySubtitle;
  final IconData? emptyIcon;

  const StateAwareWidget({
    super.key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.isEmpty,
    required this.onData,
    this.onLoading,
    this.onError,
    this.onEmpty,
    this.onRetry,
    this.loadingMessage,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoading) {
      return onLoading?.call() ?? LoadingWidget(message: loadingMessage);
    }

    // Show error state
    if (error != null && error!.isNotEmpty) {
      return onError?.call(error!) ??
          ErrorHandlerWidget(
            error: error,
            onRetry: onRetry,
          );
    }

    // Show empty state
    if (isEmpty) {
      return onEmpty?.call() ??
          EmptyStateWidget(
            title: emptyTitle ?? 'No data available',
            subtitle: emptySubtitle,
            icon: emptyIcon,
          );
    }

    // Show data
    if (data != null) {
      return onData(data!);
    }

    // Fallback empty state
    return const EmptyStateWidget(
      title: 'No data available',
    );
  }
}

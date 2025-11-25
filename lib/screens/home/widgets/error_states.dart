import 'package:flutter/material.dart';
import 'package:master_mind/utils/const.dart';
import 'package:master_mind/widgets/common_styles.dart';

class ErrorStates {
  static Widget buildReloginMessage({
    required String? error,
    required VoidCallback onRelogin,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(kPaddingLarge),
        padding: const EdgeInsets.all(kPaddingLarge),
        decoration: BoxDecoration(
          color: kWarningColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(kBorderRadiusLarge),
          border: Border.all(color: kWarningColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, size: 48, color: kWarningColor),
            const SizedBox(height: kPaddingMedium),
            Text('Session Expired',
                style: kSubheadingTextStyle.copyWith(color: kWarningColor)),
            const SizedBox(height: kPaddingSmall),
            Text(
              error ??
                  'Your session has expired. Please login again to continue.',
              textAlign: TextAlign.center,
              style: kCaptionTextStyle.copyWith(color: kWarningColor),
            ),
            const SizedBox(height: kPaddingLarge),
            CommonStyles.primaryButton(
              text: 'Login Again',
              onPressed: onRelogin,
              icon: Icons.login,
            ),
            const SizedBox(height: kPaddingMedium),
            CommonStyles.secondaryButton(
              text: 'Retry',
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildLocalErrorState({
    required String error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          CommonStyles.primaryButton(
            text: 'Retry',
            onPressed: onRetry,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  static Widget buildNetworkErrorState({
    required String errorMessage,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Connection Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CommonStyles.secondaryButton(
              text: 'Retry',
              onPressed: onRetry,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }
}

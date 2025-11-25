import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Platform detection utilities
class PlatformUtils {
  /// Check if running on iOS
  static bool get isIOS {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// Check if running on Android
  static bool get isAndroid {
    if (kIsWeb) return false;
    return Platform.isAndroid;
  }

  /// Check if running on mobile (iOS or Android)
  static bool get isMobile => isIOS || isAndroid;

  /// Get platform-specific text style
  static TextStyle get platformTextStyle {
    if (isIOS) {
      return const TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
      );
    }
    return const TextStyle(
      fontFamily: 'Roboto',
      fontSize: 16,
    );
  }

  /// Get platform-specific button style (Material only)
  static ButtonStyle get platformButtonStyle {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }
}

/// Platform-aware widget builder
typedef PlatformWidgetBuilder<T> = T Function(BuildContext context);

/// Build platform-specific widgets
class PlatformWidget {
  /// Build platform-aware scaffold
  static Widget scaffold({
    required BuildContext context,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? drawer,
    Widget? floatingActionButton,
    Widget? bottomNavigationBar,
    Color? backgroundColor,
    bool resizeToAvoidBottomInset = true,
  }) {
    if (PlatformUtils.isIOS) {
      Widget content = body ?? const SizedBox.shrink();

      // Wrap with floating action button if provided
      if (floatingActionButton != null) {
        content = Stack(
          children: [
            content,
            Positioned(
              right: 16,
              bottom: bottomNavigationBar != null ? 80 : 16,
              child: floatingActionButton,
            ),
          ],
        );
      }

      // Wrap with bottom navigation if provided
      if (bottomNavigationBar != null) {
        content = Column(
          children: [
            Expanded(child: content),
            bottomNavigationBar,
          ],
        );
      }

      return CupertinoPageScaffold(
        navigationBar: appBar != null
            ? _convertAppBarToCupertinoNavBar(context, appBar)
            : null,
        child: SafeArea(
          child: content,
        ),
        backgroundColor: backgroundColor ?? CupertinoColors.systemBackground,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: body,
      drawer: drawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }

  /// Convert Material AppBar to CupertinoNavigationBar
  static ObstructingPreferredSizeWidget? _convertAppBarToCupertinoNavBar(
    BuildContext context,
    PreferredSizeWidget appBar,
  ) {
    if (appBar is AppBar) {
      return CupertinoNavigationBar(
        middle: appBar.title is Text
            ? (appBar.title as Text)
            : Text(appBar.title?.toString() ?? ''),
        leading: appBar.leading,
        trailing: appBar.actions != null && appBar.actions!.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: appBar.actions!,
              )
            : null,
        backgroundColor:
            appBar.backgroundColor ?? CupertinoColors.systemBackground,
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.0,
          ),
        ),
      );
    }
    return null;
  }

  /// Build platform-aware button
  static Widget button({
    required VoidCallback? onPressed,
    required Widget child,
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double? minWidth,
    double? height,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        color: backgroundColor ?? CupertinoColors.activeBlue,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        minSize: minWidth,
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? CupertinoColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
          child: child,
        ),
      );
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        minimumSize: minWidth != null ? Size(minWidth, height ?? 48) : null,
      ),
      child: child,
    );
  }

  /// Build platform-aware text button
  static Widget textButton({
    required VoidCallback? onPressed,
    required Widget child,
    Color? foregroundColor,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: DefaultTextStyle(
          style: TextStyle(
            color: foregroundColor ?? CupertinoColors.activeBlue,
            fontSize: 17,
          ),
          child: child,
        ),
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
      ),
      child: child,
    );
  }

  /// Build platform-aware dialog
  static Future<T?> showPlatformDialog<T>({
    required BuildContext context,
    required String title,
    required String content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    if (PlatformUtils.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions ??
              [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
        ),
      );
    }
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions ??
            [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
      ),
    );
  }

  /// Build platform-aware loading indicator
  static Widget loadingIndicator({
    Color? color,
    double? size,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoActivityIndicator(
        radius: (size ?? 20) / 2,
        color: color ?? CupertinoColors.activeBlue,
      );
    }
    return SizedBox(
      width: size ?? 40,
      height: size ?? 40,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
      ),
    );
  }

  /// Build platform-aware text field
  static Widget textField({
    TextEditingController? controller,
    String? placeholder,
    String? hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefixIcon,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    int? maxLines,
    EdgeInsetsGeometry? padding,
  }) {
    if (PlatformUtils.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? hintText,
        obscureText: obscureText,
        keyboardType: keyboardType,
        padding: padding ?? const EdgeInsets.all(12),
        prefix: prefixIcon,
        suffix: suffixIcon,
        onChanged: onChanged,
        maxLines: maxLines,
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText ?? placeholder,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}

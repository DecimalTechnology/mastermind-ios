import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';

/// Platform-aware button widget
class PlatformButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? minWidth;
  final double? height;
  final bool isLoading;

  const PlatformButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.minWidth,
    this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        onPressed: isLoading ? null : onPressed,
        color: backgroundColor ?? CupertinoColors.activeBlue,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        minSize: minWidth,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  radius: 10,
                  color: foregroundColor ?? CupertinoColors.white,
                ),
              )
            : DefaultTextStyle(
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
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        minimumSize: minWidth != null ? Size(minWidth!, height ?? 48) : null,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  foregroundColor ?? Colors.white,
                ),
              ),
            )
          : child,
    );
  }
}

/// Platform-aware text button widget
class PlatformTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? foregroundColor;

  const PlatformTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
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
}

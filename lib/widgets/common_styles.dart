import 'package:flutter/material.dart';
import 'package:master_mind/utils/const.dart';

class CommonStyles {
  // Common container with gradient background
  static Widget gradientContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            kPrimaryColor.withValues(alpha: 0.1),
            Colors.white,
          ],
        ),
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  // Common card with consistent styling
  static Widget styledCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? backgroundColor,
    double? elevation,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(kPaddingMedium),
      child: Card(
        color: backgroundColor ?? kCardColor,
        elevation: elevation ?? kElevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(kPaddingMedium),
          child: child,
        ),
      ),
    );
  }

  // Common button with primary styling
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    double? width,
    EdgeInsetsGeometry? padding,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : icon != null
                ? Icon(icon)
                : const SizedBox.shrink(),
        label: Text(
          isLoading ? 'Loading...' : text,
          style: kButtonTextStyle,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: kElevationSmall,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: kPaddingLarge,
                vertical: kPaddingMedium,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          ),
        ),
      ),
    );
  }

  // Common secondary button
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon) : const SizedBox.shrink(),
      label: Text(
        text,
        style: TextStyle(
          color: color ?? kPrimaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: kPaddingLarge,
          vertical: kPaddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        ),
      ),
    );
  }

  // Common section header
  static Widget sectionHeader({
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: kPaddingMedium,
        vertical: kPaddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kSubheadingTextStyle,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: kCaptionTextStyle,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // Common list tile with consistent styling
  static Widget styledListTile({
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    IconData? trailingIcon,
    VoidCallback? onTap,
    Color? iconColor,
    bool isActive = false,
  }) {
    return Container(
      margin:
          const EdgeInsets.symmetric(horizontal: kPaddingMedium, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? kPrimaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(kBorderRadiusMedium),
        border: isActive
            ? Border.all(color: kPrimaryColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        leading: leadingIcon != null
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? kPrimaryColor : kLightGreyColor,
                  borderRadius: BorderRadius.circular(kBorderRadiusSmall),
                ),
                child: Icon(
                  leadingIcon,
                  color:
                      isActive ? Colors.white : (iconColor ?? kGreyTextColor),
                  size: 20,
                ),
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? kPrimaryColor : kTextColor,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: kCaptionTextStyle,
              )
            : null,
        trailing: trailingIcon != null
            ? Icon(
                trailingIcon,
                size: 16,
                color: kGreyTextColor,
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: kPaddingMedium,
          vertical: 4,
        ),
      ),
    );
  }

  // Common input field with consistent styling
  static Widget styledTextField({
    required String label,
    String? hint,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: kPrimaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: kPrimaryColor.withValues(alpha: 0.3)),
        ),
        filled: true,
        fillColor: kBackgroundColor,
      ),
    );
  }

  // Common loading indicator
  static Widget loadingIndicator({
    String? message,
    Color? color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color ?? kPrimaryColor),
          ),
          if (message != null) ...[
            const SizedBox(height: kPaddingMedium),
            Text(
              message,
              style: kCaptionTextStyle,
            ),
          ],
        ],
      ),
    );
  }

  // Common empty state widget
  static Widget emptyState({
    required String message,
    IconData? icon,
    Widget? action,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 64,
              color: kGreyTextColor,
            ),
            const SizedBox(height: kPaddingMedium),
          ],
          Text(
            message,
            style: kCaptionTextStyle,
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[
            const SizedBox(height: kPaddingMedium),
            action,
          ],
        ],
      ),
    );
  }

  // Common error state widget
  static Widget errorState({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: kErrorColor,
          ),
          const SizedBox(height: kPaddingMedium),
          Text(
            message,
            style: kCaptionTextStyle.copyWith(color: kErrorColor),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: kPaddingMedium),
            primaryButton(
              text: 'Retry',
              onPressed: onRetry,
              icon: Icons.refresh,
            ),
          ],
        ],
      ),
    );
  }
}

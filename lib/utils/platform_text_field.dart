import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:master_mind/utils/platform_utils.dart';

/// Platform-aware text field widget
class PlatformTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const PlatformTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLines,
    this.padding,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder ?? hintText ?? labelText,
        obscureText: obscureText,
        keyboardType: keyboardType,
        padding: padding ?? const EdgeInsets.all(12),
        prefix: prefixIcon,
        suffix: suffixIcon,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
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
      enabled: enabled,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
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

/// Platform-aware text form field (for use in Forms)
class PlatformTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLines;
  final EdgeInsetsGeometry? padding;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const PlatformTextFormField({
    super.key,
    this.controller,
    this.placeholder,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.maxLines,
    this.padding,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      // For iOS, we'll use a custom implementation that works with Form validation
      return CupertinoTextFormFieldRow(
        controller: controller,
        placeholder: placeholder ?? hintText ?? labelText,
        obscureText: obscureText,
        keyboardType: keyboardType,
        prefix: prefixIcon,
        suffix: suffixIcon,
        onChanged: onChanged,
        validator: validator,
        enabled: enabled,
        textInputAction: textInputAction,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
      );
    }
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      enabled: enabled,
      textInputAction: textInputAction,
      focusNode: focusNode,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
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

/// iOS-specific text form field row (for use in Forms on iOS)
class CupertinoTextFormFieldRow extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;

  const CupertinoTextFormFieldRow({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.keyboardType,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.textInputAction,
    this.focusNode,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
                border: field.hasError
                    ? Border.all(color: CupertinoColors.destructiveRed)
                    : null,
              ),
              child: CupertinoTextField(
                controller: controller,
                placeholder: placeholder,
                obscureText: obscureText,
                keyboardType: keyboardType,
                prefix: prefix,
                suffix: suffix,
                onChanged: (value) {
                  field.didChange(value);
                  onChanged?.call(value);
                },
                enabled: enabled,
                textInputAction: textInputAction,
                focusNode: focusNode,
                onSubmitted: onSubmitted,
                decoration: const BoxDecoration(),
                padding: const EdgeInsets.all(12),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(
                    color: CupertinoColors.destructiveRed,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

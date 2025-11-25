import 'package:flutter/material.dart';
import '../core/error_handling/exceptions/app_exceptions.dart';

/// Comprehensive form validation service
class FormValidationService {
  static final FormValidationService _instance =
      FormValidationService._internal();
  factory FormValidationService() => _instance;
  FormValidationService._internal();

  // ===== INPUT VALIDATION =====

  /// Validate email address
  static String? validateEmail(String? email, {String? fieldName}) {
    if (email == null || email.trim().isEmpty) {
      return '${fieldName ?? 'Email'} is required';
    }

    final sanitizedEmail = ComprehensiveExceptionHandler.sanitizeInput(email);
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

    if (!emailRegex.hasMatch(sanitizedEmail)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? phone, {String? fieldName}) {
    if (phone == null || phone.trim().isEmpty) {
      return '${fieldName ?? 'Phone number'} is required';
    }

    final sanitizedPhone = ComprehensiveExceptionHandler.sanitizeInput(phone);
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');

    if (!phoneRegex.hasMatch(sanitizedPhone)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? password, {String? fieldName}) {
    if (password == null || password.isEmpty) {
      return '${fieldName ?? 'Password'} is required';
    }

    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(
      String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Please confirm your password';
    }

    if (password != confirmation) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validate name fields
  static String? validateName(String? name, {String? fieldName}) {
    if (name == null || name.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }

    final sanitizedName = ComprehensiveExceptionHandler.sanitizeInput(name);

    if (sanitizedName.length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters long';
    }

    if (sanitizedName.length > 50) {
      return '${fieldName ?? 'Name'} must be less than 50 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp('^[a-zA-Z\\s\\-\\' ']+\$');
    if (!nameRegex.hasMatch(sanitizedName)) {
      return '${fieldName ?? 'Name'} contains invalid characters';
    }

    return null;
  }

  /// Validate required fields
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength,
      {String? fieldName}) {
    if (value == null || value.trim().length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters long';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength,
      {String? fieldName}) {
    if (value != null && value.trim().length > maxLength) {
      return '${fieldName ?? 'This field'} must be less than $maxLength characters';
    }
    return null;
  }

  /// Validate numeric input
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return '${fieldName ?? 'This field'} must contain only numbers';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? url, {String? fieldName}) {
    if (url == null || url.trim().isEmpty) {
      return '${fieldName ?? 'URL'} is required';
    }

    final sanitizedUrl = ComprehensiveExceptionHandler.sanitizeInput(url);
    final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');

    if (!urlRegex.hasMatch(sanitizedUrl)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validate date
  static String? validateDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    final now = DateTime.now();
    if (date.isAfter(now)) {
      return '${fieldName ?? 'Date'} cannot be in the future';
    }

    return null;
  }

  /// Validate age (minimum age requirement)
  static String? validateAge(DateTime? birthDate,
      {int minAge = 18, String? fieldName}) {
    if (birthDate == null) {
      return '${fieldName ?? 'Birth date'} is required';
    }

    final now = DateTime.now();
    final age = now.year - birthDate.year;

    if (age < minAge) {
      return 'You must be at least $minAge years old';
    }

    return null;
  }

  // ===== FORM VALIDATION =====

  /// Validate entire form
  static Map<String, String?> validateForm(
      Map<String, String?> formData, Map<String, Function> validators) {
    final errors = <String, String?>{};

    for (final entry in validators.entries) {
      final fieldName = entry.key;
      final validator = entry.value;
      final value = formData[fieldName];

      try {
        final error = validator(value);
        if (error != null) {
          errors[fieldName] = error;
        }
      } catch (e) {
        errors[fieldName] = 'Validation error occurred';
        print('Form validation error for $fieldName: $e');
      }
    }

    return errors;
  }

  /// Check if form is valid
  static bool isFormValid(Map<String, String?> errors) {
    return errors.values.every((error) => error == null);
  }

  /// Get first error message
  static String? getFirstError(Map<String, String?> errors) {
    for (final error in errors.values) {
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  // ===== REAL-TIME VALIDATION =====

  /// Create real-time validator
  static String? Function(String?) createRealTimeValidator(
    String? Function(String?) validator, {
    String? fieldName,
  }) {
    return (String? value) {
      try {
        return validator(value);
      } catch (e) {
        print('Real-time validation error for $fieldName: $e');
        return 'Validation error occurred';
      }
    };
  }

  // ===== CUSTOM VALIDATORS =====

  /// Create custom validator
  static String? Function(String?) createCustomValidator({
    required bool Function(String?) condition,
    required String errorMessage,
  }) {
    return (String? value) {
      if (value == null || !condition(value)) {
        return errorMessage;
      }
      return null;
    };
  }

  /// Validate file upload
  static String? validateFileUpload(
    String? filePath, {
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
    int maxSizeMB = 10,
  }) {
    if (filePath == null || filePath.isEmpty) {
      return 'Please select a file';
    }

    // Check file extension
    final extension = filePath.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'File type not supported. Allowed types: ${allowedExtensions.join(', ')}';
    }

    // Check file size (basic check - actual size should be checked when file is selected)
    // This is a placeholder for file size validation
    return null;
  }

  /// Validate image dimensions
  static String? validateImageDimensions({
    int? width,
    int? height,
    int minWidth = 100,
    int minHeight = 100,
    int maxWidth = 5000,
    int maxHeight = 5000,
  }) {
    if (width != null && (width < minWidth || width > maxWidth)) {
      return 'Image width must be between $minWidth and $maxWidth pixels';
    }

    if (height != null && (height < minHeight || height > maxHeight)) {
      return 'Image height must be between $minHeight and $maxHeight pixels';
    }

    return null;
  }

  // ===== VALIDATION HELPERS =====

  /// Sanitize input for validation
  static String sanitizeInput(String? input) {
    return ComprehensiveExceptionHandler.sanitizeInput(input);
  }

  /// Remove special characters
  static String removeSpecialCharacters(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '');
  }

  /// Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format based on length
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    } else if (digits.length == 11 && digits.startsWith('1')) {
      return '+1 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7)}';
    }

    return phone; // Return original if can't format
  }

  /// Format credit card number
  static String formatCreditCard(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length == 16) {
      return '${digits.substring(0, 4)} ${digits.substring(4, 8)} ${digits.substring(8, 12)} ${digits.substring(12)}';
    }
    return cardNumber;
  }

  // ===== VALIDATION WIDGETS =====

  /// Create validation text field
  static Widget createValidationTextField({
    required TextEditingController controller,
    required String? Function(String?) validator,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefix,
    Widget? suffix,
    int? maxLines,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        errorMaxLines: 2,
        prefixIcon: prefix,
        suffixIcon: suffix,
      ),
    );
  }
}

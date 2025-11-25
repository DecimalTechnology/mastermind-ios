import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Centralized color palette
const Color kPrimaryColor = Color(0xFF4A194D); // buttonColor
const Color kBackgroundColor = Colors.white;
const Color kAccentColor = Color(0xFFEDE7F6);
const Color kErrorColor = Colors.red;
const Color kTextColor = Colors.black87;
const Color kGreyTextColor = Color(0xFF757575);
const Color kCardColor = Colors.white;
const Color kShadowColor = Colors.black12;
const Color kAppBarIconColor = kPrimaryColor;
const Color kAppBarTextColor = kPrimaryColor;

// Additional color constants for uniformity
const Color kSuccessColor = Color(0xFF4CAF50);
const Color kWarningColor = Color(0xFFFF9800);
const Color kInfoColor = Color(0xFF2196F3);
const Color kLightGreyColor = Color(0xFFF5F5F5);
const Color kMediumGreyColor = Color(0xFFE0E0E0);
const Color kDarkGreyColor = Color(0xFF424242);

// Gradient colors
const Color kGradientStartColor = kPrimaryColor;
const Color kGradientEndColor = Color(0xFF6A1B9A);

// Status colors
const Color kActiveColor = Color(0xFF4CAF50);
const Color kInactiveColor = Color(0xFF9E9E9E);
const Color kPendingColor = Color(0xFFFF9800);

const buttonColor = kPrimaryColor;

const TextStyle appBarTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: kAppBarTextColor,
);

// Additional text styles for consistency
const TextStyle kHeadingTextStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: kTextColor,
);

const TextStyle kSubheadingTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kTextColor,
);

const TextStyle kBodyTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.normal,
  color: kTextColor,
);

const TextStyle kCaptionTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: kGreyTextColor,
);

const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

// Border radius constants
const double kBorderRadiusSmall = 8.0;
const double kBorderRadiusMedium = 12.0;
const double kBorderRadiusLarge = 16.0;

// Padding constants
const double kPaddingSmall = 8.0;
const double kPaddingMedium = 16.0;
const double kPaddingLarge = 24.0;

// Elevation constants
const double kElevationSmall = 2.0;
const double kElevationMedium = 4.0;
const double kElevationLarge = 8.0;

// final baseurl = 'http://175.1.1.47:3000'; //adarsh
// final baseurl = 'http://175.1.1.95:3000'; //sebastian
final baseurl = 'http://15.207.109.75:3000'; //Aws

// Brand Colors
const Color kOxygenMMPurple = Color(0xFF4D194B);
const Color kAccentPurple = Color(0xFF9131BD);
const Color kBlack = Color(0xFF131313);
const Color kGrey = Color(0xFFE6E6EA);
const Color kWhite = Color(0xFFFFFFFF);
const Color kLightPink = Color(0xFFE79F6B);
const Color kYellow = Color(0xFFFFFF25);
const Color kBlue = Color(0xFF093871);
const Color kLightBlue = Color(0xFF041F4D);
const Color kRed = Color(0xFFD51B49);
const Color kDarkGrey = Color(0xFF515150);

// Number formatting utilities
class NumberFormatter {
  static final NumberFormat _numberFormat = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _integerFormat = NumberFormat('#,##0', 'en_US');

  /// Format a number with commas in international format (e.g., 1,234.56)
  static String formatNumber(double number) {
    return _numberFormat.format(number);
  }

  /// Format an integer with commas in international format (e.g., 1,234)
  static String formatInteger(int number) {
    return _integerFormat.format(number);
  }

  /// Parse a formatted number string back to double
  static double parseNumber(String formattedNumber) {
    // Remove commas and parse
    String cleanNumber = formattedNumber.replaceAll(',', '');
    return double.tryParse(cleanNumber) ?? 0.0;
  }

  /// Parse a formatted integer string back to int
  static int parseInteger(String formattedNumber) {
    // Remove commas and parse
    String cleanNumber = formattedNumber.replaceAll(',', '');
    return int.tryParse(cleanNumber) ?? 0;
  }
}

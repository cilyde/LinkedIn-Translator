import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Cupertino Color System for LinkedIn Translator
/// Follows iOS Human Interface Guidelines
class AppColors {
  // Primary Brand Colors
  static const Color primaryBlue = Color(0xFF0A66C2);
  static const Color primaryBlueLight = Color(0xFF0B7ADB);
  static const Color primaryBlueDark = Color(0xFF094FA3);

  // Accent Colors
  static const Color accentGreen = Color(0xFF06A94F);
  static const Color accentOrange = Color(0xFFFF8C00);
  static const Color accentRed = Color(0xFFE53935);

  // Backgrounds - Light Mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSecondaryBackground = Color(0xFFF9FAFB);
  static const Color lightTertiaryBackground = Color(0xFFF3F6F9);
  static const Color lightGroupedBackground = Color(0xFFEEF4FD);

  // Backgrounds - Dark Mode
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSecondaryBackground = Color(0xFF1C1C1E);
  static const Color darkTertiaryBackground = Color(0xFF2C2C2E);
  static const Color darkGroupedBackground = Color(0xFF1A2332);

  // Text Colors - Light Mode
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF667085);
  static const Color lightTextTertiary = Color(0xFFA0A9B8);
  static const Color lightTextDisabled = Color(0xFFD0D5DD);

  // Text Colors - Dark Mode
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFD0D5DD);
  static const Color darkTextTertiary = Color(0xFF8892A0);
  static const Color darkTextDisabled = Color(0xFF595960);

  // Borders & Separators
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF3A3A3C);

  // Success, Warning, Error
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // Glass Effect (Vibrancy)
  static const Color glassLight = Color(0xF0FFFFFF);
  static const Color glassDark = Color(0xF01C1C1E);

  // Static method for theme-aware colors
  static Color textPrimary(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  static Color textTertiary(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkTextTertiary
        : lightTextTertiary;
  }

  static Color background(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }

  static Color secondaryBackground(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkSecondaryBackground
        : lightSecondaryBackground;
  }

  static Color groupedBackground(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkGroupedBackground
        : lightGroupedBackground;
  }

  static Color border(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }
}

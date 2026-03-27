import 'package:flutter/material.dart';

/// Typography scale following iOS Human Interface Guidelines
class AppTypography {
  // Font Family
  static const String fontFamily = '.SF Pro Display';

  // Large Title: 34pt, bold, line height 41pt
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    height: 1.206,
    letterSpacing: 0.25,
  );

  // Title 1: 28pt, bold, line height 34pt
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.214,
    letterSpacing: 0.25,
  );

  // Title 2: 22pt, bold, line height 28pt
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    height: 1.273,
    letterSpacing: 0.25,
  );

  // Title 3: 20pt, semibold, line height 24pt
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.25,
  );

  // Headline: 17pt, semibold, line height 22pt
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.294,
    letterSpacing: -0.41,
  );

  // Body: 17pt, regular, line height 22pt
  static const TextStyle body = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.294,
    letterSpacing: -0.41,
  );

  // Callout: 16pt, regular, line height 21pt
  static const TextStyle callout = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3125,
    letterSpacing: -0.32,
  );

  // Subheadline: 15pt, regular, line height 20pt
  static const TextStyle subheadline = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.333,
    letterSpacing: -0.24,
  );

  // Footnote: 13pt, regular, line height 18pt
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.385,
    letterSpacing: -0.08,
  );

  // Caption 1: 12pt, regular, line height 16pt
  static const TextStyle caption1 = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.333,
    letterSpacing: 0,
  );

  // Caption 2: 11pt, regular, line height 13pt
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.182,
    letterSpacing: 0.06,
  );
}

/// Semantic typography utilities
extension TextStyleX on TextStyle {
  TextStyle withColor(Color color) => copyWith(color: color);

  TextStyle withWeight(FontWeight weight) => copyWith(fontWeight: weight);

  TextStyle withSize(double size) => copyWith(fontSize: size);
}

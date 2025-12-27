import 'package:flutter/material.dart';

/// Modern, vibrant color palette for Todo Social app
class AppColors {
  // Primary gradient colors (Instagram-inspired)
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryBlue = Color(0xFF4FACFE);
  static const Color primaryPink = Color(0xFFFF6B9D);

  // Gradient combinations
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPurple, primaryBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryPink, Color(0xFFFFA06B)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );

  // Main colors
  static const Color primary = primaryPurple;
  static const Color secondary = primaryBlue;
  static const Color accent = primaryPink;

  // Status colors
  static const Color success = Color(0xFF38EF7D);
  static const Color error = Color(0xFFFF6B9D);
  static const Color warning = Color(0xFFFFA06B);
  static const Color info = Color(0xFF4FACFE);

  // Neutral colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textDisabled = Color(0xFFB2BEC3);

  // Border and divider
  static const Color border = Color(0xFFDFE6E9);
  static const Color divider = Color(0xFFECF0F1);

  // Social media colors
  static const Color like = Color(0xFFFF3B5C);
  static const Color share = Color(0xFF4FACFE);
  static const Color comment = Color(0xFF95A5A6);
}

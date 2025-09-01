import 'package:flutter/material.dart';

/// Color tokens for BulletDroid
class GeistColors {
  // Base neutral colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F4);
  static const Color gray200 = Color(0xFFE1E1E1);
  static const Color gray300 = Color(0xFFCCCCCC);
  static const Color gray400 = Color(0xFF999999);
  static const Color gray500 = Color(0xFF666666);
  static const Color gray600 = Color(0xFF333333);
  static const Color gray700 = Color(0xFF1A1A1A);
  static const Color gray800 = Color(0xFF0A0A0A);

  // Technical accent colors
  static const Color terminalGreen = Color(0xFF00FF00);
  static const Color amber = Color(0xFFFFB000);
  static const Color red = Color(0xFFFF0000);
  static const Color blue = Color(0xFF0070F3);
  static const Color transparent = Color(0x00000000);

  // Light theme colors
  static const Color lightBackground = white;
  static const Color lightSurface = gray50;
  static const Color lightBorder = gray200;
  static const Color lightTextPrimary = black;
  static const Color lightTextSecondary = gray500;
  static const Color lightTextTertiary = gray400;

  // Semantic colors for technical states
  static const Color successColor = terminalGreen;
  static const Color warningColor = amber;
  static const Color errorColor = red;
  static const Color infoColor = blue;

  // State colors with opacity variants
  static Color successColorSubtle = terminalGreen.withValues(alpha: 0.1);
  static Color warningColorSubtle = amber.withValues(alpha: 0.1);
  static Color errorColorSubtle = red.withValues(alpha: 0.1);
  static Color infoColorSubtle = blue.withValues(alpha: 0.1);
}

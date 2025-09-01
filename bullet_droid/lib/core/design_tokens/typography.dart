import 'package:flutter/material.dart';

/// Typography tokens for BulletDroid
class GeistTypography {
  // Font families
  static const String geistSans = 'Geist';
  static const String geistMono = 'GeistMono';
  
  // Mobile-first typography scale
  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double base = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  
  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  
  // Line heights optimized for information density
  static const double tightLineHeight = 1.2;
  static const double normalLineHeight = 1.4;
  static const double relaxedLineHeight = 1.6;
  
  // Display text styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: geistSans,
    fontSize: xxl,
    fontWeight: bold,
    height: tightLineHeight,
    letterSpacing: -0.5,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: geistSans,
    fontSize: xl,
    fontWeight: semiBold,
    height: tightLineHeight,
    letterSpacing: -0.25,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: geistSans,
    fontSize: lg,
    fontWeight: semiBold,
    height: normalLineHeight,
  );
  
  // Heading text styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: geistSans,
    fontSize: lg,
    fontWeight: medium,
    height: tightLineHeight,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontFamily: geistSans,
    fontSize: base,
    fontWeight: medium,
    height: normalLineHeight,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontFamily: geistSans,
    fontSize: sm,
    fontWeight: medium,
    height: normalLineHeight,
  );
  
  // Body text styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: geistSans,
    fontSize: base,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: geistSans,
    fontSize: sm,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: geistSans,
    fontSize: xs,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  // Technical/monospace text styles
  static const TextStyle codeLarge = TextStyle(
    fontFamily: geistMono,
    fontSize: base,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  static const TextStyle codeMedium = TextStyle(
    fontFamily: geistMono,
    fontSize: sm,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  static const TextStyle codeSmall = TextStyle(
    fontFamily: geistMono,
    fontSize: xs,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  // Label text styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: geistSans,
    fontSize: sm,
    fontWeight: medium,
    height: normalLineHeight,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: geistSans,
    fontSize: xs,
    fontWeight: medium,
    height: normalLineHeight,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: geistSans,
    fontSize: xs,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  // Caption text styles
  static const TextStyle caption = TextStyle(
    fontFamily: geistSans,
    fontSize: xs,
    fontWeight: regular,
    height: normalLineHeight,
  );
  
  // Button text styles
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: geistSans,
    fontSize: base,
    fontWeight: medium,
    height: normalLineHeight,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: geistSans,
    fontSize: sm,
    fontWeight: medium,
    height: normalLineHeight,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: geistSans,
    fontSize: xs,
    fontWeight: medium,
    height: normalLineHeight,
  );
} 
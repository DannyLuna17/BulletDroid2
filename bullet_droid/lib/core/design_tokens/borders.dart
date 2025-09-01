import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';

/// Border tokens
class GeistBorders {
  // Border radius tokens
  static const double radiusSmall = 2.0;
  static const double radiusMedium = 4.0;
  static const double radiusLarge = 8.0;

  // Border width tokens
  static const double widthThin = 1.0;
  static const double widthMedium = 2.0;
  static const double widthThick = 3.0;

  // Border styles for light theme
  static const BorderSide lightBorder = BorderSide(
    color: GeistColors.lightBorder,
    width: widthThin,
  );

  static const BorderSide lightBorderMedium = BorderSide(
    color: GeistColors.lightBorder,
    width: widthMedium,
  );

  static const BorderSide lightBorderFocus = BorderSide(
    color: GeistColors.blue,
    width: widthMedium,
  );

  static const BorderSide lightBorderError = BorderSide(
    color: GeistColors.errorColor,
    width: widthThin,
  );

  // Border radius configurations
  static const BorderRadius radiusSmallAll = BorderRadius.all(
    Radius.circular(radiusSmall),
  );

  static const BorderRadius radiusMediumAll = BorderRadius.all(
    Radius.circular(radiusMedium),
  );

  static const BorderRadius radiusLargeAll = BorderRadius.all(
    Radius.circular(radiusLarge),
  );

  // Component-specific border configurations
  static const BorderRadius buttonRadius = radiusMediumAll;
  static const BorderRadius cardRadius = radiusMediumAll;
  static const BorderRadius inputRadius = radiusMediumAll;
  static const BorderRadius tableRadius = radiusSmallAll;
}

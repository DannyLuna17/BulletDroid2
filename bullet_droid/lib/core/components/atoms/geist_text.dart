import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/typography.dart';

enum GeistTextVariant {
  displayLarge,
  displayMedium,
  displaySmall,
  headingLarge,
  headingMedium,
  headingSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
  caption,
  codeLarge,
  codeMedium,
  codeSmall,
}

enum GeistTextColor {
  primary,
  secondary,
  tertiary,
  success,
  warning,
  error,
  info,
  custom,
}

class GeistText extends StatelessWidget {
  final String text;
  final GeistTextVariant variant;
  final GeistTextColor color;
  final Color? customColor;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool selectable;
  final TextDecoration? decoration;
  final FontWeight? fontWeight;
  final double? fontSize;
  final double? letterSpacing;
  final double? height;

  const GeistText(
    this.text, {
    super.key,
    this.variant = GeistTextVariant.bodyMedium,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  });

  // Display variants
  const GeistText.displayLarge(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.displayLarge;

  const GeistText.displayMedium(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.displayMedium;

  const GeistText.displaySmall(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.displaySmall;

  // Heading variants
  const GeistText.headingLarge(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.headingLarge;

  const GeistText.headingMedium(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.headingMedium;

  const GeistText.headingSmall(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.headingSmall;

  // Body variants
  const GeistText.bodyLarge(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.bodyLarge;

  const GeistText.bodyMedium(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.bodyMedium;

  const GeistText.bodySmall(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.bodySmall;

  // Label variants
  const GeistText.labelLarge(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.labelLarge;

  const GeistText.labelMedium(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.labelMedium;

  const GeistText.labelSmall(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.labelSmall;

  // Caption variant
  const GeistText.caption(
    this.text, {
    super.key,
    this.color = GeistTextColor.secondary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = false,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.caption;

  // Monospace variants
  const GeistText.codeLarge(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = true,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.codeLarge;

  const GeistText.codeMedium(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = true,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.codeMedium;

  const GeistText.codeSmall(
    this.text, {
    super.key,
    this.color = GeistTextColor.primary,
    this.customColor,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.selectable = true,
    this.decoration,
    this.fontWeight,
    this.fontSize,
    this.letterSpacing,
    this.height,
  }) : variant = GeistTextVariant.codeSmall;

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();

    if (selectable) {
      return SelectableText(
        text,
        style: textStyle,
        maxLines: maxLines,
        textAlign: textAlign,
      );
    }

    return Text(
      text,
      style: textStyle,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
    );
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle = _getBaseTextStyle();
    Color textColor = _getTextColor();

    return baseStyle.copyWith(
      color: textColor,
      decoration: decoration,
      fontWeight: fontWeight,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      height: height,
    );
  }

  TextStyle _getBaseTextStyle() {
    switch (variant) {
      case GeistTextVariant.displayLarge:
        return GeistTypography.displayLarge;
      case GeistTextVariant.displayMedium:
        return GeistTypography.displayMedium;
      case GeistTextVariant.displaySmall:
        return GeistTypography.displaySmall;
      case GeistTextVariant.headingLarge:
        return GeistTypography.headingLarge;
      case GeistTextVariant.headingMedium:
        return GeistTypography.headingMedium;
      case GeistTextVariant.headingSmall:
        return GeistTypography.headingSmall;
      case GeistTextVariant.bodyLarge:
        return GeistTypography.bodyLarge;
      case GeistTextVariant.bodyMedium:
        return GeistTypography.bodyMedium;
      case GeistTextVariant.bodySmall:
        return GeistTypography.bodySmall;
      case GeistTextVariant.labelLarge:
        return GeistTypography.labelLarge;
      case GeistTextVariant.labelMedium:
        return GeistTypography.labelMedium;
      case GeistTextVariant.labelSmall:
        return GeistTypography.labelSmall;
      case GeistTextVariant.caption:
        return GeistTypography.caption;
      case GeistTextVariant.codeLarge:
        return GeistTypography.codeLarge;
      case GeistTextVariant.codeMedium:
        return GeistTypography.codeMedium;
      case GeistTextVariant.codeSmall:
        return GeistTypography.codeSmall;
    }
  }

  Color _getTextColor() {
    if (customColor != null) {
      return customColor!;
    }

    switch (color) {
      case GeistTextColor.primary:
        return GeistColors.lightTextPrimary;
      case GeistTextColor.secondary:
        return GeistColors.lightTextSecondary;
      case GeistTextColor.tertiary:
        return GeistColors.lightTextTertiary;
      case GeistTextColor.success:
        return GeistColors.successColor;
      case GeistTextColor.warning:
        return GeistColors.warningColor;
      case GeistTextColor.error:
        return GeistColors.errorColor;
      case GeistTextColor.info:
        return GeistColors.infoColor;
      case GeistTextColor.custom:
        return GeistColors.lightTextPrimary;
    }
  }
}

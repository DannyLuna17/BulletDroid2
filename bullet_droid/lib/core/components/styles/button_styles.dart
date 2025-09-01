import 'package:flutter/material.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/design_tokens/typography.dart';

/// Shared style helpers
class GeistButtonStyles {
  /// Geometry
  static double iconSize(GeistButtonSize size, [double? override]) {
    if (override != null) return override;
    switch (size) {
      case GeistButtonSize.small:
        return 14;
      case GeistButtonSize.medium:
        return 16;
      case GeistButtonSize.large:
        return 18;
    }
  }

  static double height(GeistButtonSize size, [double? override]) {
    if (override != null) return override;
    switch (size) {
      case GeistButtonSize.small:
        return 32;
      case GeistButtonSize.medium:
        return GeistSpacing.touchTargetMin;
      case GeistButtonSize.large:
        return GeistSpacing.touchTargetComfortable;
    }
  }

  static EdgeInsets padding(GeistButtonSize size) {
    switch (size) {
      case GeistButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: GeistSpacing.md,
          vertical: GeistSpacing.xs,
        );
      case GeistButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: GeistSpacing.lg,
          vertical: GeistSpacing.sm,
        );
      case GeistButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: GeistSpacing.xl,
          vertical: GeistSpacing.md,
        );
    }
  }

  /// Text style adapts color to background.
  static TextStyle textStyle(
    GeistButtonSize size,
    bool isDisabled,
    Color backgroundColor, {
    double? fontSize,
  }) {
    final TextStyle baseStyle = switch (size) {
      GeistButtonSize.small => GeistTypography.buttonSmall,
      GeistButtonSize.medium => GeistTypography.buttonMedium,
      GeistButtonSize.large => GeistTypography.buttonLarge,
    };

    final Color textColor = isDisabled
        ? GeistColors.gray400
        : _isDarkBackground(backgroundColor)
        ? GeistColors.white
        : GeistColors.black;

    final double resolvedFontSize =
        fontSize ??
        (switch (size) {
          GeistButtonSize.small => 12,
          GeistButtonSize.medium => 12.5,
          GeistButtonSize.large => 16,
        });

    return baseStyle.copyWith(
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: resolvedFontSize,
    );
  }

  /// Icon color mirrors text color rules
  static Color iconColor(bool isDisabled, Color backgroundColor) {
    if (isDisabled) return GeistColors.gray400;
    return _isDarkBackground(backgroundColor)
        ? GeistColors.white
        : GeistColors.black;
  }

  static bool _isDarkBackground(Color color) {
    return color == GeistColors.black || color == GeistColors.gray800;
  }

  static ButtonVisualStyle styleFor(
    GeistButtonVariant variant,
    bool isPressed,
    bool isDisabled,
  ) {
    if (isDisabled) {
      return ButtonVisualStyle(
        backgroundColor: GeistColors.gray200,
        border: Border.all(color: GeistColors.gray300, width: 1.0),
      );
    }

    final Color backgroundColor = isPressed
        ? GeistColors.gray800
        : GeistColors.white;
    final Color borderColor = isPressed
        ? const Color.fromRGBO(120, 120, 120, 1)
        : const Color.fromRGBO(218, 211, 214, 1);

    return ButtonVisualStyle(
      backgroundColor: backgroundColor,
      border: Border.all(color: borderColor, width: 1.2),
    );
  }
}

class ButtonVisualStyle {
  final Color backgroundColor;
  final Border border;

  const ButtonVisualStyle({
    required this.backgroundColor,
    required this.border,
  });
}

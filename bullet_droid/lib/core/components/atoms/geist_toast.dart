import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';

import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';

/// Toast notification variants
enum GeistToastVariant { success, warning, error, info, neutral }

/// Toast positioning options
enum GeistToastPosition { top, center, bottom }

/// Toast action definition
class GeistToastAction {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;

  const GeistToastAction({
    required this.label,
    required this.onPressed,
    this.textColor,
  });
}

/// Toast notification component
class GeistToast extends StatelessWidget {
  final String message;
  final GeistToastVariant variant;
  final Duration duration;
  final List<GeistToastAction>? actions;
  final VoidCallback? onDismiss;
  final bool showIcon;
  final GeistToastPosition position;
  final String? id;

  GeistToast({
    super.key,
    required this.message,
    this.variant = GeistToastVariant.neutral,
    this.duration = const Duration(seconds: 4),
    this.actions,
    this.onDismiss,
    this.showIcon = true,
    this.position = GeistToastPosition.top,
    this.id,
  }) : assert(
         message != '' && message.trim().isNotEmpty,
         'GeistToast.message cannot be empty',
       ),
       assert(!duration.isNegative, 'GeistToast.duration cannot be negative');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(GeistSpacing.md),
        padding: EdgeInsets.all(GeistSpacing.md),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(color: _getBorderColor(), width: 1),
          borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: GeistColors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(_getIcon(), color: _getIconColor(), size: 20),
              SizedBox(width: GeistSpacing.sm),
            ],
            Expanded(
              child: GeistText(
                message,
                variant: GeistTextVariant.bodyMedium,
                color: GeistTextColor.primary,
                customColor: _getTextColor(),
              ),
            ),
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(width: GeistSpacing.sm),
              ...actions!.map((action) => _buildAction(action)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAction(GeistToastAction action) {
    return TextButton(
      onPressed: action.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: action.textColor ?? _getActionColor(),
        padding: EdgeInsets.symmetric(
          horizontal: GeistSpacing.sm,
          vertical: GeistSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: GeistText(
        action.label,
        variant: GeistTextVariant.bodySmall,
        color: GeistTextColor.primary,
        customColor: action.textColor ?? _getActionColor(),
      ),
    );
  }

  Color _getBackgroundColor() {
    return GeistColors.lightSurface;
  }

  Color _getBorderColor() {
    switch (variant) {
      case GeistToastVariant.success:
        return GeistColors.successColor;
      case GeistToastVariant.warning:
        return GeistColors.warningColor;
      case GeistToastVariant.error:
        return GeistColors.errorColor;
      case GeistToastVariant.info:
        return GeistColors.infoColor;
      case GeistToastVariant.neutral:
        return GeistColors.lightBorder;
    }
  }

  Color _getIconColor() {
    switch (variant) {
      case GeistToastVariant.success:
        return GeistColors.successColor;
      case GeistToastVariant.warning:
        return GeistColors.warningColor;
      case GeistToastVariant.error:
        return GeistColors.errorColor;
      case GeistToastVariant.info:
        return GeistColors.infoColor;
      case GeistToastVariant.neutral:
        return GeistColors.lightTextSecondary;
    }
  }

  Color _getTextColor() {
    return GeistColors.lightTextPrimary;
  }

  Color _getActionColor() {
    switch (variant) {
      case GeistToastVariant.success:
        return GeistColors.successColor;
      case GeistToastVariant.warning:
        return GeistColors.warningColor;
      case GeistToastVariant.error:
        return GeistColors.errorColor;
      case GeistToastVariant.info:
        return GeistColors.infoColor;
      case GeistToastVariant.neutral:
        return GeistColors.lightTextPrimary;
    }
  }

  IconData _getIcon() {
    switch (variant) {
      case GeistToastVariant.success:
        return Icons.check_circle_outline;
      case GeistToastVariant.warning:
        return Icons.warning_amber_outlined;
      case GeistToastVariant.error:
        return Icons.error_outline;
      case GeistToastVariant.info:
        return Icons.info_outline;
      case GeistToastVariant.neutral:
        return Icons.notifications_none;
    }
  }
}

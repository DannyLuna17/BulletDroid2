import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/typography.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/styles/button_styles.dart';

/// A specialized confirmation button that manages its own confirmation state.
class GeistConfirmationButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final VoidCallback? onConfirm;
  final bool isDisabled;
  final Widget? icon;
  final bool iconOnRight;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? iconSize;

  // Confirmation state properties
  final String confirmText;
  final Widget? confirmIcon;
  final Color? confirmBackgroundColor;
  final Color? confirmTextColor;

  // External state control
  final bool? isConfirming;
  final VoidCallback? onConfirmationStateChanged;

  const GeistConfirmationButton({
    super.key,
    required this.text,
    this.onPressed,
    this.onConfirm,
    this.isDisabled = false,
    this.icon,
    this.iconOnRight = false,
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
    this.confirmText = 'Confirm',
    this.confirmIcon,
    this.confirmBackgroundColor,
    this.confirmTextColor,
    this.isConfirming,
    this.onConfirmationStateChanged,
  });

  @override
  State<GeistConfirmationButton> createState() =>
      _GeistConfirmationButtonState();
}

class _GeistConfirmationButtonState extends State<GeistConfirmationButton> {
  bool _internalConfirmingState = false;
  final bool _isPressed = false;

  bool get _isConfirming => widget.isConfirming ?? _internalConfirmingState;
  bool get _isInteractive => !widget.isDisabled;

  void _toggleConfirmationState() {
    if (widget.isConfirming != null) {
      widget.onConfirmationStateChanged?.call();
    } else {
      setState(() {
        _internalConfirmingState = !_internalConfirmingState;
      });
    }
  }

  void _handlePress() {
    if (_isConfirming) {
      widget.onConfirm?.call();
      // Reset confirmation state
      if (widget.isConfirming == null) {
        setState(() {
          _internalConfirmingState = false;
        });
      }
    } else {
      _toggleConfirmationState();
      widget.onPressed?.call();
    }
  }

  Widget? _getIcon() {
    if (_isConfirming) {
      return widget.confirmIcon ?? const Icon(Icons.check);
    }
    return widget.icon;
  }

  String _getText() {
    return _isConfirming ? widget.confirmText : widget.text;
  }

  ButtonVisualStyle _getVisual() {
    if (_isConfirming) {
      final bg = widget.confirmBackgroundColor ?? GeistColors.red;
      return ButtonVisualStyle(
        backgroundColor: bg,
        border: Border.all(color: bg, width: 1),
      );
    }
    return GeistButtonStyles.styleFor(
      GeistButtonVariant.filled,
      _isPressed && _isInteractive,
      widget.isDisabled,
    );
  }

  Color _getTextColor() {
    if (_isConfirming) {
      return widget.confirmTextColor ?? GeistColors.white;
    }
    final visual = _getVisual();
    return GeistButtonStyles.iconColor(
      widget.isDisabled,
      visual.backgroundColor,
    );
  }

  Color _getIconColor() {
    if (_isConfirming) {
      return widget.confirmTextColor ?? GeistColors.white;
    }
    final visual = _getVisual();
    return GeistButtonStyles.iconColor(
      widget.isDisabled,
      visual.backgroundColor,
    );
  }

  double _getHeight() {
    return widget.height ?? 44;
  }

  EdgeInsets _getPadding() {
    return const EdgeInsets.symmetric(
      horizontal: GeistSpacing.md,
      vertical: GeistSpacing.sm,
    );
  }

  TextStyle _getTextStyle() {
    return GeistTypography.buttonMedium.copyWith(
      color: _getTextColor(),
      fontWeight: FontWeight.w500,
      fontSize: widget.fontSize ?? 14,
    );
  }

  double _getIconSize() {
    return widget.iconSize ?? 20;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: _getHeight(),
      child: GestureDetector(
        onTap: _isInteractive ? _handlePress : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _getVisual().backgroundColor,
            border: _getVisual().border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: _getPadding(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_getIcon() != null && !widget.iconOnRight) ...[
                  IconTheme(
                    data: IconThemeData(
                      color: _getIconColor(),
                      size: _getIconSize(),
                    ),
                    child: _getIcon()!,
                  ),
                  SizedBox(width: GeistSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    _getText(),
                    style: _getTextStyle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (_getIcon() != null && widget.iconOnRight) ...[
                  SizedBox(width: GeistSpacing.sm),
                  IconTheme(
                    data: IconThemeData(
                      color: _getIconColor(),
                      size: _getIconSize(),
                    ),
                    child: _getIcon()!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/styles/button_styles.dart';

enum GeistButtonVariant { ghost, outline, filled }

enum GeistButtonSize { small, medium, large }

class GeistButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GeistButtonVariant variant;
  final GeistButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool iconOnRight;
  final double? width;
  final double? height;
  final Color fillColor;
  final double? fontSize;
  final double? iconSize;

  const GeistButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = GeistButtonVariant.filled,
    this.size = GeistButtonSize.medium,
    this.fillColor = GeistColors.white,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.iconOnRight = false,
    this.width,
    this.height,
    this.fontSize,
    this.iconSize,
  });

  @override
  State<GeistButton> createState() => _GeistButtonState();
}

class _GeistButtonState extends State<GeistButton> {
  bool _isPressed = false;

  bool get _isInteractive =>
      widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final visual = GeistButtonStyles.styleFor(
      widget.variant,
      _isPressed && _isInteractive,
      widget.isDisabled,
    );
    final textStyle = GeistButtonStyles.textStyle(
      widget.size,
      widget.isDisabled,
      visual.backgroundColor,
      fontSize: widget.fontSize,
    );
    final height = GeistButtonStyles.height(widget.size, widget.height);
    final padding = GeistButtonStyles.padding(widget.size);

    return SizedBox(
      width: widget.width,
      height: height,
      child: GestureDetector(
        onTapDown: _isInteractive
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: _isInteractive
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: _isInteractive
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: _isInteractive ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: visual.backgroundColor,
            border: visual.border,
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: padding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null && !widget.iconOnRight) ...[
                    _buildIcon(),
                    SizedBox(width: GeistSpacing.xs),
                  ],
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          textStyle.color ?? GeistColors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: GeistSpacing.sm),
                  ],
                  Flexible(
                    child: Text(
                      widget.text,
                      style: textStyle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (widget.icon != null && widget.iconOnRight) ...[
                    SizedBox(width: GeistSpacing.sm),
                    _buildIcon(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final visual = GeistButtonStyles.styleFor(
      widget.variant,
      _isPressed && _isInteractive,
      widget.isDisabled,
    );
    final iconColor = GeistButtonStyles.iconColor(
      widget.isDisabled,
      visual.backgroundColor,
    );

    return IconTheme(
      data: IconThemeData(color: iconColor, size: _getIconSize()),
      child: widget.icon!,
    );
  }

  double _getIconSize() {
    return GeistButtonStyles.iconSize(widget.size, widget.iconSize);
  }
}

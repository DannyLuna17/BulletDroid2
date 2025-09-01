import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';

/// Floating action button with scale animation and no splash effect
class GeistFab extends StatefulWidget {
  final VoidCallback? onPressed;

  final Widget child;

  final Color? backgroundColor;

  final Color? foregroundColor;

  final bool isSmall;

  final String? tooltip;

  const GeistFab({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.isSmall = false,
    this.tooltip,
  });

  const GeistFab.small({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  }) : isSmall = true;

  @override
  State<GeistFab> createState() => _GeistFabState();
}

class _GeistFabState extends State<GeistFab> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !_isPressed) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      if (widget.onPressed != null) {
        widget.onPressed!();
      }
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? GeistColors.black;
    final foregroundColor = widget.foregroundColor ?? GeistColors.white;

    final size = widget.isSmall ? 40.0 : 56.0;

    Widget fab = Transform.scale(
      scale: _isPressed ? 0.95 : 1.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: _isPressed ? 100 : 150),
        curve: _isPressed ? Curves.easeOut : Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: foregroundColor,
              size: widget.isSmall ? 18.0 : 24.0,
            ),
            child: widget.child,
          ),
        ),
      ),
    );

    fab = GestureDetector(
      onTapDown: widget.onPressed != null ? _handleTapDown : null,
      onTapUp: widget.onPressed != null ? _handleTapUp : null,
      onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
      child: fab,
    );

    if (widget.tooltip != null) {
      fab = fab;
    }

    return fab;
  }
}

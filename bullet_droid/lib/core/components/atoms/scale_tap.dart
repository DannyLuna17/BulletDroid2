import 'package:flutter/material.dart';

/// Provides a scale animation on press
class ScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double beginScale;
  final double endScale;
  final Duration duration;
  final Curve curve;

  const ScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.beginScale = 1.0,
    this.endScale = 1.15,
    this.duration = const Duration(milliseconds: 100),
    this.curve = Curves.elasticOut,
  });

  @override
  State<ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<ScaleTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, _) {
          return Transform.scale(scale: _scale.value, child: widget.child);
        },
      ),
    );
  }
}

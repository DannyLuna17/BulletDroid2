import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/typography.dart';

/// Status indicator atoms
enum StatusIndicatorState {
  success,
  warning,
  error,
  info,
  running,
  stopped,
  pending,
  neutral,
}

enum StatusIndicatorVariant { dot, badge, pill, inline }

enum StatusIndicatorSize { small, medium, large }

class StatusIndicator extends StatelessWidget {
  final StatusIndicatorState state;
  final StatusIndicatorVariant variant;
  final StatusIndicatorSize size;
  final String? label;
  final bool animate;
  final VoidCallback? onTap;

  const StatusIndicator({
    super.key,
    required this.state,
    this.variant = StatusIndicatorVariant.dot,
    this.size = StatusIndicatorSize.medium,
    this.label,
    this.animate = false,
    this.onTap,
  });

  // Constructors for common states
  const StatusIndicator.success({
    super.key,
    this.variant = StatusIndicatorVariant.dot,
    this.size = StatusIndicatorSize.medium,
    this.label,
    this.animate = false,
    this.onTap,
  }) : state = StatusIndicatorState.success;

  const StatusIndicator.warning({
    super.key,
    this.variant = StatusIndicatorVariant.dot,
    this.size = StatusIndicatorSize.medium,
    this.label,
    this.animate = false,
    this.onTap,
  }) : state = StatusIndicatorState.warning;

  const StatusIndicator.error({
    super.key,
    this.variant = StatusIndicatorVariant.dot,
    this.size = StatusIndicatorSize.medium,
    this.label,
    this.animate = false,
    this.onTap,
  }) : state = StatusIndicatorState.error;

  const StatusIndicator.running({
    super.key,
    this.variant = StatusIndicatorVariant.dot,
    this.size = StatusIndicatorSize.medium,
    this.label,
    this.animate = true,
    this.onTap,
  }) : state = StatusIndicatorState.running;

  const StatusIndicator.stopped({
    super.key,
    this.variant = StatusIndicatorVariant.dot,
    this.size = StatusIndicatorSize.medium,
    this.label,
    this.animate = false,
    this.onTap,
  }) : state = StatusIndicatorState.stopped;

  @override
  Widget build(BuildContext context) {
    Widget indicator = _buildIndicator();

    if (onTap != null) {
      indicator = GestureDetector(onTap: onTap, child: indicator);
    }

    return indicator;
  }

  Widget _buildIndicator() {
    switch (variant) {
      case StatusIndicatorVariant.dot:
        return _buildDot();
      case StatusIndicatorVariant.badge:
        return _buildBadge();
      case StatusIndicatorVariant.pill:
        return _buildPill();
      case StatusIndicatorVariant.inline:
        return _buildInline();
    }
  }

  Widget _buildDot() {
    final dotSize = _getDotSize();
    final color = _getStateColor();

    Widget dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    if (animate) {
      dot = _buildAnimatedDot(dot, color);
    }

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          SizedBox(width: GeistSpacing.sm),
          Text(label!, style: _getTextStyle()),
        ],
      );
    }

    return dot;
  }

  Widget _buildBadge() {
    final color = _getStateColor();
    final backgroundColor = color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.2);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.sm,
        vertical: GeistSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(GeistSpacing.xs),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _getDotSize() * 0.8,
            height: _getDotSize() * 0.8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (label != null) ...[
            SizedBox(width: GeistSpacing.xs),
            Text(label!, style: _getTextStyle().copyWith(color: color)),
          ],
        ],
      ),
    );
  }

  Widget _buildPill() {
    final color = _getStateColor();
    final backgroundColor = color.withValues(alpha: 0.15);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.md,
        vertical: GeistSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _getDotSize() * 0.7,
            height: _getDotSize() * 0.7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (label != null) ...[
            SizedBox(width: GeistSpacing.xs),
            Text(label!, style: _getTextStyle().copyWith(color: color)),
          ],
        ],
      ),
    );
  }

  Widget _buildInline() {
    final color = _getStateColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _getDotSize() * 0.6,
          height: _getDotSize() * 0.6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        if (label != null) ...[
          SizedBox(width: GeistSpacing.xs),
          Text(label!, style: _getTextStyle().copyWith(color: color)),
        ],
      ],
    );
  }

  Widget _buildAnimatedDot(Widget dot, Color color) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing ring
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Container(
              width: _getDotSize() * (1 + value * 0.8),
              height: _getDotSize() * (1 + value * 0.8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.3 * (1 - value)),
                shape: BoxShape.circle,
              ),
            );
          },
          onEnd: () {
            // Animation restarts automatically
          },
        ),
        // Main dot
        dot,
      ],
    );
  }

  double _getDotSize() {
    switch (size) {
      case StatusIndicatorSize.small:
        return 6;
      case StatusIndicatorSize.medium:
        return 8;
      case StatusIndicatorSize.large:
        return 10;
    }
  }

  Color _getStateColor() {
    switch (state) {
      case StatusIndicatorState.success:
        return GeistColors.successColor;
      case StatusIndicatorState.warning:
        return GeistColors.warningColor;
      case StatusIndicatorState.error:
        return GeistColors.errorColor;
      case StatusIndicatorState.info:
        return GeistColors.infoColor;
      case StatusIndicatorState.running:
        return GeistColors.successColor;
      case StatusIndicatorState.stopped:
        return GeistColors.errorColor;
      case StatusIndicatorState.pending:
        return GeistColors.warningColor;
      case StatusIndicatorState.neutral:
        return GeistColors.gray500;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case StatusIndicatorSize.small:
        return GeistTypography.labelSmall;
      case StatusIndicatorSize.medium:
        return GeistTypography.labelMedium;
      case StatusIndicatorSize.large:
        return GeistTypography.labelLarge;
    }
  }
}

// Extension for converting strings to status states
extension StatusIndicatorStateExtension on String {
  StatusIndicatorState? toStatusIndicatorState() {
    switch (toLowerCase()) {
      case 'success':
        return StatusIndicatorState.success;
      case 'warning':
        return StatusIndicatorState.warning;
      case 'error':
        return StatusIndicatorState.error;
      case 'info':
        return StatusIndicatorState.info;
      case 'running':
        return StatusIndicatorState.running;
      case 'stopped':
        return StatusIndicatorState.stopped;
      case 'pending':
        return StatusIndicatorState.pending;
      case 'neutral':
        return StatusIndicatorState.neutral;
      default:
        return null;
    }
  }
}

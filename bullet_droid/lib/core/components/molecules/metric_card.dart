import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';

/// Metric card for dashboard
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? changeText;
  final ChangeDirection? changeDirection;
  final StatusIndicatorState? status;
  final Widget? icon;
  final VoidCallback? onTap;
  final List<QuickAction>? quickActions;
  final bool showBorder;
  final bool isLoading;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.changeText,
    this.changeDirection,
    this.status,
    this.icon,
    this.onTap,
    this.quickActions,
    this.showBorder = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: GeistColors.lightSurface,
          borderRadius: GeistBorders.cardRadius,
          border: showBorder
              ? Border.all(
                  color: GeistColors.lightBorder,
                  width: GeistBorders.widthThin,
                )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? GeistSpacing.md : GeistSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: GeistSpacing.sm),
              _buildValue(isMobile),
              if (subtitle != null || changeText != null) ...[
                SizedBox(height: GeistSpacing.xs),
                _buildSubtitle(),
              ],
              if (quickActions != null && quickActions!.isNotEmpty) ...[
                SizedBox(height: GeistSpacing.md),
                _buildQuickActions(isMobile),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              color: GeistColors.lightTextSecondary,
              size: 16,
            ),
            child: icon!,
          ),
          SizedBox(width: GeistSpacing.sm),
        ],
        Expanded(
          child: GeistText.labelMedium(title, color: GeistTextColor.secondary),
        ),
        if (status != null) ...[
          StatusIndicator(
            state: status!,
            variant: StatusIndicatorVariant.dot,
            size: StatusIndicatorSize.small,
          ),
        ],
      ],
    );
  }

  Widget _buildValue(bool isMobile) {
    if (isLoading) {
      return Container(
        width: 80,
        height: isMobile ? 24 : 32,
        decoration: BoxDecoration(
          color: GeistColors.gray200,
          borderRadius: BorderRadius.circular(GeistSpacing.xs),
        ),
      );
    }

    return GeistText(
      value,
      variant: isMobile
          ? GeistTextVariant.headingMedium
          : GeistTextVariant.headingLarge,
      color: GeistTextColor.primary,
    );
  }

  Widget _buildSubtitle() {
    final widgets = <Widget>[];

    if (subtitle != null) {
      widgets.add(
        GeistText.caption(subtitle!, color: GeistTextColor.secondary),
      );
    }

    if (changeText != null && changeDirection != null) {
      if (widgets.isNotEmpty) {
        widgets.add(SizedBox(width: GeistSpacing.sm));
      }
      widgets.add(_buildChangeIndicator());
    }

    return Row(children: widgets);
  }

  Widget _buildChangeIndicator() {
    Color color;
    IconData iconData;

    switch (changeDirection!) {
      case ChangeDirection.up:
        color = GeistColors.successColor;
        iconData = Icons.arrow_upward;
        break;
      case ChangeDirection.down:
        color = GeistColors.errorColor;
        iconData = Icons.arrow_downward;
        break;
      case ChangeDirection.neutral:
        color = GeistColors.lightTextSecondary;
        iconData = Icons.remove;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, size: 12, color: color),
        SizedBox(width: GeistSpacing.xs),
        GeistText.caption(changeText!, customColor: color),
      ],
    );
  }

  Widget _buildQuickActions(bool isMobile) {
    if (isMobile && quickActions!.length > 2) {
      return Row(
        children: [
          for (int i = 0; i < 2; i++) ...[
            if (i > 0) SizedBox(width: GeistSpacing.sm),
            Expanded(child: _buildQuickAction(quickActions![i])),
          ],
        ],
      );
    }

    return Wrap(
      spacing: GeistSpacing.sm,
      runSpacing: GeistSpacing.xs,
      children: quickActions!
          .map((action) => _buildQuickAction(action))
          .toList(),
    );
  }

  Widget _buildQuickAction(QuickAction action) {
    return GeistButton(
      text: action.label,
      variant: GeistButtonVariant.ghost,
      size: GeistButtonSize.small,
      onPressed: action.onTap,
      icon: action.icon,
    );
  }
}

class QuickAction {
  final String label;
  final VoidCallback onTap;
  final Widget? icon;

  const QuickAction({required this.label, required this.onTap, this.icon});
}

enum ChangeDirection { up, down, neutral }

/// Specialized metric card variants
class MetricCardVariants {
  // Stats card for numerical metrics
  static Widget stats({
    required String title,
    required String value,
    String? subtitle,
    String? changeText,
    ChangeDirection? changeDirection,
    Widget? icon,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return MetricCard(
      title: title,
      value: value,
      subtitle: subtitle,
      changeText: changeText,
      changeDirection: changeDirection,
      icon: icon,
      onTap: onTap,
      isLoading: isLoading,
    );
  }

  static Widget status({
    required String title,
    required String value,
    required StatusIndicatorState status,
    String? subtitle,
    Widget? icon,
    VoidCallback? onTap,
    List<QuickAction>? quickActions,
    bool isLoading = false,
  }) {
    return MetricCard(
      title: title,
      value: value,
      subtitle: subtitle,
      status: status,
      icon: icon,
      onTap: onTap,
      quickActions: quickActions,
      isLoading: isLoading,
    );
  }

  static Widget action({
    required String title,
    required String value,
    required List<QuickAction> actions,
    String? subtitle,
    Widget? icon,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return MetricCard(
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      quickActions: actions,
      isLoading: isLoading,
    );
  }

  static Widget minimal({
    required String title,
    required String value,
    String? subtitle,
    StatusIndicatorState? status,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return MetricCard(
      title: title,
      value: value,
      subtitle: subtitle,
      status: status,
      onTap: onTap,
      showBorder: false,
      isLoading: isLoading,
    );
  }
}

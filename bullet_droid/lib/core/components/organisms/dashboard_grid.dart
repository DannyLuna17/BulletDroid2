import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';
import 'package:bullet_droid/core/components/molecules/metric_card.dart';

/// Dashboard grid organism
class GeistDashboardGrid extends StatelessWidget {
  final List<DashboardGridItem> items;
  final String? title;
  final String? subtitle;
  final List<DashboardAction>? actions;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final int? maxColumns;
  final bool adaptiveColumns;
  final bool isLoading;
  final Widget? emptyWidget;
  final ScrollController? scrollController;
  final bool shrinkWrap;

  const GeistDashboardGrid({
    super.key,
    required this.items,
    this.title,
    this.subtitle,
    this.actions,
    this.padding,
    this.spacing,
    this.maxColumns,
    this.adaptiveColumns = true,
    this.isLoading = false,
    this.emptyWidget,
    this.scrollController,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      padding:
          padding ??
          EdgeInsets.all(isMobile ? GeistSpacing.md : GeistSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || actions != null) _buildHeader(isMobile),
          if (title != null || actions != null)
            SizedBox(height: GeistSpacing.lg),
          Expanded(child: _buildContent(context, isMobile)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          GeistText.headingLarge(title!, color: GeistTextColor.primary),
          if (subtitle != null) ...[
            SizedBox(height: GeistSpacing.xs),
            GeistText.bodyMedium(subtitle!, color: GeistTextColor.secondary),
          ],
        ],
        if (actions != null && actions!.isNotEmpty) ...[
          SizedBox(height: GeistSpacing.md),
          _buildActions(isMobile),
        ],
      ],
    );
  }

  Widget _buildActions(bool isMobile) {
    if (isMobile && actions!.length > 3) {
      return Wrap(
        spacing: GeistSpacing.sm,
        runSpacing: GeistSpacing.sm,
        children: actions!
            .take(3)
            .map((action) => _buildAction(action))
            .toList(),
      );
    }

    return Wrap(
      spacing: GeistSpacing.sm,
      runSpacing: GeistSpacing.sm,
      children: actions!.map((action) => _buildAction(action)).toList(),
    );
  }

  Widget _buildAction(DashboardAction action) {
    return GeistButton(
      text: action.label,
      variant: action.variant,
      size: action.size,
      onPressed: action.onPressed,
      icon: action.icon,
    );
  }

  Widget _buildContent(BuildContext context, bool isMobile) {
    if (isLoading) {
      return _buildLoadingState(context, isMobile);
    }

    if (items.isEmpty) {
      return _buildEmptyState(isMobile);
    }

    return _buildGrid(context, isMobile);
  }

  Widget _buildLoadingState(BuildContext context, bool isMobile) {
    final columns = _getColumnCount(GeistBreakpoints.getDeviceType(context));

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing ?? GeistSpacing.lg,
        mainAxisSpacing: spacing ?? GeistSpacing.lg,
        childAspectRatio: 1.5,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        color: GeistColors.lightSurface,
        borderRadius: BorderRadius.circular(GeistSpacing.sm),
        border: Border.all(color: GeistColors.lightBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: GeistColors.gray300,
              borderRadius: BorderRadius.circular(GeistSpacing.xs),
            ),
          ),
          SizedBox(height: GeistSpacing.md),
          Container(
            height: 24,
            width: 120,
            decoration: BoxDecoration(
              color: GeistColors.gray300,
              borderRadius: BorderRadius.circular(GeistSpacing.xs),
            ),
          ),
          SizedBox(height: GeistSpacing.sm),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: GeistColors.gray300,
              borderRadius: BorderRadius.circular(GeistSpacing.xs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile) {
    if (emptyWidget != null) {
      return emptyWidget!;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: GeistColors.lightTextTertiary,
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistText.headingMedium(
            'No data available',
            color: GeistTextColor.secondary,
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistText.bodyMedium(
            'Dashboard metrics will appear here once data is available',
            color: GeistTextColor.tertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, bool isMobile) {
    final deviceType = GeistBreakpoints.getDeviceType(context);
    final columns = _getColumnCount(deviceType);

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing ?? GeistSpacing.lg,
        mainAxisSpacing: spacing ?? GeistSpacing.lg,
        childAspectRatio: _getAspectRatio(deviceType),
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildGridItem(item, isMobile);
      },
    );
  }

  Widget _buildGridItem(DashboardGridItem item, bool isMobile) {
    switch (item.type) {
      case DashboardItemType.metric:
        return MetricCard(
          title: item.title,
          value: item.value,
          subtitle: item.subtitle,
          changeText: item.changeText,
          changeDirection: item.changeDirection,
          status: item.status,
          icon: item.icon,
          onTap: item.onTap,
          quickActions: item.quickActions,
          isLoading: item.isLoading,
        );
      case DashboardItemType.custom:
        return item.customWidget!;
      case DashboardItemType.status:
        return MetricCardVariants.status(
          title: item.title,
          value: item.value,
          status: item.status ?? StatusIndicatorState.neutral,
          subtitle: item.subtitle,
          icon: item.icon,
          onTap: item.onTap,
          quickActions: item.quickActions,
          isLoading: item.isLoading,
        );
      case DashboardItemType.action:
        return MetricCardVariants.action(
          title: item.title,
          value: item.value,
          actions: item.quickActions ?? [],
          subtitle: item.subtitle,
          icon: item.icon,
          onTap: item.onTap,
          isLoading: item.isLoading,
        );
    }
  }

  int _getColumnCount(DeviceType deviceType) {
    if (maxColumns != null) {
      return maxColumns!;
    }

    if (!adaptiveColumns) {
      return 2;
    }

    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.mobileLarge:
        return 2;
      case DeviceType.tablet:
        return 2;
      case DeviceType.tabletLarge:
        return 3;
      case DeviceType.desktop:
        return 4;
      case DeviceType.desktopLarge:
        return 4;
      case DeviceType.desktopXL:
        return 5;
    }
  }

  double _getAspectRatio(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobile:
        return 2.0;
      case DeviceType.mobileLarge:
        return 1.8;
      case DeviceType.tablet:
        return 1.6;
      case DeviceType.tabletLarge:
        return 1.5;
      case DeviceType.desktop:
        return 1.4;
      case DeviceType.desktopLarge:
        return 1.3;
      case DeviceType.desktopXL:
        return 1.2;
    }
  }
}

/// Dashboard grid item model
class DashboardGridItem {
  final DashboardItemType type;
  final String title;
  final String value;
  final String? subtitle;
  final String? changeText;
  final ChangeDirection? changeDirection;
  final StatusIndicatorState? status;
  final Widget? icon;
  final VoidCallback? onTap;
  final List<QuickAction>? quickActions;
  final bool isLoading;
  final Widget? customWidget;

  const DashboardGridItem({
    required this.type,
    required this.title,
    required this.value,
    this.subtitle,
    this.changeText,
    this.changeDirection,
    this.status,
    this.icon,
    this.onTap,
    this.quickActions,
    this.isLoading = false,
    this.customWidget,
  });

  // Factory constructors for common types
  factory DashboardGridItem.metric({
    required String title,
    required String value,
    String? subtitle,
    String? changeText,
    ChangeDirection? changeDirection,
    Widget? icon,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return DashboardGridItem(
      type: DashboardItemType.metric,
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

  factory DashboardGridItem.status({
    required String title,
    required String value,
    required StatusIndicatorState status,
    String? subtitle,
    Widget? icon,
    VoidCallback? onTap,
    List<QuickAction>? quickActions,
    bool isLoading = false,
  }) {
    return DashboardGridItem(
      type: DashboardItemType.status,
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

  factory DashboardGridItem.action({
    required String title,
    required String value,
    required List<QuickAction> actions,
    String? subtitle,
    Widget? icon,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return DashboardGridItem(
      type: DashboardItemType.action,
      title: title,
      value: value,
      subtitle: subtitle,
      icon: icon,
      onTap: onTap,
      quickActions: actions,
      isLoading: isLoading,
    );
  }

  factory DashboardGridItem.custom({required Widget widget}) {
    return DashboardGridItem(
      type: DashboardItemType.custom,
      title: '',
      value: '',
      customWidget: widget,
    );
  }
}

enum DashboardItemType { metric, status, action, custom }

/// Dashboard action model
class DashboardAction {
  final String label;
  final VoidCallback onPressed;
  final GeistButtonVariant variant;
  final GeistButtonSize size;
  final Widget? icon;

  const DashboardAction({
    required this.label,
    required this.onPressed,
    this.variant = GeistButtonVariant.outline,
    this.size = GeistButtonSize.medium,
    this.icon,
  });
}

/// Specialized dashboard grid variants
class GeistDashboardGridVariants {
  static Widget metrics({
    required List<DashboardGridItem> items,
    String? title,
    String? subtitle,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
  }) {
    return GeistDashboardGrid(
      items: items,
      title: title,
      subtitle: subtitle,
      padding: padding,
      isLoading: isLoading,
    );
  }

  /// Status dashboard with indicators
  static Widget status({
    required List<DashboardGridItem> items,
    String? title,
    String? subtitle,
    List<DashboardAction>? actions,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
  }) {
    return GeistDashboardGrid(
      items: items,
      title: title,
      subtitle: subtitle,
      actions: actions,
      padding: padding,
      isLoading: isLoading,
    );
  }

  /// Compact dashboard
  static Widget compact({
    required List<DashboardGridItem> items,
    String? title,
    EdgeInsetsGeometry? padding,
    bool isLoading = false,
  }) {
    return GeistDashboardGrid(
      items: items,
      title: title,
      padding: padding,
      maxColumns: 2,
      adaptiveColumns: false,
      isLoading: isLoading,
    );
  }

  /// Full-featured dashboard with actions
  static Widget full({
    required List<DashboardGridItem> items,
    String? title,
    String? subtitle,
    List<DashboardAction>? actions,
    EdgeInsetsGeometry? padding,
    Widget? emptyWidget,
    bool isLoading = false,
  }) {
    return GeistDashboardGrid(
      items: items,
      title: title,
      subtitle: subtitle,
      actions: actions,
      padding: padding,
      emptyWidget: emptyWidget,
      isLoading: isLoading,
    );
  }
}

/// Dashboard utilities
class GeistDashboardUtils {
  /// Calculate grid columns based on screen width
  static int calculateColumns(BuildContext context, {int? maxColumns}) {
    final deviceType = GeistBreakpoints.getDeviceType(context);

    if (maxColumns != null) {
      return maxColumns;
    }

    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.mobileLarge:
        return 2;
      case DeviceType.tablet:
        return 2;
      case DeviceType.tabletLarge:
        return 3;
      case DeviceType.desktop:
        return 4;
      case DeviceType.desktopLarge:
        return 4;
      case DeviceType.desktopXL:
        return 5;
    }
  }

  static double getSpacing(BuildContext context) {
    final deviceType = GeistBreakpoints.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.mobileLarge:
        return GeistSpacing.md;
      case DeviceType.tablet:
      case DeviceType.tabletLarge:
        return GeistSpacing.lg;
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
      case DeviceType.desktopXL:
        return GeistSpacing.xl;
    }
  }

  static EdgeInsets getPadding(BuildContext context) {
    final deviceType = GeistBreakpoints.getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return EdgeInsets.all(GeistSpacing.md);
      case DeviceType.mobileLarge:
        return EdgeInsets.all(GeistSpacing.lg);
      case DeviceType.tablet:
      case DeviceType.tabletLarge:
        return EdgeInsets.all(GeistSpacing.xl);
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
      case DeviceType.desktopXL:
        return EdgeInsets.all(GeistSpacing.xxl);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';

import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';

/// Navigation tab component
class GeistTabBar extends StatefulWidget {
  final List<GeistTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double? tabSpacing;
  final TabAlignment alignment;
  final bool showIndicator;
  final bool compactMode;

  const GeistTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.isScrollable = false,
    this.padding,
    this.tabSpacing,
    this.alignment = TabAlignment.start,
    this.showIndicator = true,
    this.compactMode = false,
  });

  @override
  State<GeistTabBar> createState() => _GeistTabBarState();
}

class _GeistTabBarState extends State<GeistTabBar> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      padding:
          widget.padding ??
          EdgeInsets.symmetric(
            horizontal: isMobile ? GeistSpacing.md : GeistSpacing.lg,
          ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: GeistColors.lightBorder,
            width: GeistBorders.widthThin,
          ),
        ),
      ),
      child: widget.isScrollable
          ? SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: _buildTabRow(isMobile),
            )
          : _buildTabRow(isMobile),
    );
  }

  Widget _buildTabRow(bool isMobile) {
    return Row(
      mainAxisAlignment: widget.alignment == TabAlignment.center
          ? MainAxisAlignment.center
          : widget.alignment == TabAlignment.end
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: widget.tabs.asMap().entries.map((entry) {
        final index = entry.key;
        final tab = entry.value;
        final isSelected = index == widget.selectedIndex;

        return Padding(
          padding: EdgeInsets.only(
            right: index < widget.tabs.length - 1
                ? (widget.tabSpacing ?? GeistSpacing.md)
                : 0,
          ),
          child: _buildTab(tab, index, isSelected, isMobile),
        );
      }).toList(),
    );
  }

  Widget _buildTab(GeistTab tab, int index, bool isSelected, bool isMobile) {
    final textColor = isSelected
        ? GeistColors.blue
        : GeistColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => widget.onTabChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: widget.compactMode ? GeistSpacing.sm : GeistSpacing.md,
          horizontal: widget.compactMode ? GeistSpacing.sm : GeistSpacing.lg,
        ),
        decoration: BoxDecoration(
          border: widget.showIndicator && isSelected
              ? Border(
                  bottom: BorderSide(
                    color: GeistColors.blue,
                    width: GeistBorders.widthMedium,
                  ),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              IconTheme(
                data: IconThemeData(
                  color: textColor,
                  size: widget.compactMode ? 16 : 18,
                ),
                child: tab.icon!,
              ),
              SizedBox(width: GeistSpacing.xs),
            ],
            GeistText(
              tab.label,
              variant: widget.compactMode
                  ? GeistTextVariant.labelSmall
                  : GeistTextVariant.labelMedium,
              customColor: textColor,
            ),
            if (tab.badge != null) ...[
              SizedBox(width: GeistSpacing.xs),
              _buildBadge(tab.badge!),
            ],
            if (tab.status != null) ...[
              SizedBox(width: GeistSpacing.xs),
              StatusIndicator(
                state: tab.status!,
                variant: StatusIndicatorVariant.dot,
                size: StatusIndicatorSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String badgeText) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.xs,
        vertical: GeistSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: GeistColors.blue,
        borderRadius: BorderRadius.circular(GeistSpacing.sm),
      ),
      child: GeistText(
        badgeText,
        variant: GeistTextVariant.labelSmall,
        customColor: GeistColors.white,
      ),
    );
  }
}

/// Tab data model
class GeistTab {
  final String label;
  final Widget? icon;
  final String? badge;
  final StatusIndicatorState? status;
  final bool isDisabled;
  final VoidCallback? onLongPress;

  const GeistTab({
    required this.label,
    this.icon,
    this.badge,
    this.status,
    this.isDisabled = false,
    this.onLongPress,
  });
}

enum TabAlignment { start, center, end }

class GeistSegmentedControl extends StatefulWidget {
  final List<GeistSegment> segments;
  final int selectedIndex;
  final ValueChanged<int> onSegmentChanged;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;

  const GeistSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentChanged,
    this.isFullWidth = false,
    this.padding,
  });

  @override
  State<GeistSegmentedControl> createState() => _GeistSegmentedControlState();
}

class _GeistSegmentedControlState extends State<GeistSegmentedControl> {
  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: GeistColors.gray100,
        borderRadius: GeistBorders.buttonRadius,
        border: Border.all(
          color: GeistColors.lightBorder,
          width: GeistBorders.widthThin,
        ),
      ),
      child: Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: widget.segments.asMap().entries.map((entry) {
          final index = entry.key;
          final segment = entry.value;
          final isSelected = index == widget.selectedIndex;

          return widget.isFullWidth
              ? Expanded(
                  child: _buildSegment(segment, index, isSelected, isMobile),
                )
              : _buildSegment(segment, index, isSelected, isMobile);
        }).toList(),
      ),
    );
  }

  Widget _buildSegment(
    GeistSegment segment,
    int index,
    bool isSelected,
    bool isMobile,
  ) {
    final backgroundColor = isSelected ? GeistColors.black : Colors.transparent;

    final textColor = isSelected
        ? GeistColors.white
        : GeistColors.lightTextPrimary;

    return GestureDetector(
      onTap: () => widget.onSegmentChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: GeistSpacing.sm,
          horizontal: GeistSpacing.md,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: GeistBorders.buttonRadius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (segment.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: textColor, size: 16),
                child: segment.icon!,
              ),
              SizedBox(width: GeistSpacing.xs),
            ],
            GeistText(
              segment.label,
              variant: GeistTextVariant.labelMedium,
              customColor: textColor,
            ),
            if (segment.badge != null) ...[
              SizedBox(width: GeistSpacing.xs),
              _buildSegmentBadge(segment.badge!, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentBadge(String badgeText, bool isSelected) {
    final badgeColor = isSelected ? GeistColors.white : GeistColors.blue;
    final textColor = isSelected ? GeistColors.black : GeistColors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.xs,
        vertical: GeistSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(GeistSpacing.sm),
      ),
      child: GeistText(
        badgeText,
        variant: GeistTextVariant.labelSmall,
        customColor: textColor,
      ),
    );
  }
}

class GeistSegment {
  final String label;
  final Widget? icon;
  final String? badge;
  final bool isDisabled;

  const GeistSegment({
    required this.label,
    this.icon,
    this.badge,
    this.isDisabled = false,
  });
}

class GeistPillTabs extends StatefulWidget {
  final List<GeistPill> pills;
  final int selectedIndex;
  final ValueChanged<int> onPillChanged;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double? pillSpacing;
  final WrapAlignment alignment;

  const GeistPillTabs({
    super.key,
    required this.pills,
    required this.selectedIndex,
    required this.onPillChanged,
    this.isScrollable = true,
    this.padding,
    this.pillSpacing,
    this.alignment = WrapAlignment.start,
  });

  @override
  State<GeistPillTabs> createState() => _GeistPillTabsState();
}

class _GeistPillTabsState extends State<GeistPillTabs> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      padding:
          widget.padding ??
          EdgeInsets.symmetric(
            horizontal: isMobile ? GeistSpacing.md : GeistSpacing.lg,
          ),
      child: widget.isScrollable
          ? SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: _buildPillRow(isMobile),
            )
          : _buildPillWrap(isMobile),
    );
  }

  Widget _buildPillRow(bool isMobile) {
    return Row(
      children: widget.pills.asMap().entries.map((entry) {
        final index = entry.key;
        final pill = entry.value;
        final isSelected = index == widget.selectedIndex;

        return Padding(
          padding: EdgeInsets.only(
            right: index < widget.pills.length - 1
                ? (widget.pillSpacing ?? GeistSpacing.sm)
                : 0,
          ),
          child: _buildPill(pill, index, isSelected, isMobile),
        );
      }).toList(),
    );
  }

  Widget _buildPillWrap(bool isMobile) {
    return Wrap(
      alignment: widget.alignment,
      spacing: widget.pillSpacing ?? GeistSpacing.sm,
      runSpacing: GeistSpacing.sm,
      children: widget.pills.asMap().entries.map((entry) {
        final index = entry.key;
        final pill = entry.value;
        final isSelected = index == widget.selectedIndex;

        return _buildPill(pill, index, isSelected, isMobile);
      }).toList(),
    );
  }

  Widget _buildPill(GeistPill pill, int index, bool isSelected, bool isMobile) {
    final backgroundColor = isSelected ? GeistColors.blue : GeistColors.gray100;

    final textColor = isSelected
        ? GeistColors.white
        : GeistColors.lightTextPrimary;

    final borderColor = isSelected ? GeistColors.blue : GeistColors.lightBorder;

    return GestureDetector(
      onTap: () => widget.onPillChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: GeistSpacing.sm,
          horizontal: GeistSpacing.md,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor, width: GeistBorders.widthThin),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pill.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: textColor, size: 14),
                child: pill.icon!,
              ),
              SizedBox(width: GeistSpacing.xs),
            ],
            GeistText(
              pill.label,
              variant: GeistTextVariant.labelSmall,
              customColor: textColor,
            ),
            if (pill.badge != null) ...[
              SizedBox(width: GeistSpacing.xs),
              _buildPillBadge(pill.badge!, isSelected),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPillBadge(String badgeText, bool isSelected) {
    final badgeColor = isSelected
        ? GeistColors.white.withValues(alpha: 0.2)
        : GeistColors.blue;

    final textColor = isSelected ? GeistColors.white : GeistColors.white;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.xs,
        vertical: GeistSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(GeistSpacing.sm),
      ),
      child: GeistText(
        badgeText,
        variant: GeistTextVariant.labelSmall,
        customColor: textColor,
      ),
    );
  }
}

/// Pill data model
class GeistPill {
  final String label;
  final Widget? icon;
  final String? badge;
  final bool isDisabled;

  const GeistPill({
    required this.label,
    this.icon,
    this.badge,
    this.isDisabled = false,
  });
}

/// Tab controller for managing tab state
class GeistTabController extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void selectTab(int index) {
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }

  void nextTab(int maxIndex) {
    if (_selectedIndex < maxIndex) {
      selectTab(_selectedIndex + 1);
    }
  }

  void previousTab() {
    if (_selectedIndex > 0) {
      selectTab(_selectedIndex - 1);
    }
  }
}

/// Specialized tab variants
class GeistTabVariants {
  /// Simple text-only tabs
  static Widget simple({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    bool isScrollable = false,
    TabAlignment alignment = TabAlignment.start,
  }) {
    final tabs = labels.map((label) => GeistTab(label: label)).toList();

    return GeistTabBar(
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabChanged: onTabChanged,
      isScrollable: isScrollable,
      alignment: alignment,
    );
  }

  /// Tabs with icons
  static Widget withIcons({
    required List<String> labels,
    required List<Widget> icons,
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    bool isScrollable = false,
    TabAlignment alignment = TabAlignment.start,
  }) {
    final tabs = List.generate(
      labels.length,
      (index) => GeistTab(label: labels[index], icon: icons[index]),
    );

    return GeistTabBar(
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabChanged: onTabChanged,
      isScrollable: isScrollable,
      alignment: alignment,
    );
  }

  /// Tabs with badges
  static Widget withBadges({
    required List<String> labels,
    required List<String?> badges,
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    bool isScrollable = false,
    TabAlignment alignment = TabAlignment.start,
  }) {
    final tabs = List.generate(
      labels.length,
      (index) => GeistTab(label: labels[index], badge: badges[index]),
    );

    return GeistTabBar(
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabChanged: onTabChanged,
      isScrollable: isScrollable,
      alignment: alignment,
    );
  }

  static Widget compact({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    bool isScrollable = true,
  }) {
    final tabs = labels.map((label) => GeistTab(label: label)).toList();

    return GeistTabBar(
      tabs: tabs,
      selectedIndex: selectedIndex,
      onTabChanged: onTabChanged,
      isScrollable: isScrollable,
      compactMode: true,
    );
  }
}

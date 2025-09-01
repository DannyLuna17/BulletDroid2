import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';

/// Navigation organism for bottom navigation
class MobileNavigation extends StatefulWidget {
  final List<MobileNavItem> items;

  final int selectedIndex;

  final ValueChanged<int> onItemTapped;

  final bool showLabels;

  final MobileNavType type;

  final bool showBadges;

  final double? height;

  final bool useSafeArea;

  final Color? backgroundColor;

  final bool showDivider;

  const MobileNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.showLabels = true,
    this.type = MobileNavType.standard,
    this.showBadges = true,
    this.height,
    this.useSafeArea = true,
    this.backgroundColor,
    this.showDivider = true,
  });

  @override
  State<MobileNavigation> createState() => _MobileNavigationState();
}

class _MobileNavigationState extends State<MobileNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    for (final controller in _scaleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _setupAnimations() {
    _animationControllers = widget.items.map((item) {
      return AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this,
      );
    }).toList();

    _animations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    // Setup scale controllers for juicy tap animations
    _scaleControllers = widget.items.map((item) {
      return AnimationController(
        duration: Duration(milliseconds: 100),
        vsync: this,
      );
    }).toList();

    _scaleAnimations = _scaleControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.15,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    // Animate initial selection
    if (widget.selectedIndex < _animationControllers.length) {
      _animationControllers[widget.selectedIndex].forward();
    }
  }

  @override
  void didUpdateWidget(MobileNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      // Animate out old selection
      if (oldWidget.selectedIndex < _animationControllers.length) {
        _animationControllers[oldWidget.selectedIndex].reverse();
      }

      // Animate in new selection
      if (widget.selectedIndex < _animationControllers.length) {
        _animationControllers[widget.selectedIndex].forward();
      }
    }
  }

  void _triggerScaleAnimation(int index) {
    if (index < _scaleControllers.length) {
      _scaleControllers[index].forward();
    }
  }

  void _releaseScaleAnimation(int index) {
    if (index < _scaleControllers.length) {
      _scaleControllers[index].reverse();
    }
  }

  void _cancelScaleAnimation(int index) {
    if (index < _scaleControllers.length) {
      _scaleControllers[index].reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = GeistBreakpoints.isMobile(context);

    if (!isMobile && widget.type == MobileNavType.standard) {
      return SizedBox.shrink();
    }

    if (widget.type == MobileNavType.floating) {
      return _buildFloatingNavigation(theme);
    }

    final backgroundColor =
        widget.backgroundColor ??
        theme.colorScheme.surface.withValues(alpha: 0.95);

    return Container(
      height: widget.height ?? _getNavigationHeight(context),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: widget.showDivider
            ? Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              )
            : null,
      ),
      child: widget.useSafeArea
          ? SafeArea(top: false, child: _buildNavigationContent(theme))
          : _buildNavigationContent(theme),
    );
  }

  double _getNavigationHeight(BuildContext context) {
    switch (widget.type) {
      case MobileNavType.standard:
        return widget.showLabels ? 88.0 : 60.0;
      case MobileNavType.compact:
        return 56.0;
      case MobileNavType.floating:
        return 80.0;
    }
  }

  Widget _buildNavigationContent(ThemeData theme) {
    switch (widget.type) {
      case MobileNavType.standard:
        return _buildStandardNavigation(theme);
      case MobileNavType.compact:
        return _buildCompactNavigation(theme);
      case MobileNavType.floating:
        return _buildFloatingNavigation(theme);
    }
  }

  Widget _buildStandardNavigation(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.md,
        vertical: GeistSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return _buildNavItem(
            item,
            index,
            theme,
            isSelected: index == widget.selectedIndex,
            showLabel: widget.showLabels,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompactNavigation(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return _buildCompactNavItem(
            item,
            index,
            theme,
            isSelected: index == widget.selectedIndex,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingNavigation(ThemeData theme) {
    const navHeight = 64.0;

    return Container(
      margin: EdgeInsets.only(
        left: GeistSpacing.lg,
        right: GeistSpacing.lg,
        bottom: GeistSpacing.lg *2,
      ),
      constraints: BoxConstraints(minHeight: navHeight, maxHeight: navHeight),
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.md,
        vertical: GeistSpacing.md,
      ),
      decoration: BoxDecoration(
        color: GeistColors.white,
        borderRadius: BorderRadius.circular(navHeight / 2),
        border: Border.all(
          color: GeistColors.gray200,
          width: GeistBorders.widthThin,
        ),
        boxShadow: [
          BoxShadow(
            color: GeistColors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return _buildFloatingNavItem(
            item,
            index,
            theme,
            isSelected: index == widget.selectedIndex,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem(
    MobileNavItem item,
    int index,
    ThemeData theme, {
    required bool isSelected,
    bool showLabel = true,
  }) {
    return GestureDetector(
      onTapDown: (_) => _triggerScaleAnimation(index),
      onTapUp: (_) {
        _releaseScaleAnimation(index);
        widget.onItemTapped(index);
      },
      onTapCancel: () => _cancelScaleAnimation(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animations[index],
          _scaleAnimations[index],
        ]),
        builder: (context, child) {
          final animationValue = _animations[index].value;
          final scale = _scaleAnimations[index].value;

          return Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: GeistSpacing.sm,
                vertical: GeistSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with badge
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(GeistSpacing.xs),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withValues(
                                  alpha: 0.1 + 0.05 * animationValue,
                                )
                              : GeistColors.transparent,
                          borderRadius: BorderRadius.circular(
                            GeistBorders.radiusSmall,
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                          size: 24,
                        ),
                      ),

                      // Badge
                      if (widget.showBadges && item.badge != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: _buildBadge(item.badge!, theme),
                        ),

                      // Status indicator
                      if (item.status != null)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: StatusIndicator(
                            state: item.status!,
                            variant: StatusIndicatorVariant.dot,
                            size: StatusIndicatorSize.small,
                          ),
                        ),
                    ],
                  ),

                  // Label
                  if (showLabel && item.label != null) ...[
                    SizedBox(height: 2),
                    Flexible(
                      child: GeistText.labelSmall(
                        item.label!,
                        color: isSelected
                            ? GeistTextColor.primary
                            : GeistTextColor.secondary,
                        customColor: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompactNavItem(
    MobileNavItem item,
    int index,
    ThemeData theme, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTapDown: (_) => _triggerScaleAnimation(index),
      onTapUp: (_) {
        _releaseScaleAnimation(index);
        widget.onItemTapped(index);
      },
      onTapCancel: () => _cancelScaleAnimation(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animations[index],
          _scaleAnimations[index],
        ]),
        builder: (context, child) {
          final scale = _scaleAnimations[index].value;

          return Transform.scale(
            scale: scale,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: GeistSpacing.md,
                vertical: GeistSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : GeistColors.transparent,
                borderRadius: BorderRadius.circular(GeistBorders.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                        size: 20,
                      ),

                      if (widget.showBadges && item.badge != null)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: _buildBadge(item.badge!, theme, small: true),
                        ),
                    ],
                  ),

                  if (isSelected && item.label != null) ...[
                    SizedBox(width: GeistSpacing.sm),
                    GeistText.labelSmall(
                      item.label!,
                      color: GeistTextColor.primary,
                      customColor: theme.colorScheme.primary,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingNavItem(
    MobileNavItem item,
    int index,
    ThemeData theme, {
    required bool isSelected,
  }) {
    // Determine icon based on selection state
    IconData iconToShow = item.icon;
    if (isSelected) {
      // Map outline icons to filled versions
      switch (item.icon) {
        case Icons.dashboard_outlined:
          iconToShow = Icons.dashboard;
          break;
        case Icons.description_outlined:
          iconToShow = Icons.description;
          break;
        case Icons.list_alt_outlined:
          iconToShow = Icons.list_alt;
          break;
        case Icons.vpn_lock_outlined:
          iconToShow = Icons.vpn_lock;
          break;
        case Icons.settings_outlined:
          iconToShow = Icons.settings;
          break;
        default:
          iconToShow = item.icon;
      }
    }

    return GestureDetector(
      onTapDown: (_) => _triggerScaleAnimation(index),
      onTapUp: (_) {
        _releaseScaleAnimation(index);
        widget.onItemTapped(index);
      },
      onTapCancel: () => _cancelScaleAnimation(index),
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _animations[index],
          _scaleAnimations[index],
        ]),
        builder: (context, child) {
          final scale = _scaleAnimations[index].value;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: 56.0,
              height: 56.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      iconToShow,
                      color: isSelected
                          ? GeistColors.black
                          : GeistColors.gray500,
                      size: 28,
                    ),
                  ),

                  if (widget.showBadges && item.badge != null)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: _buildBadge(item.badge!, theme),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String badge, ThemeData theme, {bool small = false}) {
    if (badge.isEmpty) return SizedBox.shrink();

    final isCountBadge = int.tryParse(badge) != null;
    final count = isCountBadge ? int.parse(badge) : 0;

    if (isCountBadge && count == 0) {
      return SizedBox.shrink();
    }

    if (isCountBadge && count > 99) {
      badge = '99+';
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? GeistSpacing.xs : GeistSpacing.sm,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(
          small ? GeistBorders.radiusSmall : GeistBorders.radiusMedium,
        ),
      ),
      child: GeistText.labelSmall(
        badge,
        color: GeistTextColor.custom,
        customColor: theme.colorScheme.onError,
      ),
    );
  }
}

// Supporting classes
class MobileNavItem {
  final IconData icon;

  final String? label;

  final String? badge;

  final StatusIndicatorState? status;

  final bool isEnabled;

  final String? tooltip;

  const MobileNavItem({
    required this.icon,
    this.label,
    this.badge,
    this.status,
    this.isEnabled = true,
    this.tooltip,
  });
}

enum MobileNavType { standard, compact, floating }

import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/molecules/navigation_tab.dart';
import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';

class DataInterface extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<String>? tabLabels;
  final int initialTabIndex;
  final List<QuickFilter>? quickFilters;
  final Widget? content;
  final List<DataInterfaceAction>? actions;
  final SearchConfig? searchConfig;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final ValueChanged<int>? onTabChanged;

  const DataInterface({
    super.key,
    required this.title,
    this.subtitle,
    this.tabLabels,
    this.initialTabIndex = 0,
    this.quickFilters,
    this.content,
    this.actions,
    this.searchConfig,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onTabChanged,
  });

  @override
  State<DataInterface> createState() => _DataInterfaceState();
}

class _DataInterfaceState extends State<DataInterface> {
  late int _selectedTabIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(theme, isMobile),

          // Tabs
          if (widget.tabLabels != null) _buildTabs(theme),

          // Search and Filters
          if (widget.searchConfig != null || widget.quickFilters != null)
            _buildSearchAndFilters(theme, isMobile),

          // Content
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeistText.headingMedium(
                  widget.title,
                  color: GeistTextColor.primary,
                  customColor: theme.colorScheme.onSurface,
                ),
                if (widget.subtitle != null) ...[
                  SizedBox(height: GeistSpacing.xs),
                  GeistText.bodyMedium(
                    widget.subtitle!,
                    color: GeistTextColor.secondary,
                    customColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (widget.actions != null) ...[
            SizedBox(width: GeistSpacing.md),
            if (isMobile)
              _buildMobileActions(theme)
            else
              _buildDesktopActions(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopActions(ThemeData theme) {
    return Row(
      children: widget.actions!.map((action) {
        return Padding(
          padding: EdgeInsets.only(left: GeistSpacing.sm),
          child: GeistButton(
            onPressed: action.onPressed,
            variant: action.variant,
            size: GeistButtonSize.small,
            icon: action.icon != null ? Icon(action.icon) : null,
            text: action.label,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMobileActions(ThemeData theme) {
    return GeistActionDropdown(
      label: 'Actions',
      actions: widget.actions!.map((action) {
        return DropdownAction(
          icon: action.icon ?? Icons.more_horiz,
          title: action.label,
          onTap: () => action.onPressed?.call(),
        );
      }).toList(),
    );
  }

  Widget _buildTabs(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: GeistTabBar(
        tabs: widget.tabLabels!.map((label) => GeistTab(label: label)).toList(),
        selectedIndex: _selectedTabIndex,
        onTabChanged: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
          widget.onTabChanged?.call(index);
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search
          if (widget.searchConfig != null)
            Row(
              children: [
                Expanded(
                  child: GeistInput(
                    controller: _searchController,
                    placeholder: widget.searchConfig!.placeholder,
                    prefixIcon: Icon(Icons.search),
                    onChanged: (value) {
                      widget.searchConfig!.onSearchChanged?.call(value);
                    },
                  ),
                ),
              ],
            ),

          // Quick filters
          if (widget.quickFilters != null &&
              widget.quickFilters!.isNotEmpty) ...[
            SizedBox(height: GeistSpacing.md),
            _buildQuickFilters(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickFilters(ThemeData theme) {
    return Wrap(
      spacing: GeistSpacing.sm,
      runSpacing: GeistSpacing.sm,
      children: widget.quickFilters!.map((filter) {
        return FilterChip(
          label: Text(filter.label),
          selected: filter.isSelected,
          onSelected: filter.onChanged,
          backgroundColor: theme.colorScheme.surface,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          checkmarkColor: theme.colorScheme.primary,
        );
      }).toList(),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (widget.isLoading) {
      return _buildLoadingState(theme);
    }

    if (widget.error != null) {
      return _buildErrorState(theme);
    }

    if (widget.content != null) {
      return widget.content!;
    }

    return _buildEmptyState(theme);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: GeistSpacing.lg),
          GeistText.bodyLarge(
            'Loading data...',
            color: GeistTextColor.secondary,
            customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
          SizedBox(height: GeistSpacing.lg),
          GeistText.headingSmall(
            'Error',
            color: GeistTextColor.error,
            customColor: theme.colorScheme.error,
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistText.bodyMedium(
            widget.error!,
            color: GeistTextColor.secondary,
            customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistButton(
            onPressed: widget.onRefresh,
            variant: GeistButtonVariant.outline,
            text: 'Retry',
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistText.headingSmall(
            'No data available',
            color: GeistTextColor.secondary,
            customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistText.bodyMedium(
            'There are no items to display.',
            color: GeistTextColor.tertiary,
            customColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Supporting classes
class QuickFilter {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

  const QuickFilter({
    required this.label,
    required this.isSelected,
    this.onChanged,
  });
}

class DataInterfaceAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GeistButtonVariant variant;

  const DataInterfaceAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GeistButtonVariant.outline,
  });
}

class SearchConfig {
  final String placeholder;
  final ValueChanged<String>? onSearchChanged;

  const SearchConfig({required this.placeholder, this.onSearchChanged});
}

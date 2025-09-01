import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';
import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';

/// Filter control organism for advanced data filtering
class FilterControl extends StatefulWidget {
  final String title;

  final String? description;

  final List<FilterGroup> groups;

  final Set<String> initiallyExpandedGroups;

  final int activeFilterCount;

  final VoidCallback? onApplyFilters;

  final VoidCallback? onResetFilters;

  final VoidCallback? onClearFilters;

  final bool showSummary;

  final bool showActionButtons;

  final bool isCollapsible;

  final bool defaultExpanded;

  final bool compactMode;

  const FilterControl({
    super.key,
    required this.title,
    this.description,
    required this.groups,
    this.initiallyExpandedGroups = const {},
    this.activeFilterCount = 0,
    this.onApplyFilters,
    this.onResetFilters,
    this.onClearFilters,
    this.showSummary = true,
    this.showActionButtons = true,
    this.isCollapsible = true,
    this.defaultExpanded = true,
    this.compactMode = false,
  });

  @override
  State<FilterControl> createState() => _FilterControlState();
}

class _FilterControlState extends State<FilterControl> {
  late bool _isExpanded;
  late Set<String> _expandedGroups;
  final Map<String, dynamic> _filterValues = {};

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.defaultExpanded;
    _expandedGroups = Set.from(widget.initiallyExpandedGroups);
    _initializeFilterValues();
  }

  void _initializeFilterValues() {
    for (final group in widget.groups) {
      for (final filter in group.filters) {
        if (filter.initialValue != null) {
          _filterValues[filter.key] = filter.initialValue;
        }
      }
    }
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(theme, isMobile),

          // Content
          if (_isExpanded) ...[
            // Filter summary
            if (widget.showSummary && widget.activeFilterCount > 0)
              _buildFilterSummary(theme, isMobile),

            // Filter groups
            _buildFilterGroups(theme, isMobile),

            // Action buttons
            if (widget.showActionButtons) _buildActionButtons(theme, isMobile),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        border: _isExpanded
            ? Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          // Title and count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GeistText.headingMedium(
                      widget.title,
                      color: GeistTextColor.primary,
                      customColor: theme.colorScheme.onSurface,
                    ),
                    if (widget.activeFilterCount > 0) ...[
                      SizedBox(width: GeistSpacing.sm),
                      StatusIndicator(
                        state: StatusIndicatorState.info,
                        variant: StatusIndicatorVariant.badge,
                        size: StatusIndicatorSize.small,
                        label: widget.activeFilterCount.toString(),
                      ),
                    ],
                  ],
                ),
                if (widget.description != null) ...[
                  SizedBox(height: GeistSpacing.xs),
                  GeistText.bodyMedium(
                    widget.description!,
                    color: GeistTextColor.secondary,
                    customColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quick actions
          if (widget.activeFilterCount > 0)
            TextButton(
              onPressed: widget.onClearFilters,
              child: GeistText.labelMedium(
                'Clear',
                color: GeistTextColor.primary,
                customColor: theme.colorScheme.primary,
              ),
            ),

          // Collapse toggle
          if (widget.isCollapsible)
            IconButton(
              icon: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSummary(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GeistText.labelMedium(
            'Active Filters',
            color: GeistTextColor.primary,
            customColor: theme.colorScheme.onSurface,
          ),
          SizedBox(height: GeistSpacing.sm),

          // Active filter chips
          Wrap(
            spacing: GeistSpacing.sm,
            runSpacing: GeistSpacing.sm,
            children: _buildActiveFilterChips(theme),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActiveFilterChips(ThemeData theme) {
    final chips = <Widget>[];

    for (final group in widget.groups) {
      for (final filter in group.filters) {
        final value = _filterValues[filter.key];
        if (value != null && _isFilterActive(filter, value)) {
          chips.add(_buildFilterChip(filter, value, theme));
        }
      }
    }

    return chips;
  }

  bool _isFilterActive(FilterItem filter, dynamic value) {
    switch (filter.type) {
      case FilterType.text:
        return value is String && value.isNotEmpty;
      case FilterType.toggle:
        return value is bool && value;
      case FilterType.dropdown:
        return value is String && value.isNotEmpty;
      case FilterType.dateRange:
        return value is DateTimeRange;
      case FilterType.slider:
        return value is double && value != (filter.min ?? 0.0);
      case FilterType.multiSelect:
        return value is List && value.isNotEmpty;
    }
  }

  Widget _buildFilterChip(FilterItem filter, dynamic value, ThemeData theme) {
    String displayValue = _getDisplayValue(filter, value);

    return Chip(
      label: GeistText.labelSmall(
        '${filter.label}: $displayValue',
        color: GeistTextColor.primary,
        customColor: theme.colorScheme.onSurface,
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 16,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      onDeleted: () {
        setState(() {
          _filterValues.remove(filter.key);
        });
        filter.onChanged?.call(null);
      },
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
    );
  }

  String _getDisplayValue(FilterItem filter, dynamic value) {
    switch (filter.type) {
      case FilterType.text:
        return value.toString();
      case FilterType.toggle:
        return value ? 'Yes' : 'No';
      case FilterType.dropdown:
        return value.toString();
      case FilterType.dateRange:
        final range = value as DateTimeRange;
        return '${range.start.day}/${range.start.month} - ${range.end.day}/${range.end.month}';
      case FilterType.slider:
        return value.toString();
      case FilterType.multiSelect:
        final list = value as List;
        return list.join(', ');
    }
  }

  Widget _buildFilterGroups(ThemeData theme, bool isMobile) {
    return Column(
      children: widget.groups.map((group) {
        return _buildFilterGroup(group, theme, isMobile);
      }).toList(),
    );
  }

  Widget _buildFilterGroup(FilterGroup group, ThemeData theme, bool isMobile) {
    final isExpanded = _expandedGroups.contains(group.key);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          if (group.title != null)
            InkWell(
              onTap: () {
                setState(() {
                  if (isExpanded) {
                    _expandedGroups.remove(group.key);
                  } else {
                    _expandedGroups.add(group.key);
                  }
                });
              },
              child: Container(
                padding: EdgeInsets.all(GeistSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GeistText.labelLarge(
                            group.title!,
                            color: GeistTextColor.primary,
                            customColor: theme.colorScheme.onSurface,
                          ),
                          if (group.description != null) ...[
                            SizedBox(height: GeistSpacing.xs),
                            GeistText.bodySmall(
                              group.description!,
                              color: GeistTextColor.secondary,
                              customColor: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),

          // Group content
          if (isExpanded || group.title == null)
            Container(
              padding: EdgeInsets.all(GeistSpacing.lg),
              child: Column(
                children: group.filters.map((filter) {
                  return _buildFilterItem(filter, theme, isMobile);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterItem(FilterItem filter, ThemeData theme, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter label
          if (filter.label != null) ...[
            GeistText.labelMedium(
              filter.label!,
              color: GeistTextColor.primary,
              customColor: theme.colorScheme.onSurface,
            ),
            if (filter.description != null) ...[
              SizedBox(height: GeistSpacing.xs),
              GeistText.bodySmall(
                filter.description!,
                color: GeistTextColor.secondary,
                customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
            SizedBox(height: GeistSpacing.sm),
          ],

          // Filter control
          _buildFilterControl(filter, theme, isMobile),
        ],
      ),
    );
  }

  Widget _buildFilterControl(
    FilterItem filter,
    ThemeData theme,
    bool isMobile,
  ) {
    switch (filter.type) {
      case FilterType.text:
        return GeistInput(
          placeholder: filter.placeholder,
          value: _filterValues[filter.key] as String?,
          onChanged: (value) {
            setState(() {
              _filterValues[filter.key] = value;
            });
            filter.onChanged?.call(value);
          },
        );

      case FilterType.toggle:
        return Switch(
          value: _filterValues[filter.key] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filterValues[filter.key] = value;
            });
            filter.onChanged?.call(value);
          },
          activeColor: theme.colorScheme.primary,
        );

      case FilterType.dropdown:
        return GeistDropdownFormField<String>(
          label: filter.label ?? '',
          items: filter.options ?? [],
          itemLabelBuilder: (String option) => option,
          initialValue: _filterValues[filter.key] as String?,
          onChanged: (value) {
            setState(() {
              _filterValues[filter.key] = value;
            });
            filter.onChanged?.call(value);
          },
          validator: (value) => null,
        );

      case FilterType.dateRange:
        return InkWell(
          onTap: () async {
            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now().subtract(Duration(days: 365)),
              lastDate: DateTime.now().add(Duration(days: 365)),
              initialDateRange: _filterValues[filter.key] as DateTimeRange?,
            );

            if (range != null) {
              setState(() {
                _filterValues[filter.key] = range;
              });
              filter.onChanged?.call(range);
            }
          },
          child: Container(
            padding: EdgeInsets.all(GeistSpacing.md),
            decoration: BoxDecoration(
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(GeistBorders.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                SizedBox(width: GeistSpacing.sm),
                Expanded(
                  child: GeistText.bodyMedium(
                    _filterValues[filter.key] != null
                        ? _getDisplayValue(filter, _filterValues[filter.key])
                        : filter.placeholder ?? 'Select date range',
                    color: GeistTextColor.secondary,
                    customColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case FilterType.slider:
        return Column(
          children: [
            Slider(
              value: (_filterValues[filter.key] as double? ?? filter.min ?? 0.0)
                  .clamp(filter.min ?? 0.0, filter.max ?? 1.0),
              min: filter.min ?? 0.0,
              max: filter.max ?? 1.0,
              divisions: filter.divisions,
              onChanged: (value) {
                setState(() {
                  _filterValues[filter.key] = value;
                });
                filter.onChanged?.call(value);
              },
              activeColor: theme.colorScheme.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GeistText.bodySmall(
                  '${filter.min ?? 0.0}',
                  color: GeistTextColor.secondary,
                  customColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
                GeistText.bodySmall(
                  '${filter.max ?? 1.0}',
                  color: GeistTextColor.secondary,
                  customColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
              ],
            ),
          ],
        );

      case FilterType.multiSelect:
        return Column(
          children: (filter.options ?? []).map((option) {
            final selectedValues =
                _filterValues[filter.key] as List<String>? ?? [];
            final isSelected = selectedValues.contains(option);

            return CheckboxListTile(
              title: Text(option),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedValues.add(option);
                  } else {
                    selectedValues.remove(option);
                  }
                  _filterValues[filter.key] = selectedValues;
                });
                filter.onChanged?.call(selectedValues);
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            );
          }).toList(),
        );
    }
  }

  Widget _buildActionButtons(ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.onResetFilters != null)
                  GeistButton(
                    text: 'Reset Filters',
                    variant: GeistButtonVariant.ghost,
                    onPressed: () {
                      setState(() {
                        _filterValues.clear();
                      });
                      widget.onResetFilters?.call();
                    },
                  ),
                if (widget.onResetFilters != null)
                  SizedBox(height: GeistSpacing.sm),
                if (widget.onApplyFilters != null)
                  GeistButton(
                    text: 'Apply Filters',
                    variant: GeistButtonVariant.filled,
                    onPressed: widget.onApplyFilters,
                  ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.onResetFilters != null)
                  GeistButton(
                    text: 'Reset Filters',
                    variant: GeistButtonVariant.ghost,
                    onPressed: () {
                      setState(() {
                        _filterValues.clear();
                      });
                      widget.onResetFilters?.call();
                    },
                  ),
                if (widget.onResetFilters != null)
                  SizedBox(width: GeistSpacing.sm),
                if (widget.onApplyFilters != null)
                  GeistButton(
                    text: 'Apply Filters',
                    variant: GeistButtonVariant.filled,
                    onPressed: widget.onApplyFilters,
                  ),
              ],
            ),
    );
  }
}

// Supporting classes
class FilterGroup {
  final String key;
  final String? title;
  final String? description;
  final List<FilterItem> filters;

  const FilterGroup({
    required this.key,
    this.title,
    this.description,
    required this.filters,
  });
}

class FilterItem {
  final String key;
  final String? label;
  final String? description;
  final FilterType type;
  final String? placeholder;
  final dynamic initialValue;
  final ValueChanged<dynamic>? onChanged;

  final List<String>? options;

  final double? min;
  final double? max;
  final int? divisions;

  const FilterItem({
    required this.key,
    this.label,
    this.description,
    required this.type,
    this.placeholder,
    this.initialValue,
    this.onChanged,
    this.options,
    this.min,
    this.max,
    this.divisions,
  });
}

enum FilterType { text, toggle, dropdown, dateRange, slider, multiSelect }

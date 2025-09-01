import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';
import 'package:bullet_droid/core/components/molecules/form_field.dart';
import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';

/// Settings section organism for configuration interfaces
class SettingsSection extends StatefulWidget {
  final String title;

  final String? description;

  final IconData? icon;

  final List<SettingsGroup> groups;

  final List<SettingsAction>? actions;

  final bool collapsible;

  final bool initiallyExpanded;

  final bool isLoading;

  final bool isDirty;

  final VoidCallback? onSave;

  final VoidCallback? onReset;

  const SettingsSection({
    super.key,
    required this.title,
    this.description,
    this.icon,
    required this.groups,
    this.actions,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.isLoading = false,
    this.isDirty = false,
    this.onSave,
    this.onReset,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.lg),
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
            if (widget.isLoading)
              _buildLoadingState(theme)
            else
              _buildContent(theme, isMobile),

            // Actions
            if (widget.actions != null ||
                widget.onSave != null ||
                widget.onReset != null)
              _buildActions(theme, isMobile),
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
          // Icon
          if (widget.icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(GeistBorders.radiusSmall),
              ),
              child: Icon(
                widget.icon!,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            SizedBox(width: GeistSpacing.md),
          ],

          // Title and description
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
                    if (widget.isDirty) ...[
                      SizedBox(width: GeistSpacing.sm),
                      StatusIndicator.warning(
                        variant: StatusIndicatorVariant.dot,
                        size: StatusIndicatorSize.small,
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

          // Collapse toggle
          if (widget.collapsible)
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

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.xl),
      child: Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(GeistSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.groups.map((group) {
          return _buildGroup(group, theme, isMobile);
        }).toList(),
      ),
    );
  }

  Widget _buildGroup(SettingsGroup group, ThemeData theme, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          if (group.title != null) ...[
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
                customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
            SizedBox(height: GeistSpacing.md),
          ],

          // Settings items
          ...group.items.map((item) {
            return _buildSettingsItem(item, theme, isMobile);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(SettingsItem item, ThemeData theme, bool isMobile) {
    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          if (item.title != null) ...[
            Row(
              children: [
                Expanded(
                  child: GeistText.labelMedium(
                    item.title!,
                    color: GeistTextColor.primary,
                    customColor: theme.colorScheme.onSurface,
                  ),
                ),
                if (item.isRequired) ...[
                  SizedBox(width: GeistSpacing.xs),
                  GeistText.labelSmall(
                    '*',
                    color: GeistTextColor.error,
                    customColor: theme.colorScheme.error,
                  ),
                ],
              ],
            ),
            if (item.description != null) ...[
              SizedBox(height: GeistSpacing.xs),
              GeistText.bodySmall(
                item.description!,
                color: GeistTextColor.secondary,
                customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
            SizedBox(height: GeistSpacing.sm),
          ],

          // Item content
          _buildItemContent(item, theme, isMobile),
        ],
      ),
    );
  }

  Widget _buildItemContent(SettingsItem item, ThemeData theme, bool isMobile) {
    switch (item.type) {
      case SettingsItemType.text:
        return GeistFormField(
          placeholder: item.placeholder,
          value: item.value as String?,
          onChanged: (value) => item.onChanged?.call(value),
          validator: item.validator,
          isDisabled: !item.isEnabled,
          keyboardType: TextInputType.text,
        );

      case SettingsItemType.password:
        return GeistFormField(
          placeholder: item.placeholder,
          value: item.value as String?,
          onChanged: (value) => item.onChanged?.call(value),
          validator: item.validator,
          isDisabled: !item.isEnabled,
          obscureText: true,
          keyboardType: TextInputType.visiblePassword,
        );

      case SettingsItemType.number:
        return GeistFormField(
          placeholder: item.placeholder,
          value: item.value as String?,
          onChanged: (value) => item.onChanged?.call(value),
          validator: item.validator,
          isDisabled: !item.isEnabled,
          keyboardType: TextInputType.number,
        );

      case SettingsItemType.toggle:
        return Container(
          padding: EdgeInsets.symmetric(vertical: GeistSpacing.sm),
          child: Row(
            children: [
              Switch(
                value: item.value as bool? ?? false,
                onChanged: item.isEnabled
                    ? (value) => item.onChanged?.call(value)
                    : null,
                activeColor: theme.colorScheme.primary,
              ),
              SizedBox(width: GeistSpacing.sm),
              if (item.toggleLabel != null)
                GeistText.bodyMedium(
                  item.toggleLabel!,
                  color: GeistTextColor.primary,
                  customColor: theme.colorScheme.onSurface,
                ),
            ],
          ),
        );

      case SettingsItemType.dropdown:
        return GeistDropdownFormField<String>(
          label: item.title ?? 'Select...',
          items: item.options ?? [],
          itemLabelBuilder: (String option) => option,
          initialValue: item.value as String?,
          onChanged: item.isEnabled
              ? (value) => item.onChanged?.call(value)
              : (value) {},
          validator: (value) => null,
        );

      case SettingsItemType.slider:
        return Column(
          children: [
            Slider(
              value: (item.value as double? ?? 0.0).clamp(
                item.min ?? 0.0,
                item.max ?? 1.0,
              ),
              min: item.min ?? 0.0,
              max: item.max ?? 1.0,
              divisions: item.divisions,
              label: item.sliderLabel,
              onChanged: item.isEnabled
                  ? (value) => item.onChanged?.call(value)
                  : null,
              activeColor: theme.colorScheme.primary,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GeistText.bodySmall(
                  '${item.min ?? 0.0}',
                  color: GeistTextColor.secondary,
                  customColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
                GeistText.bodySmall(
                  '${item.max ?? 1.0}',
                  color: GeistTextColor.secondary,
                  customColor: theme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
              ],
            ),
          ],
        );

      case SettingsItemType.custom:
        return item.customWidget ?? SizedBox.shrink();
    }
  }

  Widget _buildActions(ThemeData theme, bool isMobile) {
    final actions = <Widget>[];

    if (widget.onReset != null) {
      actions.add(
        GeistButton(
          text: 'Reset',
          variant: GeistButtonVariant.ghost,
          onPressed: widget.onReset,
          icon: Icon(Icons.refresh),
        ),
      );
    }

    if (widget.onSave != null) {
      actions.add(
        GeistButton(
          text: 'Save Changes',
          variant: GeistButtonVariant.filled,
          onPressed: widget.onSave,
          icon: Icon(Icons.save),
          isDisabled: !widget.isDirty,
        ),
      );
    }

    // Custom actions
    if (widget.actions != null) {
      actions.addAll(
        widget.actions!.map((action) {
          return GeistButton(
            text: action.label,
            variant: action.variant,
            onPressed: action.onPressed,
            icon: action.icon != null ? Icon(action.icon!) : null,
            isDisabled: action.isDisabled,
          );
        }).toList(),
      );
    }

    if (actions.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(GeistSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: actions.map((action) {
                return Padding(
                  padding: EdgeInsets.only(bottom: GeistSpacing.sm),
                  child: action,
                );
              }).toList(),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions.map((action) {
                return Padding(
                  padding: EdgeInsets.only(left: GeistSpacing.sm),
                  child: action,
                );
              }).toList(),
            ),
    );
  }
}

// Supporting classes
class SettingsGroup {
  final String? title;
  final String? description;
  final List<SettingsItem> items;

  const SettingsGroup({this.title, this.description, required this.items});
}

class SettingsItem {
  final String? title;
  final String? description;
  final SettingsItemType type;
  final dynamic value;
  final ValueChanged<dynamic>? onChanged;
  final String? placeholder;
  final bool isRequired;
  final bool isEnabled;
  final String? Function(String?)? validator;

  final List<String>? options;

  final String? toggleLabel;

  final double? min;
  final double? max;
  final int? divisions;
  final String? sliderLabel;

  final Widget? customWidget;

  const SettingsItem({
    this.title,
    this.description,
    required this.type,
    this.value,
    this.onChanged,
    this.placeholder,
    this.isRequired = false,
    this.isEnabled = true,
    this.validator,
    this.options,
    this.toggleLabel,
    this.min,
    this.max,
    this.divisions,
    this.sliderLabel,
    this.customWidget,
  });
}

enum SettingsItemType {
  text,
  password,
  number,
  toggle,
  dropdown,
  slider,
  custom,
}

class SettingsAction {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final GeistButtonVariant variant;
  final bool isDisabled;

  const SettingsAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.variant = GeistButtonVariant.outline,
    this.isDisabled = false,
  });
}

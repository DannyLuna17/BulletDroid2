import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';

// Dropdown Component
class GeistDropdown<T> extends StatefulWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final Widget? Function(T)? itemWidgetBuilder;
  final ValueChanged<T> onChanged;
  final bool isExpanded;
  final GlobalKey? dropdownKey;
  final double? width;

  const GeistDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.itemWidgetBuilder,
    required this.onChanged,
    this.isExpanded = false,
    this.dropdownKey,
    this.width,
  });

  @override
  State<GeistDropdown<T>> createState() => _GeistDropdownState<T>();
}

class _GeistDropdownState<T> extends State<GeistDropdown<T>> {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  late GlobalKey _dropdownKey;

  @override
  void initState() {
    super.initState();
    _dropdownKey = widget.dropdownKey ?? GlobalKey();
    _isExpanded = widget.isExpanded;
  }

  @override
  void dispose() {
    // Clean up overlay without triggering setState
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isExpanded = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dropdownKey,
      width: widget.width,
      height: 44,
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border.all(
          color: const Color.fromRGBO(218, 211, 214, 1),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: GeistColors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GeistText(
                    widget.itemLabelBuilder(widget.value),
                    variant: GeistTextVariant.bodyMedium,
                    fontWeight: FontWeight.bold,
                    customColor: GeistColors.black,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 5.0),
                child: Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: GeistColors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Calculate screen dimensions
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double viewPadding = mediaQuery.viewPadding.bottom;
    final double availableHeight = screenHeight - viewPadding;

    // Estimate dropdown height
    final double estimatedDropdownHeight = (widget.items.length * 44.0) + 16;

    // Determine if dropdown should open upward
    final double spaceBelow = availableHeight - (position.dy + size.height);
    final double spaceAbove = position.dy;
    final bool openUpward =
        spaceBelow < estimatedDropdownHeight && spaceAbove > spaceBelow;

    // Calculate dropdown position
    final double dropdownTop = openUpward
        ? position.dy - estimatedDropdownHeight
        : position.dy + size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: position.dx,
              top:
                  dropdownTop.clamp(
                    0.0,
                    availableHeight - estimatedDropdownHeight,
                  ) +
                  (openUpward ? 12 : 0),
              width: size.width,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border.all(
                        color: const Color.fromRGBO(218, 211, 214, 1),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: GeistColors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final isLast = index == widget.items.length - 1;

                            return _buildDropdownItem(
                              item: item,
                              isLast: isLast,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    } else {
      _isExpanded = false;
    }
  }

  Widget _buildDropdownItem({required T item, bool isLast = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _removeOverlay();
          widget.onChanged(item);
        },
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : const Radius.circular(12),
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: GeistColors.gray200, width: 0.5),
                  ),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.itemWidgetBuilder != null
                    ? (widget.itemWidgetBuilder!(item) ??
                          GeistText(
                            widget.itemLabelBuilder(item),
                            variant: GeistTextVariant.bodyMedium,
                            customColor: GeistColors.gray800,
                            overflow: TextOverflow.ellipsis,
                          ))
                    : GeistText(
                        widget.itemLabelBuilder(item),
                        variant: GeistTextVariant.bodyMedium,
                        customColor: GeistColors.gray800,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Action Dropdown Component
class GeistActionDropdown extends StatefulWidget {
  final String label;
  final List<DropdownAction> actions;
  final GlobalKey? dropdownKey;
  final double? width;

  const GeistActionDropdown({
    super.key,
    required this.label,
    required this.actions,
    this.dropdownKey,
    this.width,
  });

  @override
  State<GeistActionDropdown> createState() => _GeistActionDropdownState();
}

class _GeistActionDropdownState extends State<GeistActionDropdown> {
  bool _isExpanded = false;
  OverlayEntry? _overlayEntry;
  late GlobalKey _dropdownKey;

  @override
  void initState() {
    super.initState();
    _dropdownKey = widget.dropdownKey ?? GlobalKey();
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dropdownKey,
      width: widget.width,
      height: 44,
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border.all(
          color: const Color.fromRGBO(218, 211, 214, 1),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleDropdown,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GeistText(
                  widget.label,
                  variant: GeistTextVariant.bodyMedium,
                  fontWeight: FontWeight.bold,
                  customColor: GeistColors.black,
                  fontSize: 12.5,
                ),
                Spacer(),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 20,
                  color: GeistColors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    if (_isExpanded) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Calculate screen dimensions
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenHeight = mediaQuery.size.height;
    final double viewPadding = mediaQuery.viewPadding.bottom;
    final double availableHeight = screenHeight - viewPadding;

    // Estimate dropdown height
    final double estimatedDropdownHeight = (widget.actions.length * 44.0) + 16;

    // Determine if dropdown should open upward
    final double spaceBelow = availableHeight - (position.dy + size.height);
    final double spaceAbove = position.dy;
    final bool openUpward =
        spaceBelow < estimatedDropdownHeight && spaceAbove > spaceBelow;

    // Calculate dropdown position
    final double dropdownTop = openUpward
        ? position.dy - estimatedDropdownHeight
        : position.dy + size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: position.dx,
              top: dropdownTop.clamp(
                0.0,
                availableHeight - estimatedDropdownHeight,
              ),
              width: size.width,
              child: GestureDetector(
                onTap: () {},
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border.all(
                        color: const Color.fromRGBO(218, 211, 214, 1),
                        width: 1.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: GeistColors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.actions.asMap().entries.map((entry) {
                            final index = entry.key;
                            final action = entry.value;
                            final isLast = index == widget.actions.length - 1;

                            return _buildDropdownItem(
                              action: action,
                              isLast: isLast,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isExpanded = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    } else {
      _isExpanded = false;
    }
  }

  Widget _buildDropdownItem({
    required DropdownAction action,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _removeOverlay();
          action.onTap();
        },
        borderRadius: BorderRadius.vertical(
          top: isLast ? Radius.zero : const Radius.circular(12),
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(color: GeistColors.gray200, width: 0.5),
                  ),
          ),
          child: Row(
            children: [
              Icon(action.icon, size: 18, color: GeistColors.gray600),
              SizedBox(width: GeistSpacing.sm),
              Expanded(
                child: GeistText(
                  action.title,
                  variant: GeistTextVariant.bodyMedium,
                  customColor: GeistColors.gray800,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Form Field Dropdown Component
class GeistDropdownFormField<T> extends FormField<T> {
  GeistDropdownFormField({
    super.key,
    required String label,
    required List<T> items,
    required String Function(T) itemLabelBuilder,
    Widget? Function(T)? itemWidgetBuilder,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled,
    super.autovalidateMode,
    GlobalKey? dropdownKey,
    ValueChanged<T>? onChanged,
    double? width,
  }) : super(
         builder: (FormFieldState<T> field) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GeistText(
                 label,
                 variant: GeistTextVariant.bodyMedium,
                 fontWeight: FontWeight.w500,
               ),
               SizedBox(height: GeistSpacing.xs),
               GeistDropdown<T>(
                 label: field.value != null
                     ? itemLabelBuilder(field.value as T)
                     : 'Select...',
                 value: field.value ?? items.first,
                 items: items,
                 itemLabelBuilder: itemLabelBuilder,
                 itemWidgetBuilder: itemWidgetBuilder,
                 onChanged: enabled
                     ? (T value) {
                         field.didChange(value);
                         onChanged?.call(value);
                       }
                     : (T value) {},
                 dropdownKey: dropdownKey,
                 width: width,
               ),
               if (field.hasError) ...[
                 SizedBox(height: GeistSpacing.xs),
                 GeistText(
                   field.errorText!,
                   variant: GeistTextVariant.bodySmall,
                   customColor: GeistColors.errorColor,
                 ),
               ],
             ],
           );
         },
       );
}

// Dropdown Action Model
class DropdownAction {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const DropdownAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/geist_fab.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/router/app_router.dart';

import 'package:bullet_droid/features/wordlists/providers/custom_wordlist_types_provider.dart';
import 'package:bullet_droid/features/wordlists/models/custom_wordlist_type.dart';

class CustomWordlistTypesScreen extends ConsumerStatefulWidget {
  const CustomWordlistTypesScreen({super.key});

  @override
  ConsumerState<CustomWordlistTypesScreen> createState() =>
      _CustomWordlistTypesScreenState();
}

class _CustomWordlistTypesScreenState
    extends ConsumerState<CustomWordlistTypesScreen>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _swipeControllers = {};
  final Map<String, Animation<double>> _swipeAnimations = {};
  final Set<String> _editingIds = {};

  @override
  void dispose() {
    for (final controller in _swipeControllers.values) {
      controller.dispose();
    }
    _swipeControllers.clear();
    _swipeAnimations.clear();
    super.dispose();
  }

  AnimationController _getSwipeController(String id) {
    if (!_swipeControllers.containsKey(id)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _swipeControllers[id] = controller;
      _swipeAnimations[id] = Tween<double>(
        begin: 0.0,
        end: -60.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }
    return _swipeControllers[id]!;
  }

  void _resetSwipe(String id) {
    final controller = _swipeControllers[id];
    if (controller != null) {
      controller.reverse();
    }
  }

  void _resetAllSwipes() {
    for (final controller in _swipeControllers.values) {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customWordlistTypesProvider);
    final types = state.types;

    return Scaffold(
      backgroundColor: GeistColors.gray50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight - 10),
        child: GestureDetector(
          onTap: _resetAllSwipes,
          child: AppBar(
            backgroundColor: GeistColors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: GeistColors.transparent,
            shadowColor: GeistColors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GeistColors.black),
              onPressed: () => context.goNamed(AppRoute.settings),
            ),
            title: const GeistText(
              'Custom Wordlist Types',
              variant: GeistTextVariant.headingMedium,
              customColor: GeistColors.black,
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _resetAllSwipes,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: GeistSpacing.lg,
            vertical: GeistSpacing.md,
          ),
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : types.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: types.length,
                  itemBuilder: (context, index) {
                    final type = types[index];
                    return _buildTypeCard(type);
                  },
                ),
        ),
      ),
      floatingActionButton: GeistFab(
        onPressed: () async {
          _resetAllSwipes();
          try {
            final id = await ref.read(customWordlistTypesProvider.notifier).addPlaceholder();
            setState(() {
              _editingIds.add(id);
            });
          } catch (e) {
             if (context.mounted) {
               context.showErrorToast('Failed to create new type');
             }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.list_alt_outlined, size: 72, color: GeistColors.gray400),
          SizedBox(height: GeistSpacing.md),
          const GeistText(
            'No custom wordlist types',
            variant: GeistTextVariant.headingMedium,
            customColor: GeistColors.gray700,
          ),
          SizedBox(height: GeistSpacing.xs),
          const GeistText(
            'Tap + to add your own type',
            variant: GeistTextVariant.bodyMedium,
            customColor: GeistColors.gray500,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(CustomWordlistType type) {
    if (_editingIds.contains(type.id)) {
      return _buildEditableCard(type);
    }
    
    final controller = _getSwipeController(type.id);
    final animation = _swipeAnimations[type.id]!;

    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      child: Stack(
        children: [
          // Delete background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: GeistSpacing.md),
              child: GestureDetector(
                onTap: () async {
                  await ref
                      .read(customWordlistTypesProvider.notifier)
                      .deleteType(type.id);
                  if (mounted) {
                    context.showSuccessToast(
                      'Deleted custom type "${type.name}"',
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(GeistSpacing.sm),
                  child: Icon(Icons.delete, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          // Main content
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(animation.value, 0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final currentValue = controller.value;
                    final delta = details.delta.dx / 300;

                    if (details.delta.dx < 0) {
                      final newValue = (currentValue - delta).clamp(0.0, 1.0);
                      controller.value = newValue;
                    } else if (details.delta.dx > 0 && currentValue > 0) {
                      final newValue = (currentValue - delta).clamp(0.0, 1.0);
                      controller.value = newValue;
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    final velocity = details.velocity.pixelsPerSecond.dx;

                    if (velocity < -500) {
                      controller.forward();
                    } else if (velocity > 500) {
                      controller.reverse();
                    } else if (controller.value > 0.3) {
                      controller.forward();
                    } else {
                      controller.reverse();
                    }
                  },
                  onTap: () {
                    _resetSwipe(type.id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GeistColors.gray200),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: GeistSpacing.md,
                            bottom: GeistSpacing.lg,
                            left: GeistSpacing.md,
                            right: GeistSpacing.xs,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GeistText(
                                      type.name,
                                      variant: GeistTextVariant.headingSmall,
                                      customColor: GeistColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: GeistSpacing.xs),
                              _keyValueRow('Regex', type.regex),
                              SizedBox(height: GeistSpacing.xs),
                              _keyValueRow(
                                'Separator',
                                type.separator.isEmpty
                                    ? 'none'
                                    : type.separator,
                              ),
                              SizedBox(height: GeistSpacing.sm),
                              Wrap(
                                spacing: GeistSpacing.sm,
                                runSpacing: GeistSpacing.xs,
                                children: type.slices
                                    .map(
                                      (s) => Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: GeistSpacing.sm,
                                          vertical: GeistSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: GeistColors.gray100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: GeistText(
                                          s,
                                          variant: GeistTextVariant.bodySmall,
                                          customColor: GeistColors.gray700,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: IconButton(
                              icon: const Icon(Icons.edit, size: 24),
                              color: GeistColors.gray500,
                              onPressed: () {
                                _resetSwipe(type.id);
                                setState(() {
                                  _editingIds.add(type.id);
                                });
                              },
                              tooltip: 'Edit',
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Tooltip(
                            message: 'Swipe left to delete this type',
                            preferBelow: false,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.info_outline,
                                size: 20,
                                color: GeistColors.gray400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(CustomWordlistType type) {
    return _EditableTypeCard(
      key: ValueKey('editable_${type.id}'),
      type: type,
      onSave: (updatedType) async {
        try {
          await ref.read(customWordlistTypesProvider.notifier).updateType(updatedType);
          if (mounted) {
            setState(() {
              _editingIds.remove(type.id);
            });
            context.showSuccessToast('Saved "${updatedType.name}"');
          }
        } catch (e) {
          if (mounted) {
            context.showErrorToast(e.toString().replaceAll('Exception: ', ''));
          }
        }
      },
      onCancel: () {
        // If it was a placeholder, delete it
        if (type.isPlaceholder) {
          ref.read(customWordlistTypesProvider.notifier).deleteType(type.id);
        }
        if (mounted) {
          setState(() {
            _editingIds.remove(type.id);
          });
        }
      },
    );
  }

  Widget _keyValueRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: GeistText(
            '$label:',
            variant: GeistTextVariant.bodySmall,
            fontWeight: FontWeight.w600,
            customColor: GeistColors.gray600,
          ),
        ),
        Expanded(
          child: GeistText(
            value,
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray800,
          ),
        ),
      ],
    );
  }
}

class _EditableTypeCard extends StatefulWidget {
  final CustomWordlistType type;
  final Function(CustomWordlistType) onSave;
  final VoidCallback onCancel;

  const _EditableTypeCard({
    super.key,
    required this.type,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_EditableTypeCard> createState() => _EditableTypeCardState();
}

class _EditableTypeCardState extends State<_EditableTypeCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _regexController;
  late final TextEditingController _separatorController;
  late final TextEditingController _slicesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.type.name);
    _regexController = TextEditingController(text: widget.type.regex);
    _separatorController = TextEditingController(text: widget.type.separator);
    _slicesController = TextEditingController(text: widget.type.slices.join(', '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regexController.dispose();
    _separatorController.dispose();
    _slicesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: GeistSpacing.md),
      decoration: BoxDecoration(
        color: GeistColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: GeistColors.lightBorder, width: 2), // Active edit border
      ),
      padding: EdgeInsets.all(GeistSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              isDense: true,
            ),
          ),
          SizedBox(height: GeistSpacing.sm),
          TextField(
            controller: _regexController,
            decoration: const InputDecoration(
              labelText: 'Regex',
              isDense: true,
            ),
          ),
          SizedBox(height: GeistSpacing.sm),
          TextField(
            controller: _separatorController,
            decoration: const InputDecoration(
              labelText: 'Separator (optional)',
              isDense: true,
            ),
          ),
          SizedBox(height: GeistSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _slicesController,
                  decoration: const InputDecoration(
                    labelText: 'Slices (comma separated)',
                    hintText: 'e.g. USERNAME,PASSWORD',
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: GeistSpacing.sm),
              IconButton(
                icon: const Icon(Icons.close),
                color: GeistColors.gray500,
                iconSize: 28,
                onPressed: widget.onCancel,
                tooltip: 'Cancel',
              ),
              IconButton(
                icon: const Icon(Icons.check_circle),
                color: GeistColors.black,
                iconSize: 34,
                onPressed: _handleSave,
                tooltip: 'Save',
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    final slices = _slicesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final updatedType = widget.type.copyWith(
      name: _nameController.text,
      regex: _regexController.text,
      separator: _separatorController.text,
      slices: slices,
    );
    
    widget.onSave(updatedType);
  }
}

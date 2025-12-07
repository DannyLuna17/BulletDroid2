import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/router/app_router.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_confirmation_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';
import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';

import 'package:bullet_droid/features/hits_db/providers/hits_db_provider.dart';
import 'package:bullet_droid/features/hits_db/models/hit_record.dart';

class HitsDbScreen extends ConsumerStatefulWidget {
  const HitsDbScreen({super.key});

  @override
  ConsumerState<HitsDbScreen> createState() => _HitsDbScreenState();
}

class _HitsDbScreenState extends ConsumerState<HitsDbScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  bool _isFilterExpanded = false;

  bool _showDeleteDuplicatesConfirmation = false;
  bool _showDeleteFilteredConfirmation = false;
  bool _showDeleteAllConfirmation = false;

  final Map<String, AnimationController> _swipeControllers = {};
  final Map<String, Animation<double>> _swipeAnimations = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Dispose all animation controllers
    for (final controller in _swipeControllers.values) {
      controller.dispose();
    }
    _swipeControllers.clear();
    _swipeAnimations.clear();
    super.dispose();
  }

  void _cancelAllConfirmations() {
    setState(() {
      _showDeleteDuplicatesConfirmation = false;
      _showDeleteFilteredConfirmation = false;
      _showDeleteAllConfirmation = false;
    });
  }

  // Get or create animation controller for a hit card
  AnimationController _getSwipeController(String hitId) {
    if (!_swipeControllers.containsKey(hitId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _swipeControllers[hitId] = controller;
      _swipeAnimations[hitId] = Tween<double>(
        begin: 0.0,
        end: -60.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }
    return _swipeControllers[hitId]!;
  }

  // Reset swipe state for a specific hit
  void _resetSwipe(String hitId) {
    final controller = _swipeControllers[hitId];
    if (controller != null) {
      controller.reverse();
    }
  }

  // Reset all swipe states
  void _resetAllSwipes() {
    for (final controller in _swipeControllers.values) {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hitsDbState = ref.watch(hitsDbProvider);

    return Scaffold(
      backgroundColor: GeistColors.gray50,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight - 10),
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
          title: GeistText(
            'Hits Database',
            variant: GeistTextVariant.headingMedium,
            customColor: GeistColors.black,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.filter_alt_outlined, color: GeistColors.gray600),
              onPressed: () {
                setState(() {
                  _isFilterExpanded = !_isFilterExpanded;
                });
              },
            ),
          ],
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _cancelAllConfirmations();
          _resetAllSwipes();
        },
        child: Column(
          children: [
            // Statistics Header
            Container(
              padding: EdgeInsets.all(GeistSpacing.md),
              decoration: BoxDecoration(
                color: GeistColors.white,
                border: Border(
                  bottom: BorderSide(color: GeistColors.gray200, width: 1),
                ),
              ),
              child: _buildStatisticsHeader(hitsDbState),
            ),

            // Filter Panel
            if (_isFilterExpanded) _buildFilterPanel(hitsDbState),

            // Main Data Interface
            Expanded(child: _buildMainDataInterface(hitsDbState)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(HitsDbState hitsDbState) {
    return Row(
      children: [
        // Total Hits
        Expanded(
          child: _buildMetricCard(
            title: 'Total Hits',
            value: hitsDbState.totalHits.toString(),
            icon: Icons.analytics,
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Filtered Hits
        Expanded(
          child: _buildMetricCard(
            title: 'Filtered',
            value: hitsDbState.hits.length.toString(),
            icon: Icons.filter_alt,
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Success Rate
        Expanded(
          child: _buildMetricCard(
            title: 'Success %',
            value: hitsDbState.totalHits > 0
                ? '${((hitsDbState.hits.where((h) => h.type == 'SUCCESS').length / hitsDbState.totalHits) * 100).toStringAsFixed(1)}%'
                : '0%',
            icon: Icons.check_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.md),
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border.all(color: GeistColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: GeistColors.gray600),
              SizedBox(width: GeistSpacing.xs),
              GeistText(
                title,
                variant: GeistTextVariant.bodySmall,
                customColor: GeistColors.gray600,
              ),
            ],
          ),
          SizedBox(height: GeistSpacing.xs),
          GeistText(
            value,
            variant: GeistTextVariant.headingSmall,
            customColor: GeistColors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(HitsDbState hitsDbState) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GeistSpacing.lg,
        vertical: GeistSpacing.md,
      ),
      decoration: BoxDecoration(
        color: GeistColors.white,
        border: Border(
          bottom: BorderSide(color: GeistColors.gray200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Config',
                  value: hitsDbState.selectedConfig,
                  options: hitsDbState.availableConfigs,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(hitsDbProvider.notifier)
                          .updateSelectedConfig(value);
                    }
                  },
                ),
              ),
              SizedBox(width: GeistSpacing.md),
              Expanded(
                child: _buildFilterDropdown(
                  label: 'Type',
                  value: hitsDbState.selectedType,
                  options: hitsDbState.availableTypes,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(hitsDbProvider.notifier)
                          .updateSelectedType(value);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GeistText(
          label,
          variant: GeistTextVariant.bodySmall,
          customColor: GeistColors.gray600,
        ),
        SizedBox(height: GeistSpacing.xs),
        GeistDropdown<String>(
          label: value ?? 'Select...',
          value: value ?? options.first,
          items: options,
          itemLabelBuilder: (String option) => option,
          onChanged: (String newValue) {
            onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildMainDataInterface(HitsDbState hitsDbState) {
    if (hitsDbState.isLoading) {
      return _buildLoadingState();
    }

    return Column(
      children: [
        // Toolbar
        Container(
          padding: EdgeInsets.only(
            left: GeistSpacing.sm,
            right: GeistSpacing.sm,
            top: GeistSpacing.md,
            bottom: GeistSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: GeistColors.white,
            border: Border(bottom: BorderSide(color: GeistColors.gray200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Search
              Container(
                width: 170,
                padding: EdgeInsets.only(right: GeistSpacing.xs, left: GeistSpacing.sm),
                child: GeistInput(
                  controller: _searchController,
                  placeholder: 'Search hits...',
                  onChanged: (query) {
                    ref.read(hitsDbProvider.notifier).updateSearchQuery(query);
                  },
                ),
              ),
              GeistButton(
                text: 'Export',
                variant: GeistButtonVariant.outline,
                onPressed: () => _exportHits(hitsDbState),
              ),
              GeistButton(
                text: 'Refresh',
                variant: GeistButtonVariant.outline,
                onPressed: () =>
                    ref.read(hitsDbProvider.notifier).refreshData(),
              ),
            ],
          ),
        ),

        // Delete Actions
        Container(
          padding: EdgeInsets.all(GeistSpacing.md),
          decoration: BoxDecoration(
            color: GeistColors.white,
            border: Border(bottom: BorderSide(color: GeistColors.gray200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: GeistConfirmationButton(
                  text: 'Del. Duplicates',
                  isConfirming: _showDeleteDuplicatesConfirmation,
                  onConfirmationStateChanged: () {
                    setState(() {
                      _showDeleteDuplicatesConfirmation =
                          !_showDeleteDuplicatesConfirmation;
                      _showDeleteFilteredConfirmation = false;
                      _showDeleteAllConfirmation = false;
                    });
                  },
                  onConfirm: () async {
                    await ref
                        .read(hitsDbProvider.notifier)
                        .deleteDuplicateHits();
                    setState(() {
                      _showDeleteDuplicatesConfirmation = false;
                    });
                    if (mounted) {
                      context.showSuccessToast('Duplicate hits deleted');
                    }
                  },
                  height: 44,
                ),
              ),

              SizedBox(width: GeistSpacing.sm),

              Expanded(
                child: GeistConfirmationButton(
                  text: 'Del. Filtered',
                  isConfirming: _showDeleteFilteredConfirmation,
                  onConfirmationStateChanged: () {
                    setState(() {
                      _showDeleteFilteredConfirmation =
                          !_showDeleteFilteredConfirmation;
                      _showDeleteDuplicatesConfirmation = false;
                      _showDeleteAllConfirmation = false;
                    });
                  },
                  onConfirm: () async {
                    await ref
                        .read(hitsDbProvider.notifier)
                        .deleteFilteredHits();
                    setState(() {
                      _showDeleteFilteredConfirmation = false;
                    });
                    if (mounted) {
                      context.showSuccessToast('Filtered hits deleted');
                    }
                  },
                  height: 44,
                ),
              ),

              SizedBox(width: GeistSpacing.sm),

              Expanded(
                child: GeistConfirmationButton(
                  text: 'Del. All',
                  isConfirming: _showDeleteAllConfirmation,
                  onConfirmationStateChanged: () {
                    setState(() {
                      _showDeleteAllConfirmation = !_showDeleteAllConfirmation;
                      _showDeleteDuplicatesConfirmation = false;
                      _showDeleteFilteredConfirmation = false;
                    });
                  },
                  onConfirm: () async {
                    await ref.read(hitsDbProvider.notifier).deleteAllHits();
                    setState(() {
                      _showDeleteAllConfirmation = false;
                    });
                    if (mounted) {
                      context.showSuccessToast('All hits deleted');
                    }
                  },
                  height: 44,
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(child: _buildCardView(hitsDbState)),
      ],
    );
  }

  Widget _buildCardView(HitsDbState hitsDbState) {
    if (hitsDbState.hits.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(GeistSpacing.md),
      itemCount: hitsDbState.hits.length,
      itemBuilder: (context, index) {
        final hit = hitsDbState.hits[index];
        return _buildHitCard(hit);
      },
    );
  }

  Widget _buildHitCard(HitRecord hit) {
    final controller = _getSwipeController(hit.id);
    final animation = _swipeAnimations[hit.id]!;

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
                  await ref.read(hitsDbProvider.notifier).deleteHit(hit.id);
                  if (mounted) {
                    context.showSuccessToast('Hit deleted');
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(GeistSpacing.sm),
                  child: Icon(Icons.delete, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          // Main card content
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(animation.value, 0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    final currentValue = controller.value;
                    final delta = details.delta.dx / 300;

                    // Allow left swipe to open and right swipe to close
                    if (details.delta.dx < 0) {
                      final newValue = (currentValue - delta).clamp(0.0, 1.0);
                      controller.value = newValue;
                    } else if (details.delta.dx > 0 && currentValue > 0) {
                      final newValue = (currentValue - delta).clamp(0.0, 1.0);
                      controller.value = newValue;
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    // Consider both position and velocity for more natural feel
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
                    _resetSwipe(hit.id);
                  },
                  child: Container(
                    padding: EdgeInsets.all(GeistSpacing.md),
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border.all(color: GeistColors.gray200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with status and type
                            Row(
                              children: [
                                StatusIndicator(
                                  state: _getStatusFromType(hit.type),
                                  size: StatusIndicatorSize.medium,
                                  label: hit.type,
                                ),
                                const Spacer(),
                                GeistText(
                                  DateFormat('MMM d, HH:mm').format(hit.date),
                                  variant: GeistTextVariant.bodySmall,
                                  customColor: GeistColors.gray600,
                                  selectable: true,
                                ),
                              ],
                            ),

                            SizedBox(height: GeistSpacing.md),

                            // Data
                            GeistText(
                              'Data',
                              variant: GeistTextVariant.bodySmall,
                              customColor: GeistColors.gray600,
                            ),
                            SizedBox(height: GeistSpacing.xs),
                            GeistText(
                              hit.data,
                              variant: GeistTextVariant.bodyMedium,
                              selectable: true,
                            ),

                            SizedBox(height: GeistSpacing.sm),

                            // Config and Wordlist
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GeistText(
                                        'Config',
                                        variant: GeistTextVariant.bodySmall,
                                        customColor: GeistColors.gray600,
                                      ),
                                      SizedBox(height: GeistSpacing.xs),
                                      GeistText(
                                        hit.configName,
                                        variant: GeistTextVariant.bodySmall,
                                        selectable: true,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: GeistSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GeistText(
                                        'Wordlist',
                                        variant: GeistTextVariant.bodySmall,
                                        customColor: GeistColors.gray600,
                                      ),
                                      SizedBox(height: GeistSpacing.xs),
                                      GeistText(
                                        hit.wordlistName,
                                        variant: GeistTextVariant.bodySmall,
                                        selectable: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            if (hit.proxy != null) ...[
                              SizedBox(height: GeistSpacing.sm),
                              GeistText(
                                'Proxy',
                                variant: GeistTextVariant.bodySmall,
                                customColor: GeistColors.gray600,
                              ),
                              SizedBox(height: GeistSpacing.xs),
                              GeistText(
                                hit.proxy!,
                                variant: GeistTextVariant.bodySmall,
                                selectable: true,
                              ),
                            ],

                            if (hit.capturedData.isNotEmpty) ...[
                              SizedBox(height: GeistSpacing.sm),
                              GeistText(
                                'Captured Data',
                                variant: GeistTextVariant.bodySmall,
                                customColor: GeistColors.gray600,
                              ),
                              SizedBox(height: GeistSpacing.xs),
                              ...hit.capturedData.entries.map(
                                (entry) => Container(
                                  margin: EdgeInsets.only(
                                    bottom: GeistSpacing.xs,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GeistText(
                                        '${entry.key}: ',
                                        variant: GeistTextVariant.bodySmall,
                                        selectable: true,
                                      ),
                                      Expanded(
                                        child: GeistText(
                                          entry.value,
                                          variant: GeistTextVariant.bodySmall,
                                          selectable: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Tooltip(
                            message: 'Swipe left to delete this hit',
                            preferBelow: false,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outline,
                              size: 20,
                              color: GeistColors.gray400,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: GeistColors.blue),
          SizedBox(height: GeistSpacing.md),
          GeistText(
            'Loading hits...',
            variant: GeistTextVariant.bodyMedium,
            customColor: GeistColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: GeistColors.gray400),
          SizedBox(height: GeistSpacing.md),
          GeistText(
            'No hits found',
            variant: GeistTextVariant.headingSmall,
            customColor: GeistColors.gray600,
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistText(
            'Run some jobs to see results here',
            variant: GeistTextVariant.bodySmall,
            customColor: GeistColors.gray400,
          ),
        ],
      ),
    );
  }

  StatusIndicatorState _getStatusFromType(String type) {
    switch (type.toUpperCase()) {
      case 'SUCCESS':
        return StatusIndicatorState.success;
      case 'CUSTOM':
        return StatusIndicatorState.success;
      case 'TOCHECK':
        return StatusIndicatorState.warning;
      case 'FAIL':
        return StatusIndicatorState.error;
      default:
        return StatusIndicatorState.neutral;
    }
  }

  void _exportHits(HitsDbState hitsDbState) async {
    if (hitsDbState.hits.isEmpty) {
      context.showWarningToast('No hits to export');
      return;
    }

    try {
      final success = await ref
          .read(hitsDbProvider.notifier)
          .exportHitsToTxt(
            includeProxy: true,
            includeCapturedData: true,
            includeConfig: true,
            includeDate: true,
            includeWordlist: true,
          );

      if (mounted) {
        if (success) {
          context.showSuccessToast('Hits exported successfully');
        } else {
          context.showWarningToast('Export was cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Export failed: ${e.toString()}');
      }
    }
  }
}

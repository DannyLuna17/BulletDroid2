import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bullet_droid/core/router/app_router.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';
import 'package:bullet_droid/core/components/atoms/geist_fab.dart';

import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/configs/models/config_summary.dart';

class ConfigsScreen extends ConsumerStatefulWidget {
  const ConfigsScreen({super.key});

  @override
  ConsumerState<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends ConsumerState<ConfigsScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  bool _showDeleteConfirmation = false;
  String? _configDeleteConfirmation;

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

  // Get or create animation controller for a config card
  AnimationController _getSwipeController(String configId) {
    if (!_swipeControllers.containsKey(configId)) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      );
      _swipeControllers[configId] = controller;
      _swipeAnimations[configId] = Tween<double>(
        begin: 0.0,
        end: -60.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }
    return _swipeControllers[configId]!;
  }

  // Reset swipe state for a specific config
  void _resetSwipe(String configId) {
    final controller = _swipeControllers[configId];
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
    final configsState = ref.watch(configsProvider);
    final filteredConfigs = ref.watch(filteredConfigsProvider);

    return Scaffold(
      backgroundColor: GeistColors.gray50,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: GestureDetector(
          onTap: () {
            if (_showDeleteConfirmation || _configDeleteConfirmation != null) {
              setState(() {
                _showDeleteConfirmation = false;
                _configDeleteConfirmation = null;
              });
            }
            _resetAllSwipes();
          },
          child: AppBar(
            backgroundColor: GeistColors.white,
            elevation: 0,
            title: GeistText(
              'Configs',
              variant: GeistTextVariant.headingMedium,
              customColor: GeistColors.black,
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_showDeleteConfirmation || _configDeleteConfirmation != null) {
            setState(() {
              _showDeleteConfirmation = false;
              _configDeleteConfirmation = null;
            });
          }
          _resetAllSwipes();
        },
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Statistics Header
                GestureDetector(
                  onTap: () {
                    if (_showDeleteConfirmation ||
                        _configDeleteConfirmation != null) {
                      setState(() {
                        _showDeleteConfirmation = false;
                        _configDeleteConfirmation = null;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: GeistSpacing.md,
                      right: GeistSpacing.md,
                      top: GeistSpacing.xs,
                      bottom: GeistSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: GeistColors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: GeistColors.gray200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildStatisticsHeader(configsState),
                  ),
                ),

                // Main Content
                Expanded(
                  child: _buildMainContent(configsState, filteredConfigs),
                ),
              ],
            ),

            // Floating Action Button positioned above floating navigation (responsive)
            Positioned(
              bottom: _floatingNavClearance(context),
              right: 16,
              child: _buildAddButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsHeader(ConfigsState configsState) {
    final totalConfigs = configsState.configs.length;

    return Row(
      children: [
        // Search Input
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_showDeleteConfirmation ||
                  _configDeleteConfirmation != null) {
                setState(() {
                  _showDeleteConfirmation = false;
                  _configDeleteConfirmation = null;
                });
              }
            },
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  // Search icon
                  Padding(
                    padding: EdgeInsets.only(left: 16),
                    child: Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  // Text field
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) {
                          ref
                              .read(configsProvider.notifier)
                              .updateSearchQuery(query);
                        },
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF374151),
                          fontFamily: 'Geist',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search…',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF9CA3AF),
                            fontFamily: 'Geist',
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          fillColor: GeistColors.transparent,
                          filled: true,
                          contentPadding: EdgeInsets.only(
                            left: 12,
                            right: 16,
                            top: 12,
                            bottom: 12,
                          ),
                        ),
                        cursorColor: Color(0xFF374151),
                        cursorHeight: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Delete All Button
        GestureDetector(
          onTap: configsState.configs.isEmpty
              ? null
              : () {
                  if (_showDeleteConfirmation) {
                    // Confirm deletion
                    ref.read(configsProvider.notifier).clearCache();
                    setState(() {
                      _showDeleteConfirmation = false;
                    });
                    context.showSuccessToast('All configurations deleted');
                  } else {
                    // Show confirmation
                    setState(() {
                      _showDeleteConfirmation = true;
                      _configDeleteConfirmation = null;
                    });
                  }
                },
          child: Container(
            height: 44,
            width: 88,
            padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
            decoration: BoxDecoration(
              color: _showDeleteConfirmation
                  ? GeistColors.red
                  : GeistColors.transparent,
              border: Border.all(color: GeistColors.gray300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showDeleteConfirmation ? Icons.check : Icons.delete,
                  size: 20,
                  color: _showDeleteConfirmation
                      ? GeistColors.white
                      : GeistColors.gray600,
                ),
                SizedBox(width: GeistSpacing.sm),
                GeistText(
                  'All',
                  variant: GeistTextVariant.headingMedium,
                  customColor: _showDeleteConfirmation
                      ? GeistColors.white
                      : (configsState.configs.isEmpty
                            ? GeistColors.gray400
                            : GeistColors.black),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Total Configs Pill
        GestureDetector(
          onTap: () {
            if (_showDeleteConfirmation || _configDeleteConfirmation != null) {
              setState(() {
                _showDeleteConfirmation = false;
                _configDeleteConfirmation = null;
              });
            }
          },
          child: SizedBox(
            height: 44,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
              decoration: BoxDecoration(
                color: GeistColors.gray100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: GeistColors.gray200),
              ),
              child: Center(
                child: GeistText(
                  '$totalConfigs Config${totalConfigs == 1 ? '' : 's'}',
                  variant: GeistTextVariant.bodyMedium,
                  customColor: GeistColors.gray700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(
    ConfigsState configsState,
    List<ConfigSummary> filteredConfigs,
  ) {
    if (configsState.isLoading) {
      return _buildLoadingState();
    }

    if (configsState.error != null) {
      return _buildErrorState(configsState.error!);
    }

    return _buildViewContent(configsState, filteredConfigs);
  }

  Widget _buildViewContent(
    ConfigsState configsState,
    List<ConfigSummary> filteredConfigs,
  ) {
    if (configsState.configs.isEmpty) {
      return _buildEmptyState();
    }

    return _buildListView(filteredConfigs);
  }

  Widget _buildListView(List<ConfigSummary> configs) {
    return ListView.builder(
      padding: EdgeInsets.only(
        left: GeistSpacing.md,
        right: GeistSpacing.md,
        top: GeistSpacing.md,
        bottom: GeistSpacing.md + _floatingNavClearance(context),
      ),
      itemCount: configs.length,
      itemBuilder: (context, index) {
        final config = configs[index];
        return _buildConfigListCard(config);
      },
    );
  }

  Widget _buildConfigListCard(ConfigSummary config) {
    final controller = _getSwipeController(config.id);
    final animation = _swipeAnimations[config.id]!;

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
                onTap: () {
                  ref.read(configsProvider.notifier).deleteConfig(config.id);
                  if (mounted) {
                    context.showSuccessToast(
                      'Configuration "${config.name}" deleted',
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
                    // Cancel any active confirmations first
                    if (_showDeleteConfirmation ||
                        _configDeleteConfirmation != null) {
                      setState(() {
                        _showDeleteConfirmation = false;
                        _configDeleteConfirmation = null;
                      });
                      return;
                    }
                    _resetSwipe(config.id);
                    // Navigate to details only if no confirmations are active
                    _navigateToConfigDetails(config.id);
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
                            // Header row
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GeistText(
                                        config.name,
                                        variant: GeistTextVariant.headingSmall,
                                      ),
                                      SizedBox(height: GeistSpacing.xs),
                                      GeistText(
                                        'by ${config.author}',
                                        variant: GeistTextVariant.bodyMedium,
                                        customColor: GeistColors.gray600,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: GeistSpacing.md),

                            // Status and metadata row
                            Row(
                              children: [
                                StatusIndicator(
                                  state: config.metadata['NeedsProxies'] == true
                                      ? StatusIndicatorState.success
                                      : StatusIndicatorState.neutral,
                                  size: StatusIndicatorSize.medium,
                                  label: config.metadata['NeedsProxies'] == true
                                      ? 'Proxy Required'
                                      : 'Direct Connect',
                                ),

                                SizedBox(width: GeistSpacing.md),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: GeistSpacing.sm,
                                    vertical: GeistSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: GeistColors.gray100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: GeistText(
                                    config.metadata['category']?.toString() ??
                                        'Uncategorized',
                                    variant: GeistTextVariant.bodySmall,
                                  ),
                                ),

                                const Spacer(),

                                GeistText(
                                  _formatDate(
                                    config.createdAt ?? DateTime.now(),
                                  ),
                                  variant: GeistTextVariant.bodySmall,
                                  customColor: GeistColors.gray400,
                                ),
                              ],
                            ),

                            // Description if available
                            if (config.description != null &&
                                config.description!.isNotEmpty) ...[
                              SizedBox(height: GeistSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(GeistSpacing.sm),
                                decoration: BoxDecoration(
                                  color: GeistColors.gray100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: GeistText(
                                  config.description!.length > 150
                                      ? '${config.description!.substring(0, 150)}...'
                                      : config.description!,
                                  variant: GeistTextVariant.bodySmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Tooltip(
                            message: 'Swipe left to delete this config',
                            preferBelow: false,
                            triggerMode: TooltipTriggerMode.tap,
                            child: Icon(
                              Icons.info_outline,
                              size: 18,
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
            'Loading configurations...',
            variant: GeistTextVariant.bodyMedium,
            customColor: GeistColors.gray600,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(GeistSpacing.lg),
        padding: EdgeInsets.all(GeistSpacing.lg),
        decoration: BoxDecoration(
          color: GeistColors.white,
          border: Border.all(color: GeistColors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: GeistColors.red),
            SizedBox(height: GeistSpacing.md),
            GeistText(
              'Error',
              variant: GeistTextVariant.headingSmall,
              customColor: GeistColors.red,
            ),
            SizedBox(height: GeistSpacing.sm),
            GeistText(
              error,
              variant: GeistTextVariant.bodyMedium,
              customColor: GeistColors.gray600,
            ),
            SizedBox(height: GeistSpacing.md),
            GeistButton(
              text: 'Retry',
              onPressed: () =>
                  ref.read(configsProvider.notifier).loadConfigFromFile(),
              variant: GeistButtonVariant.outline,
              size: GeistButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: GeistColors.gray400,
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistText(
            'No configurations loaded',
            variant: GeistTextVariant.headingMedium,
            customColor: GeistColors.gray600,
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistText(
            'Load your first config to get started',
            variant: GeistTextVariant.bodyMedium,
            customColor: GeistColors.gray400,
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistButton(
            text: 'Load Config File',
            onPressed: _loadConfigFromFile,
            variant: GeistButtonVariant.filled,
            size: GeistButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GeistFab(
      onPressed: _loadConfigFromFile,
      backgroundColor: GeistColors.black,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }

  double _floatingNavClearance(BuildContext context) {
    const double navHeight = 64.0;
    final double navBottomMargin = GeistSpacing.lg * 2;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double extraSpacing = GeistSpacing.lg;
    return safeBottom + navHeight + navBottomMargin + extraSpacing;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _navigateToConfigDetails(String configId) {
    context.pushNamed(AppRoute.configDetails, pathParameters: {'id': configId});
  }

  void _loadConfigFromFile() {
    ref.read(configsProvider.notifier).loadConfigFromFile();
  }
}

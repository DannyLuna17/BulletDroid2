import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/router/app_router.dart';
import 'package:bullet_droid/features/runner/presentation/runner_route_params.dart';

import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_fab.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/components/atoms/scale_tap.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/features/dashboard/providers/dashboard_provider.dart';
import 'package:bullet_droid/features/runner/providers/runner_provider.dart';
import 'package:bullet_droid/features/dashboard/models/config_execution.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showDeleteConfirmation = false;
  String? _confirmingExecutionId;

  bool get _hasAnyConfirmation =>
      _showDeleteConfirmation || _confirmingExecutionId != null;

  void _cancelAllConfirmations() {
    if (!_hasAnyConfirmation) return;
    setState(() {
      _showDeleteConfirmation = false;
      _confirmingExecutionId = null;
    });
  }

  Future<void> _openGithubRepo() async {
    final uri = Uri.parse('https://github.com/DannyLuna17/BulletDroid2');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback without mode if external application is not available
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configExecutions = ref.watch(configExecutionsProvider);
    final theme = Theme.of(context);
    final isMobile = GeistBreakpoints.isMobile(context);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (_hasAnyConfirmation) {
            _cancelAllConfirmations();
          }
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  snap: false,
                  elevation: 0,
                  backgroundColor: GeistColors.white,
                  foregroundColor: theme.colorScheme.onSurface,
                  toolbarHeight: isMobile ? 40 : 100,
                  expandedHeight: isMobile ? 40 : 100,
                  title: _buildHeader(context, ref, isMobile),
                  centerTitle: false,
                ),

                // Action buttons section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? GeistSpacing.md : GeistSpacing.lg,
                      vertical: GeistSpacing.md,
                    ),
                    child: isMobile
                        ? _buildMobileActions(context, ref)
                        : _buildDesktopActions(context, ref),
                  ),
                ),

                // Dashboard content
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? GeistSpacing.md : GeistSpacing.lg,
                  ),
                  sliver: _buildDashboardContent(
                    context,
                    ref,
                    configExecutions,
                    isMobile,
                  ),
                ),

                // Bottom padding for floating navigation (responsive)
                SliverToBoxAdapter(
                  child: SizedBox(height: _floatingNavClearance(context)),
                ),
              ],
            ),

            Positioned(
              bottom: _floatingNavClearance(context),
              right: 16,
              child: GeistFab(
                onPressed: () async {
                  await ref
                      .read(configExecutionsProvider.notifier)
                      .addPlaceholder();
                },
                backgroundColor: GeistColors.black,
                foregroundColor: GeistColors.white,
                tooltip: 'Add Config',
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _floatingNavClearance(BuildContext context) {
    const double navHeight = 64.0;
    final double navBottomMargin = GeistSpacing.lg * 2;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    final double extraSpacing = GeistSpacing.lg;
    return safeBottom + navHeight + navBottomMargin + extraSpacing;
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isMobile) {
    final iconSize = isMobile ? 24.0 : 28.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GeistText.headingLarge(
          'BulletDroid',
          color: GeistTextColor.primary,
          customColor: Theme.of(context).colorScheme.onSurface,
        ),
        SizedBox(width: GeistSpacing.xs),
        Tooltip(
          message: 'Open GitHub repository',
          child: ScaleTap(
            onTap: _openGithubRepo,
            child: Padding(
              padding: EdgeInsets.all(GeistSpacing.xs),
              child: Image.asset(
                'assets/icons/github-logo.png',
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopActions(BuildContext context, WidgetRef ref) {
    final double buttonFontSize = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: 12.0,
      mobileLarge: 12.5,
      tablet: 13.0,
      tabletLarge: 14.0,
      desktop: 15.0,
      desktopLarge: 16.0,
      desktopXL: 16.0,
    );
    final double buttonIconSize = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: 18.0,
      mobileLarge: 19.0,
      tablet: 20.0,
      tabletLarge: 21.0,
      desktop: 22.0,
      desktopLarge: 24.0,
      desktopXL: 24.0,
    );

    return Row(
      children: [
        GeistButton(
          text: 'Start All',
          variant: GeistButtonVariant.filled,
          icon: Icon(Icons.play_arrow),
          fontSize: buttonFontSize,
          iconSize: buttonIconSize,
          onPressed: () async {
            if (_hasAnyConfirmation) {
              _cancelAllConfirmations();
              return;
            }
            final isolatePool = ref.read(isolatePoolProvider);
            if (isolatePool.isInitializing) {
              context.showInfoToast('Initializing runners...');
            }
            await ref.read(configExecutionsProvider.notifier).startAll();
          },
        ),
        SizedBox(width: GeistSpacing.sm),
        GeistButton(
          text: 'Stop All',
          variant: GeistButtonVariant.outline,
          icon: Icon(Icons.stop),
          fontSize: buttonFontSize,
          iconSize: buttonIconSize,
          onPressed: () async {
            if (_hasAnyConfirmation) {
              _cancelAllConfirmations();
              return;
            }
            await ref.read(configExecutionsProvider.notifier).stopAll();
          },
        ),
        SizedBox(width: GeistSpacing.sm),
        GeistButton(
          text: 'Delete All',
          variant: GeistButtonVariant.ghost,
          icon: Icon(
            _showDeleteConfirmation ? Icons.check : Icons.delete_sweep,
          ),
          fontSize: buttonFontSize,
          iconSize: buttonIconSize,
          onPressed: () {
            if (_confirmingExecutionId != null) {
              _cancelAllConfirmations();
              return;
            }
            if (_showDeleteConfirmation) {
              // Confirm deletion
              ref.read(configExecutionsProvider.notifier).deleteAll();
              setState(() {
                _showDeleteConfirmation = false;
              });
              context.showSuccessToast('All configurations deleted');
            } else {
              // Show confirmation
              setState(() {
                _showDeleteConfirmation = true;
                _confirmingExecutionId = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildMobileActions(BuildContext context, WidgetRef ref) {
    final double baseFontSize = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: 11.0,
      mobileLarge: 12.0,
      tablet: 13.0,
    );
    final double baseIconSize = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: 17.0,
      mobileLarge: 19.0,
      tablet: 21.0,
    );

    final double deleteFontSize = (baseFontSize - 1).clamp(10.0, 18.0);
    final double deleteIconSize = (baseIconSize - 2).clamp(12.0, 24.0);

    return Row(
      children: [
        Expanded(
          child: GeistButton(
            text: 'Start All',
            fontSize: baseFontSize,
            iconSize: baseIconSize,
            variant: GeistButtonVariant.filled,
            icon: Icon(Icons.play_arrow),
            onPressed: () async {
              if (_hasAnyConfirmation) {
                _cancelAllConfirmations();
                return;
              }
              final isolatePool = ref.read(isolatePoolProvider);
              if (isolatePool.isInitializing) {
                context.showInfoToast('Initializing runners...');
              }
              await ref.read(configExecutionsProvider.notifier).startAll();
            },
          ),
        ),
        SizedBox(width: GeistSpacing.sm),
        Expanded(
          child: GeistButton(
            text: 'Stop All',
            fontSize: baseFontSize,
            iconSize: baseIconSize,
            variant: GeistButtonVariant.outline,
            icon: Icon(Icons.stop),
            onPressed: () async {
              if (_hasAnyConfirmation) {
                _cancelAllConfirmations();
                return;
              }
              await ref.read(configExecutionsProvider.notifier).stopAll();
            },
          ),
        ),
        SizedBox(width: GeistSpacing.sm),
        Expanded(
          child: GeistButton(
            text: 'Delete All',
            fontSize: deleteFontSize,
            iconSize: deleteIconSize,
            variant: GeistButtonVariant.filled,
            icon: Icon(
              _showDeleteConfirmation ? Icons.check : Icons.delete_sweep,
            ),
            onPressed: () {
              if (_confirmingExecutionId != null) {
                _cancelAllConfirmations();
                return;
              }
              if (_showDeleteConfirmation) {
                // Confirm deletion
                ref.read(configExecutionsProvider.notifier).deleteAll();
                setState(() {
                  _showDeleteConfirmation = false;
                });
                context.showSuccessToast('All configurations deleted');
              } else {
                // Show confirmation
                setState(() {
                  _showDeleteConfirmation = true;
                  _confirmingExecutionId = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    WidgetRef ref,
    List<ConfigExecution> configExecutions,
    bool isMobile,
  ) {
    if (configExecutions.isEmpty) {
      return SliverFillRemaining(child: _buildEmptyState(context));
    }

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final execution = configExecutions[index];
          return Padding(
            padding: EdgeInsets.only(bottom: GeistSpacing.md),
            child: _buildConfigExecutionCard(context, ref, execution, isMobile),
          );
        }, childCount: configExecutions.length),
      );
    } else {
      return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: GeistSpacing.md,
          mainAxisSpacing: GeistSpacing.md,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final execution = configExecutions[index];
          return _buildConfigExecutionCard(context, ref, execution, isMobile);
        }, childCount: configExecutions.length),
      );
    }
  }

  Widget _buildConfigExecutionCard(
    BuildContext context,
    WidgetRef ref,
    ConfigExecution execution,
    bool isMobile,
  ) {
    return _AnimatedConfigCard(
      execution: execution,
      confirmingExecutionId: _confirmingExecutionId,
      isGlobalDeleteAllConfirming: _showDeleteConfirmation,
      onSetConfirming: (id) {
        setState(() {
          _confirmingExecutionId = id;
          _showDeleteConfirmation = false;
        });
      },
      onCancelConfirmations: _cancelAllConfirmations,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistText.headingMedium(
            'No configs running',
            color: GeistTextColor.secondary,
            customColor: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          SizedBox(height: GeistSpacing.sm),
          GeistText.bodyMedium(
            'Start by adding a configuration to monitor its execution.',
            color: GeistTextColor.tertiary,
            customColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: GeistSpacing.lg),
          GeistButton(
            text: 'Go to Configs',
            variant: GeistButtonVariant.outline,
            icon: Icon(Icons.arrow_forward),
            onPressed: () => context.go(AppPath.configs),
          ),
        ],
      ),
    );
  }
}

// Animated Config Card Widget
class _AnimatedConfigCard extends ConsumerStatefulWidget {
  final ConfigExecution execution;

  final String? confirmingExecutionId;
  final bool isGlobalDeleteAllConfirming;
  final void Function(String executionId) onSetConfirming;
  final VoidCallback onCancelConfirmations;

  const _AnimatedConfigCard({
    required this.execution,
    required this.confirmingExecutionId,
    required this.isGlobalDeleteAllConfirming,
    required this.onSetConfirming,
    required this.onCancelConfirmations,
  });

  @override
  ConsumerState<_AnimatedConfigCard> createState() =>
      _AnimatedConfigCardState();
}

class _AnimatedConfigCardState extends ConsumerState<_AnimatedConfigCard>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _statusController;
  late AnimationController _progressController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _statusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _setupAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entryController.forward();
      if (!widget.execution.isPlaceholder) {
        _progressController.repeat();
      }
    });
  }

  void _setupAnimations() {
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
        );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    _colorAnimation = ColorTween(
      begin: GeistColors.gray100,
      end: widget.execution.isRunning
          ? GeistColors.successColorSubtle
          : GeistColors.gray50,
    ).animate(_statusController);

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  // Computes a font size that decreases as the numeric magnitude grows.
  double _adaptiveMetricFontSize(String value) {
    const double baseSize = 18.0;
    const double minSize = 12.0;

    final digitMatches = RegExp(r"\d+").allMatches(value);
    int totalDigits = 0;
    for (final match in digitMatches) {
      totalDigits += match.group(0)!.length;
    }

    if (totalDigits <= 0) {
      return baseSize;
    }

    final double decrement = (totalDigits - 3).clamp(0, 100) * 1.2;
    final double computed = baseSize - decrement;
    return computed.clamp(minSize, baseSize);
  }

  @override
  void didUpdateWidget(_AnimatedConfigCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate status changes
    if (oldWidget.execution.isRunning != widget.execution.isRunning) {
      _statusController.reset();
      _statusController.forward();

      if (widget.execution.isRunning) {
        _progressController.repeat();
      } else {
        _progressController.stop();
      }
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _statusController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Container(
                constraints: const BoxConstraints(maxWidth: 600),
                margin: EdgeInsets.all(GeistSpacing.xs),
                child: _buildModernCard(context),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(BuildContext context) {
    final execution = widget.execution;
    final isMobile = GeistBreakpoints.isMobile(context);
    final bool isConfirming = widget.confirmingExecutionId == execution.id;

    return Container(
      decoration: BoxDecoration(
        color: GeistColors.white,
        borderRadius: BorderRadius.circular(GeistBorders.radiusLarge + 5),
        border: Border.all(
          color: execution.isRunning
              ? GeistColors.successColor.withValues(alpha: 0.3)
              : GeistColors.gray200,
          width: execution.isRunning ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: GeistColors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: GeistColors.transparent,
        child: InkWell(
          onTap: () {
            // If any confirmation is active, cancel and do nothing else
            if (isConfirming || widget.isGlobalDeleteAllConfirming) {
              widget.onCancelConfirmations();
              return;
            }

            if (execution.isPlaceholder) {
              context.goNamed(
                AppRoute.runner,
                queryParameters: RunnerRouteParams(
                  placeholderId: execution.id,
                  source: RunnerSource.placeholder,
                ).toQueryParameters(),
              );
            } else {
              final runnerId = execution.runnerId ?? execution.id;
              context.goNamed(
                AppRoute.runner,
                queryParameters: RunnerRouteParams(
                  placeholderId: runnerId,
                  configId: execution.configId,
                  source: RunnerSource.existing,
                ).toQueryParameters(),
              );
            }
          },
          borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
          child: Padding(
            padding: EdgeInsets.only(
              left: GeistSpacing.md,
              right: GeistSpacing.md,
              top: 0,
              bottom: GeistSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section
                _buildCardHeader(execution, isMobile),

                SizedBox(height: GeistSpacing.sm / 2),

                // Status and metrics section
                _buildStatusMetrics(execution),

                SizedBox(height: GeistSpacing.sm / 2),

                // Hit indicators section
                if (!execution.isPlaceholder) ...[
                  _buildHitIndicators(execution),
                  SizedBox(height: GeistSpacing.sm / 2),
                ],

                // Actions section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildActions(execution, isMobile),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(ConfigExecution execution, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and subtitle
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(top: GeistSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GeistText.headingMedium(
                  execution.configName,
                  color: GeistTextColor.primary,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: GeistSpacing.xs),
              ],
            ),
          ),
        ),

        SizedBox(width: GeistSpacing.sm),

        // Badges row
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!execution.isPlaceholder) ...[_buildProgressBadge(execution)],
            _buildModernStatusIndicator(execution),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusMetrics(ConfigExecution execution) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GeistBorders.radiusMedium),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Progress
          Expanded(
            child: _buildLargerMetricItem(
              label: 'Progress',
              value: execution.isPlaceholder
                  ? '–/–'
                  : execution.progressFraction,
            ),
          ),

          SizedBox(width: GeistSpacing.sm),

          // CPM
          Expanded(
            child: _buildLargerMetricItem(
              label: 'CPM',
              value: execution.isPlaceholder ? '–' : execution.cpm.toString(),
            ),
          ),

          SizedBox(width: GeistSpacing.sm),

          // Bots
          Expanded(
            child: _buildLargerMetricItem(
              label: 'Bots',
              value: execution.isPlaceholder
                  ? '–'
                  : execution.totalBots.toString(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargerMetricItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GeistText.labelMedium(
          label,
          color: GeistTextColor.tertiary,
          textAlign: TextAlign.center,
          fontSize: 13,
        ),
        SizedBox(height: GeistSpacing.xs / 2),
        GeistText.headingSmall(
          value,
          color: GeistTextColor.primary,
          fontWeight: FontWeight.bold,
          fontSize: _adaptiveMetricFontSize(value),
        ),
      ],
    );
  }

  Widget _buildProgressBadge(ConfigExecution execution) {
    final double horizontalPadding = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: GeistSpacing.xs,
      mobileLarge: GeistSpacing.sm,
      tablet: GeistSpacing.sm,
      desktop: GeistSpacing.sm,
    );
    final double verticalPadding = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: GeistSpacing.xs / 2,
      mobileLarge: GeistSpacing.xs,
      tablet: GeistSpacing.xs,
      desktop: GeistSpacing.xs,
    );
    final double labelFontSize = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: 12.0,
      mobileLarge: 13.0,
      tablet: 14.0,
      desktop: 15.0,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: GeistColors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(GeistBorders.radiusSmall),
        border: Border.all(color: GeistColors.blue.withValues(alpha: 0.2)),
      ),
      child: GeistText.labelSmall(
        execution.progressPercentageString,
        color: GeistTextColor.primary,
        fontWeight: FontWeight.w500,
        fontSize: labelFontSize,
      ),
    );
  }

  Widget _buildModernStatusIndicator(ConfigExecution execution) {
    Color statusColor;
    String statusText;

    if (execution.isPlaceholder) {
      statusColor = GeistColors.gray400;
      statusText = 'Idle';
    } else if (execution.validationError != null && !execution.isConfigured) {
      statusColor = GeistColors.red;
      statusText = 'Config Required';
    } else if (execution.isRunning) {
      statusColor = GeistColors.successColor;
      statusText = 'Running';
    } else {
      statusColor = GeistColors.gray400;
      statusText = 'Stopped';
    }

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedOpacity = execution.isRunning
            ? 0.6 + 0.4 * _progressAnimation.value
            : 1.0;

        final double horizontalPadding = GeistBreakpoints.getResponsiveValue(
          context,
          mobile: GeistSpacing.xs,
          mobileLarge: GeistSpacing.sm,
          tablet: GeistSpacing.sm,
          desktop: GeistSpacing.sm,
        );
        final double verticalPadding = GeistBreakpoints.getResponsiveValue(
          context,
          mobile: GeistSpacing.xs / 2,
          mobileLarge: GeistSpacing.xs,
          tablet: GeistSpacing.xs,
          desktop: GeistSpacing.xs,
        );
        final double dotSize = GeistBreakpoints.getResponsiveValue(
          context,
          mobile: 6.0,
          mobileLarge: 7.0,
          tablet: 8.0,
          desktop: 8.0,
          desktopLarge: 9.0,
        );
        final double labelFontSize = GeistBreakpoints.getResponsiveValue(
          context,
          mobile: 12.0,
          mobileLarge: 13.0,
          tablet: 14.0,
          desktop: 14.0,
          desktopLarge: 15.0,
        );

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(GeistBorders.radiusSmall),
            border: Border.all(color: statusColor.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: animatedOpacity),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: GeistSpacing.xs),
              GeistText.labelSmall(
                statusText,
                color: GeistTextColor.primary,
                fontWeight: FontWeight.w500,
                fontSize: labelFontSize,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHitIndicators(ConfigExecution execution) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildModernHitIndicator(
            color: GeistColors.successColor,
            count: execution.good,
            label: 'Hits',
            isAnimated: execution.isRunning,
          ),
          _buildModernHitIndicator(
            color: GeistColors.amber,
            count: execution.custom,
            label: 'Custom',
            isAnimated: execution.isRunning,
          ),
          _buildModernHitIndicator(
            color: GeistColors.red,
            count: execution.bad,
            label: 'Bad',
            isAnimated: execution.isRunning,
          ),
          _buildModernHitIndicator(
            color: GeistColors.blue,
            count: execution.toCheck,
            label: 'ToCheck',
            isAnimated: execution.isRunning,
          ),
        ],
      ),
    );
  }

  Widget _buildModernHitIndicator({
    required Color color,
    required int count,
    required String label,
    required bool isAnimated,
  }) {
    final double horizontalPadding = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: GeistSpacing.xs,
      mobileLarge: GeistSpacing.sm,
      tablet: GeistSpacing.sm,
      desktop: GeistSpacing.sm,
    );
    final double verticalPadding = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: GeistSpacing.xs / 3,
      mobileLarge: GeistSpacing.xs / 2,
      tablet: GeistSpacing.xs / 2,
      desktop: GeistSpacing.xs / 2,
    );
    final double fontSize = GeistBreakpoints.getResponsiveValue(
      context,
      mobile: 13.0,
      mobileLarge: 14.0,
      tablet: 15.0,
      desktop: 16.0,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GeistText.labelSmall(
            label,
            color: GeistTextColor.primary,
            customColor: GeistColors.white,
            fontWeight: FontWeight.w600,
            fontSize: fontSize,
          ),
          SizedBox(width: GeistSpacing.xs / 2),
          GeistText.labelSmall(
            count.toString(),
            color: GeistTextColor.primary,
            customColor: GeistColors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(ConfigExecution execution, bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - GeistSpacing.sm) / 2;
        final bool isConfirming = widget.confirmingExecutionId == execution.id;

        return Row(
          children: [
            // Start/Stop button
            SizedBox(
              width: buttonWidth,
              child: GeistButton(
                text: execution.isPlaceholder
                    ? 'Configure'
                    : (execution.isRunning ? 'Stop' : 'Start'),
                variant: execution.isPlaceholder
                    ? GeistButtonVariant.filled
                    : (execution.isRunning
                          ? GeistButtonVariant.outline
                          : GeistButtonVariant.filled),
                size: GeistButtonSize.small,
                height: 36,
                fontSize: 14.5,
                iconSize: 19,
                icon: Icon(
                  execution.isPlaceholder
                      ? Icons.settings
                      : (execution.isRunning ? Icons.stop : Icons.play_arrow),
                ),
                onPressed: () async {
                  // If any confirmation is active, cancel and do nothing else
                  if (widget.isGlobalDeleteAllConfirming ||
                      widget.confirmingExecutionId != null) {
                    widget.onCancelConfirmations();
                    return;
                  }
                  if (execution.isPlaceholder) {
                    // Navigate to runner screen for configuration
                    context.goNamed(
                      AppRoute.runner,
                      queryParameters: RunnerRouteParams(
                        placeholderId: execution.id,
                        source: RunnerSource.placeholder,
                      ).toQueryParameters(),
                    );
                  } else if (execution.isRunning) {
                    await ref
                        .read(configExecutionsProvider.notifier)
                        .stopExecution(execution.id);
                  } else {
                    await ref
                        .read(configExecutionsProvider.notifier)
                        .refreshExecutionStatus(execution.id);
                    if (!mounted) return;

                    // Get updated execution state
                    final updatedExecution = ref
                        .read(configExecutionsProvider)
                        .firstWhere((e) => e.id == execution.id);

                    if (!updatedExecution.isConfigured &&
                        updatedExecution.validationError != null) {
                      // If engine still initializing, do not navigate
                      final pool = ref.read(isolatePoolProvider);
                      if (pool.isInitializing || !pool.isReady) {
                        if (!context.mounted) return;
                        context.showInfoToast('Initializing runners...');
                        return;
                      }
                      // Check if context is still mounted before using it
                      if (!context.mounted) return;

                      context.showErrorToast(updatedExecution.validationError!);
                      // Navigate to runner configuration if not configured
                      context.goNamed(
                        AppRoute.runner,
                        queryParameters: RunnerRouteParams(
                          placeholderId: updatedExecution.runnerId,
                          configId: updatedExecution.configId,
                          source: RunnerSource.dashboard,
                        ).toQueryParameters(),
                      );
                      return;
                    }

                    try {
                      await ref
                          .read(configExecutionsProvider.notifier)
                          .startExecution(execution.id);
                      if (!mounted) return;
                    } catch (e) {
                      // Check if context is still mounted before using it
                      if (!context.mounted) return;
                      context.showErrorToast(
                        'Failed to start: ${e.toString()}',
                      );
                    }
                  }
                },
              ),
            ),

            SizedBox(width: GeistSpacing.sm),

            // Delete button
            SizedBox(
              width: buttonWidth,
              child: GeistButton(
                text: 'Delete',
                variant: GeistButtonVariant.ghost,
                size: GeistButtonSize.small,
                height: 36,
                fontSize: 14.5,
                iconSize: 19,
                icon: Icon(isConfirming ? Icons.check : Icons.delete),
                onPressed: () {
                  if (widget.isGlobalDeleteAllConfirming) {
                    // If global delete-all confirmation is active, cancel and return
                    widget.onCancelConfirmations();
                    return;
                  }
                  if (isConfirming) {
                    // Confirm deletion
                    if (execution.isPlaceholder) {
                      ref
                          .read(configExecutionsProvider.notifier)
                          .removePlaceholder(execution.id);
                    } else {
                      ref
                          .read(configExecutionsProvider.notifier)
                          .deleteExecution(execution.id);
                    }
                    widget.onCancelConfirmations();
                    context.showSuccessToast('Configuration deleted');
                  } else {
                    widget.onSetConfirming(execution.id);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

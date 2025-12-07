import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/shared/utils/wordlist_utils.dart';
import 'dart:convert';
import 'package:go_router/go_router.dart';
import 'package:bullet_droid/core/router/app_router.dart';
import 'dart:io';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/scale_tap.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bullet_droid/features/runner/providers/runner_provider.dart';
import 'package:bullet_droid/features/configs/providers/configs_provider.dart';
import 'package:bullet_droid/features/wordlists/providers/wordlists_provider.dart';
import 'package:bullet_droid/features/wordlists/providers/custom_wordlist_types_provider.dart';
import 'package:bullet_droid/features/wordlists/models/custom_wordlist_type.dart';

import 'package:bullet_droid/features/runner/models/job_params.dart';
import 'package:bullet_droid/features/runner/models/runner_instance.dart';
import 'package:bullet_droid/features/runner/presentation/widgets/data_table.dart';
import 'package:bullet_droid/features/runner/presentation/widgets/live_stats_panel.dart';
import 'package:bullet_droid/features/runner/presentation/widgets/runner_controls.dart';
import 'package:bullet_droid/features/runner/presentation/widgets/collapse_button.dart';
import 'package:bullet_droid/shared/providers/custom_input_provider.dart';
import 'package:bullet_droid/features/runner/services/runner_ui_state_service.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';

/// Runner screen manages one runner instance and syncs its live progress back to the dashboard card.
class RunnerScreen extends ConsumerStatefulWidget {
  final String? placeholderId;
  final String? configId;
  final String? source;

  const RunnerScreen({
    super.key,
    this.placeholderId,
    this.configId,
    this.source,
  });

  @override
  ConsumerState<RunnerScreen> createState() => _RunnerScreenState();
}

class _RunnerScreenState extends ConsumerState<RunnerScreen>
    with SingleTickerProviderStateMixin {
  bool _isBottomSectionExpanded = true;
  bool _isDisposed = false;

  late TextEditingController _startCountController;
  late TextEditingController _botsCountController;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _startCountController = TextEditingController(text: '1');
    _botsCountController = TextEditingController(text: '1');

    // Load the expanded state from Hive
    _loadExpandedState();

    // Initialize with context-aware parameters
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final runnerId = widget.placeholderId ?? 'default';
      final context = _determineRunnerContext();
      await ref
          .read(multiRunnerProvider.notifier)
          .initializeWithContextForRunner(runnerId, context, widget.configId);

      // Update controllers with provider values after context initialization
      final runnerInstance = ref.read(runnerInstanceProvider(runnerId));
      if (runnerInstance != null) {
        _startCountController.text = runnerInstance.startCount.toString();
        _botsCountController.text = runnerInstance.botsCount.toString();
      }

      // If coming from placeholder, initialize dashboard card
      if (widget.placeholderId != null) {
        _updateDashboardCard();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _isDisposed = true;

    _startCountController.dispose();
    _botsCountController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openGithubRepo() async {
    final uri = Uri.parse('https://github.com/DannyLuna17/BulletDroid2');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri);
    }
  }

  void _loadExpandedState() {
    final service = ref.read(runnerUiStateServiceProvider);
    final expanded = service.getBottomExpanded(defaultValue: true);
    setState(() {
      _isBottomSectionExpanded = expanded;
    });
  }

  Future<void> _toggleExpandedState() async {
    setState(() {
      _isBottomSectionExpanded = !_isBottomSectionExpanded;
    });
    final service = ref.read(runnerUiStateServiceProvider);
    await service.setBottomExpanded(_isBottomSectionExpanded);
  }

  void _handleStartCountInput(String value) {
    final runnerId = widget.placeholderId ?? 'default';
    final newValue = int.tryParse(value);
    if (newValue == null) {
      _startCountController.text = '0';
      return;
    }
    if (newValue >= 0 && newValue <= 999) {
      ref
          .read(multiRunnerProvider.notifier)
          .updateStartCountForRunner(runnerId, newValue);
    } else if (value.isEmpty) {
      ref
          .read(multiRunnerProvider.notifier)
          .updateStartCountForRunner(runnerId, 1);
      _startCountController.text = '1';
    }
  }

  void _handleBotsCountInput(String value) {
    final runnerId = widget.placeholderId ?? 'default';
    final newValue = int.tryParse(value);
    if (newValue == null) {
      _botsCountController.text = '0';
      return;
    }
    if (newValue >= 0 && newValue <= 200) {
      ref
          .read(multiRunnerProvider.notifier)
          .updateBotsCountForRunner(runnerId, newValue);
      _updateDashboardCard();
    } else if (value.isEmpty) {
      ref
          .read(multiRunnerProvider.notifier)
          .updateBotsCountForRunner(runnerId, 1);
      _botsCountController.text = '1';
      _updateDashboardCard();
    }
  }

  Future<void> _updateDashboardCard() async {
    if (widget.placeholderId == null) return;
    await ref
        .read(multiRunnerProvider.notifier)
        .updateDashboardParametersFromRunner(widget.placeholderId!);
  }

  @override
  Widget build(BuildContext context) {
    final runnerId = widget.placeholderId ?? 'default';
    final runnerInstance = ref.watch(runnerInstanceProvider(runnerId));

    // Keep Start At input in sync with provider when runner stops or value changes
    ref.listen<RunnerInstance?>(runnerInstanceProvider(runnerId), (prev, next) {
      if (_isDisposed || !mounted) return;
      if (next == null) return;
      // Only update text when not running to avoid conflicting with disabled state
      if (!next.isRunning) {
        final currentText = _startCountController.text;
        final desiredText = next.startCount.toString();
        if (currentText != desiredText) {
          _startCountController.text = desiredText;
        }
      }
    });

    return Scaffold(
      backgroundColor: GeistColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          toolbarHeight: 60,
          backgroundColor: GeistColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              size: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppPath.dashboard);
              }
            },
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'BulletDroid',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                ),
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
                      width: 26,
                      height: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          // Main content area with tabs
          Expanded(
            child: Stack(
              children: [
                // Main data table
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: _isBottomSectionExpanded
                      ? _bottomSectionHeightExpanded
                      : _bottomSectionHeightCollapsed,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: GeistColors.gray200),
                      ),
                    ),
                    child: RunnerDataTable(
                      tabController: _tabController,
                      runnerId: runnerId,
                      showProxyColumn:
                          runnerInstance?.useProxies == true &&
                          runnerInstance?.selectedProxies != 'Off',
                    ),
                  ),
                ),

                // Collapse button, positioned at border between table and tabs (half visible)
                Positioned(
                  bottom: (_isBottomSectionExpanded
                      ? _bottomSectionHeightExpanded + _collapseButtonOverlap
                      : _bottomSectionHeightCollapsed + _collapseButtonOverlap),
                  right: 16,
                  child: CollapseButton(
                    isExpanded: _isBottomSectionExpanded,
                    onTap: _toggleExpandedState,
                  ),
                ),

                // Bottom section
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: _isBottomSectionExpanded
                      ? _bottomSectionHeightExpanded
                      : _bottomSectionHeightCollapsed,
                  child: _buildBottomSection(runnerId, runnerInstance),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(String runnerId, RunnerInstance? runnerInstance) {
    return Container(
      decoration: BoxDecoration(
        color: GeistColors.gray50,
        boxShadow: [
          BoxShadow(
            color: GeistColors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab Bar with integrated CPM indicator
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: GeistColors.white,
              border: Border(bottom: BorderSide(color: GeistColors.gray200)),
            ),
            child: Row(
              children: [
                // CPM Indicator
                Container(
                  height: 44,
                  padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
                  decoration: BoxDecoration(
                    color: GeistColors.gray50,
                    border: Border(
                      right: BorderSide(color: GeistColors.gray200),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, size: 16, color: GeistColors.gray600),
                      SizedBox(width: GeistSpacing.xs),
                      GeistText(
                        'CPM: ${runnerInstance?.currentCpm ?? 0}',
                        variant: GeistTextVariant.bodyMedium,
                        fontWeight: FontWeight.w600,
                        customColor: GeistColors.gray700,
                      ),
                    ],
                  ),
                ),
                // Tab Bar
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: GeistColors.black,
                    unselectedLabelColor: GeistColors.gray600,
                    indicatorColor: GeistColors.black,
                    indicatorWeight: 2,
                    labelStyle: TextStyle(
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Geist',
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    tabs: const [
                      Tab(text: 'Bots'),
                      Tab(text: 'Hits'),
                      Tab(text: 'Custom'),
                      Tab(text: 'ToCheck'),
                      Tab(text: 'Logs'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Always show stats, but compact when collapsed
          LiveStatsPanel(runnerId: runnerId),

          // Scrollable content area when expanded
          if (_isBottomSectionExpanded)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (runnerInstance != null)
                      RunnerControls(
                        runnerId: runnerId,
                        runnerInstance: runnerInstance,
                        startCountController: _startCountController,
                        botsCountController: _botsCountController,
                        onStartCountChanged: _handleStartCountInput,
                        onBotsCountChanged: _handleBotsCountInput,
                        onStartPressed: _startJob,
                        onStopPressed: () => ref
                            .read(multiRunnerProvider.notifier)
                            .stopJobForRunner(runnerId),
                        onUpdateDashboard: _updateDashboardCard,
                      )
                    else
                      const Center(child: Text('Runner not initialized')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  double get _bottomSectionHeightExpanded {
    final double base = 370;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    return base + (safeBottom > 0 ? safeBottom / 2 : 0);
  }

  double get _bottomSectionHeightCollapsed {
    final double base = 190;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    return base + (safeBottom > 0 ? safeBottom / 2 : 0);
  }

  double get _collapseButtonOverlap => -11.0;

  Future<void> _startJob() async {
    try {
      final runnerId = widget.placeholderId ?? 'default';
      final runnerInstance = ref.read(runnerInstanceProvider(runnerId));
      final configsState = ref.read(configsProvider);
      final wordlistsState = ref.read(wordlistsProvider);

      if (runnerInstance == null) {
        context.showErrorToast('Runner not initialized');
        return;
      }

      if (runnerInstance.selectedConfigId == null) {
        context.showErrorToast('Please select a config');
        return;
      }

      final config = configsState.configs.firstWhere(
        (c) => c.id == runnerInstance.selectedConfigId,
      );

      if (runnerInstance.selectedWordlistId == null) {
        context.showErrorToast('Please select a wordlist');
        return;
      }

      final wordlist = wordlistsState.wordlists.firstWhere(
        (w) => w.id == runnerInstance.selectedWordlistId,
      );

      // Validate wordlist type against config requirement
      final allowedTypes = _allowedWordlistTypes(config.metadata);
      if (allowedTypes.isNotEmpty && !allowedTypes.contains(wordlist.type)) {
        context.showErrorToast(
          'Selected wordlist type "${wordlist.type}" is not allowed for this config. Allowed: ${allowedTypes.join(", ")}',
        );
        return;
      }

      // Read and process wordlist file content
      final wordlistFile = File(wordlist.path);
      final rawLines = await WordlistUtils.readAndProcessFile(wordlistFile);

      // Apply custom wordlist type parsing if applicable
      List<String> dataLines = rawLines;
      CustomWordlistType? customType;
      for (final t in ref.read(customWordlistTypesProvider).types) {
        if (t.name == wordlist.type) {
          customType = t;
          break;
        }
      }

      if (customType != null) {
        dataLines = _parseCustomWordlistLines(rawLines, customType);
      }

      if (dataLines.isEmpty) {
        if (mounted) {
          context.showErrorToast('No valid data lines found in wordlist');
        }
        return;
      }

      // Get custom input values for the job
      final customInputValues = await ref
          .read(customInputProvider.notifier)
          .getCustomInputsForJob(config.id);

      // Build proxy list if proxies are enabled
      List<String> proxyStrings = [];
      if (runnerInstance.useProxies) {
        final proxiesState = ref.read(proxiesProvider);
        final eligibleProxies = [
          ...proxiesState.aliveProxies,
          ...proxiesState.untestedProxies,
        ];

        if (eligibleProxies.isEmpty) {
          if (mounted) {
            context.showErrorToast(
              'No eligible proxies (alive/untested) available',
            );
          }
          return;
        }

        proxyStrings = eligibleProxies.map((p) {
          final hasUser = (p.username != null && p.username!.isNotEmpty);
          final hasPass = (p.password != null && p.password!.isNotEmpty);
          if (hasUser && hasPass) {
            return '${p.address}:${p.port}:${p.username}:${p.password}';
          }
          return '${p.address}:${p.port}';
        }).toList();
      }

      // Create job parameters
      final jobParams = JobParams(
        configId: config.id,
        configPath: config.filePath,
        dataLines: dataLines,
        threads: runnerInstance.botsCount,
        startIndex: runnerInstance.startCount - 1,
        useProxies: runnerInstance.useProxies,
        proxies: runnerInstance.useProxies ? proxyStrings : [],
        customInputs: customInputValues,
      );

      // Start the job
      await ref
          .read(multiRunnerProvider.notifier)
          .startJobForRunner(runnerId, jobParams);
    } catch (e) {
      if (mounted) {
        context.showErrorToast('Failed to start job: $e');
      }
    }
  }

  // Helper to determine runner context based on source parameter
  RunnerContext _determineRunnerContext() {
    if (widget.source == 'placeholder') {
      return RunnerContext.placeholder;
    } else if (widget.source == 'config') {
      return RunnerContext.configNew;
    } else if (widget.source == 'existing') {
      return RunnerContext.configExisting;
    } else {
      return RunnerContext.configExisting;
    }
  }

  List<String> _allowedWordlistTypes(Map<String, dynamic> metadata) {
    final w1 = metadata['AllowedWordlist1']?.toString().trim() ?? '';
    final w2 = metadata['AllowedWordlist2']?.toString().trim() ?? '';
    return [w1, w2].where((w) => w.isNotEmpty).toList();
  }

  List<String> _parseCustomWordlistLines(
    List<String> lines,
    CustomWordlistType type,
  ) {
    final List<String> parsed = [];
    // int matched = 0;
    // int skipped = 0;
    RegExp? regExp;
    try {
      regExp = RegExp(type.regex);
    } catch (_) {
      return [];
    }

    for (final line in lines) {
      Map<String, String>? sliceMap;

      final match = regExp.firstMatch(line);
      if (match != null && match.start != match.end) {
        final captures = <String>[];
        if (match.groupCount > 0) {
          for (int i = 1; i <= match.groupCount; i++) {
            captures.add(match.group(i) ?? '');
          }
        } else {
          captures.add(match.group(0) ?? '');
        }
        final hasContent = captures.any((c) => c.isNotEmpty);
        if (!hasContent) {
          // Treat fully empty captures as non-match to avoid empty payloads
          // skipped++;
          continue;
        }
        sliceMap = _mapSlices(type.slices, captures);
      } else if (type.separator.isNotEmpty) {
        final parts = line.split(type.separator);
        if (parts.length >= type.slices.length) {
          sliceMap = _mapSlices(type.slices, parts);
        }
      }

      if (sliceMap == null) {
        // skip non-matching line
        // skipped++;
        continue;
      }

      final payload = {'raw': line, 'slices': sliceMap};
      parsed.add('__BDWLJSON__${jsonEncode(payload)}');
      // matched++;
    }

    return parsed;
  }

  Map<String, String> _mapSlices(List<String> sliceNames, List<String> values) {
    final map = <String, String>{};
    for (int i = 0; i < sliceNames.length; i++) {
      final val = i < values.length ? values[i] : '';
      map[sliceNames[i]] = val;
    }
    return map;
  }
}

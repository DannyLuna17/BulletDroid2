import 'package:bullet_droid/features/runner/presentation/widgets/collapse_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bullet_droid/features/proxies/models/proxy_model.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';

import 'package:bullet_droid/core/design_tokens/borders.dart';
import 'package:bullet_droid/core/components/atoms/geist_button.dart';
import 'package:bullet_droid/core/components/atoms/geist_input.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/extensions/toast_extensions.dart';

import 'package:bullet_droid/core/components/molecules/geist_dropdown.dart';
import 'package:bullet_droid/features/proxies/services/proxy_tester_service.dart';
import 'package:bullet_droid/features/proxies/presentation/widgets/proxies_table.dart';
import 'package:bullet_droid/features/proxies/presentation/widgets/proxy_import_dialog.dart';

enum ProxyTestLogLevel { info, success, warning, error }

class WorkingProxiesScreen extends ConsumerStatefulWidget {
  const WorkingProxiesScreen({super.key});

  @override
  ConsumerState<WorkingProxiesScreen> createState() =>
      _WorkingProxiesScreenState();
}

class _WorkingProxiesScreenState extends ConsumerState<WorkingProxiesScreen> {
  // State
  bool _isBottomSectionExpanded = true;
  int _botsCount = 1;
  bool _isRunning = false;
  bool _onlyUntested = false;
  int _timeout = 5;
  String _testUrl = 'https://google.com';
  String _successKey = '<title>';

  String? _selectedProxyId;

  bool _showDeleteSelectedConfirmation = false;

  final GlobalKey _deleteButtonKey = GlobalKey();

  // Controllers
  late TextEditingController _startCountController;
  late TextEditingController _botsCountController;
  late TextEditingController _testUrlController;
  late TextEditingController _successKeyController;

  StreamController<String>? _testingController;
  final List<Isolate> _testingIsolates = [];

  // Batch updates to proxies to avoid per-row rebuilds and disk writes
  final Map<String, ProxyModel> _pendingUpdateById = {};
  Timer? _pendingFlushTimer;
  Timer? _periodicPersistTimer;

  

  void _queueProxyUpdate(ProxyModel proxy, {bool immediate = false}) {
    _pendingUpdateById[proxy.id] = proxy;
    if (immediate) {
      _flushPendingUpdates(persist: false);
      return;
    }
    _pendingFlushTimer?.cancel();
    _pendingFlushTimer = Timer(const Duration(milliseconds: 200), () {
      _flushPendingUpdates(persist: false);
    });
  }

  void _flushPendingUpdates({required bool persist}) {
    if (_pendingUpdateById.isEmpty) return;
    final updates = _pendingUpdateById.values.toList();
    _pendingUpdateById.clear();
    ref
        .read(proxiesProvider.notifier)
        .updateProxiesBatch(updates, persist: persist);
  }

  @override
  void initState() {
    super.initState();
    _startCountController = TextEditingController(text: '1');
    _botsCountController = TextEditingController(text: _botsCount.toString());
    _testUrlController = TextEditingController(text: _testUrl);
    _successKeyController = TextEditingController(text: _successKey);
    _loadExpandedState();
  }

  @override
  void dispose() {
    _startCountController.dispose();
    _botsCountController.dispose();
    _testUrlController.dispose();
    _successKeyController.dispose();
    super.dispose();
  }

  void _loadExpandedState() async {
    final box = await Hive.openBox('settings');
    setState(() {
      _isBottomSectionExpanded = box.get(
        'proxiesBottomExpanded',
        defaultValue: true,
      );
    });
  }

  void _toggleExpandedState() async {
    setState(() {
      _isBottomSectionExpanded = !_isBottomSectionExpanded;
    });
    final box = await Hive.openBox('settings');
    await box.put('proxiesBottomExpanded', _isBottomSectionExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final proxiesState = ref.watch(proxiesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: GeistColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          toolbarHeight: 60,
          elevation: 0,
          title: GeistText.headingMedium(
            'Proxies',
            customColor: theme.colorScheme.onSurface,
          ),
          centerTitle: true,
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _handleGlobalTapDown,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Main proxy table
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
                          bottom: BorderSide(
                            color: theme.colorScheme.outline.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                      child: _buildProxiesTable(proxiesState),
                    ),
                  ),

                  // Collapse button
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

                  // Bottom control section
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: _isBottomSectionExpanded
                        ? _bottomSectionHeightExpanded
                        : _bottomSectionHeightCollapsed,
                    child: _buildBottomSection(proxiesState),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGlobalTapDown(TapDownDetails details) {
    if (!_showDeleteSelectedConfirmation) return;
    final contextForKey = _deleteButtonKey.currentContext;
    if (contextForKey == null) {
      setState(() => _showDeleteSelectedConfirmation = false);
      return;
    }
    final renderObject = contextForKey.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      setState(() => _showDeleteSelectedConfirmation = false);
      return;
    }
    final Offset topLeft = renderObject.localToGlobal(Offset.zero);
    final Size size = renderObject.size;
    final Rect bounds = topLeft & size;
    if (!bounds.contains(details.globalPosition)) {
      setState(() => _showDeleteSelectedConfirmation = false);
    }
  }

  

  Widget _buildBottomSection(ProxiesState proxiesState) {
    return Container(
      decoration: BoxDecoration(
        color: GeistColors.lightBackground,
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
          _buildStatsPanel(proxiesState),

          // Expandable content
          if (_isBottomSectionExpanded)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTestingControls(proxiesState),
                    // SizedBox(height: GeistSpacing.xs),
                    _buildSettingsControls(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(ProxiesState proxiesState) {
    if (_isBottomSectionExpanded) {
      // Full view when expanded
      return Container(
        padding: EdgeInsets.all(GeistSpacing.md),
        child: Column(
          children: [
            // Proxies row
            Row(
              children: [
                GeistText.bodyMedium(
                  'Proxies',
                  customColor: GeistColors.lightTextPrimary,
                ),
                SizedBox(width: GeistSpacing.sm),
                Expanded(child: _ProxyStatsRow(proxiesState: proxiesState)),
              ],
            ),
          ],
        ),
      );
    } else {
      // Compact view when collapsed
      return Container(
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: GeistSpacing.md),
        decoration: BoxDecoration(
          color: GeistColors.lightSurface,
          border: Border(top: BorderSide(color: GeistColors.lightBorder)),
        ),
        child: Row(
          children: [
            GeistText.bodySmall(
              'Proxies:',
              customColor: GeistColors.lightTextPrimary,
            ),
            SizedBox(width: GeistSpacing.xs),
            Expanded(child: _ProxyStatsRow(proxiesState: proxiesState)),
          ],
        ),
      );
    }
  }

  // Proxy Stats Row Widget for expanded view
  Widget _ProxyStatsRow({required ProxiesState proxiesState}) {
    final selectedTypes = ref.watch(selectedProxyTypesProvider);
    final list = proxiesState.filteredByTypes(selectedTypes);
    final alive = list.where((p) => p.status == ProxyStatus.alive).length;
    final dead = list.where((p) => p.status == ProxyStatus.dead).length;
    final untested = list.where((p) => p.status == ProxyStatus.untested).length;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatusPill(
            color: GeistColors.lightTextSecondary,
            count: list.length,
            label: 'Total',
          ),
          _StatusPill(
            color: GeistColors.successColor,
            count: alive,
            label: 'Working',
          ),
          _StatusPill(
            color: GeistColors.errorColor,
            count: dead,
            label: 'Dead',
          ),
          _StatusPill(
            color: GeistColors.lightTextTertiary,
            count: untested,
            label: 'Untested',
          ),
        ],
      ),
    );
  }

  

  Widget _buildTestingControls(ProxiesState proxiesState) {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Control buttons row
          Row(
            children: [
              // Bots input
              Expanded(
                flex: 3,
                child: GeistInput(
                  label: "Bots",
                  controller: _botsCountController,
                  keyboardType: TextInputType.number,
                  isDisabled: _isRunning,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: _handleBotsCountInput,
                  onEditingComplete: () {
                    final text = _botsCountController.text;
                    final parsed = int.tryParse(text) ?? 1;
                    final clamped = parsed < 1
                        ? 1
                        : (parsed > 999 ? 999 : parsed);
                    if (_botsCount != clamped) {
                      setState(() => _botsCount = clamped);
                    }
                    if (_botsCountController.text != clamped.toString()) {
                      _botsCountController.text = clamped.toString();
                    }
                  },
                ),
              ),
              SizedBox(width: GeistSpacing.md),
              // Start/Stop button
              Expanded(
                flex: 2,
                child: GeistButton(
                  text: _isRunning ? 'Stop' : 'Start',
                  variant: _isRunning
                      ? GeistButtonVariant.outline
                      : GeistButtonVariant.filled,
                  onPressed: () {
                    if (_isRunning) {
                      _stopProxyTesting();
                    } else {
                      _startProxyTesting();
                    }
                  },
                ),
              ),
              SizedBox(width: GeistSpacing.sm),
              // Delete button
              Expanded(
                flex: 2,
                child: Container(
                  key: _deleteButtonKey,
                  child: GeistButton(
                    text: _showDeleteSelectedConfirmation
                        ? 'Confirm'
                        : 'Delete',
                    variant: _showDeleteSelectedConfirmation
                        ? GeistButtonVariant.filled
                        : GeistButtonVariant.outline,
                    isDisabled: _selectedProxyId == null,
                    onPressed: _selectedProxyId != null
                        ? () {
                            _confirmDeleteSelected(context);
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: GeistSpacing.lg),

          // Action buttons row
          Row(
            children: [
              Expanded(
                flex: 1,
                child: GeistButton(
                  text: 'Import',
                  variant: GeistButtonVariant.ghost,
                  onPressed: _importProxies,
                ),
              ),
              SizedBox(width: GeistSpacing.sm),
              Expanded(
                flex: 1,
                child: GeistButton(
                  text: 'Export',
                  variant: GeistButtonVariant.ghost,
                  isDisabled: proxiesState.proxies.isEmpty,
                  onPressed: proxiesState.proxies.isNotEmpty
                      ? _exportProxies
                      : null,
                ),
              ),
              SizedBox(width: GeistSpacing.sm),
              Expanded(flex: 2, child: _buildMoreOptionsDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsControls() {
    return Container(
      padding: EdgeInsets.all(GeistSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test URL field
          GeistInput(
            label: 'Test URL',
            controller: _testUrlController,
            variant: GeistInputVariant.technical,
            onChanged: (value) => _testUrl = value,
          ),

          SizedBox(height: GeistSpacing.md),

          // Success Key field
          GeistInput(
            label: 'Success Key',
            controller: _successKeyController,
            variant: GeistInputVariant.technical,
            onChanged: (value) => _successKey = value,
          ),

          SizedBox(height: GeistSpacing.md),

          // Timeout and toggle row
          Row(
            children: [
              Expanded(
                child: GeistInput(
                  label: 'Timeout (seconds)',
                  value: _timeout.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newValue = int.tryParse(value) ?? _timeout;
                    setState(() => _timeout = newValue);
                  },
                ),
              ),
              SizedBox(width: GeistSpacing.md),
              // Only Untested toggle
              Expanded(
                child: GeistButton(
                  text: _onlyUntested
                      ? 'Only Untested: ON'
                      : 'Only Untested: OFF',
                  variant: _onlyUntested
                      ? GeistButtonVariant.outline
                      : GeistButtonVariant.filled,
                  onPressed: () {
                    setState(() {
                      _onlyUntested = !_onlyUntested;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleBotsCountInput(String value) {
    if (value.isEmpty) {
      return;
    }
    final newValue = int.tryParse(value);
    if (newValue == null) {
      return;
    }
    if (newValue >= 1 && newValue <= 999) {
      if (_botsCount != newValue) {
        setState(() => _botsCount = newValue);
      }
    }
  }

  void _evaluateBotsCount() {
    final text = _botsCountController.text.trim();
    final parsed = int.tryParse(text) ?? 1;
    final clamped = parsed < 1 ? 1 : (parsed > 999 ? 999 : parsed);
    if (_botsCount != clamped) {
      setState(() => _botsCount = clamped);
    }
    if (_botsCountController.text != clamped.toString()) {
      _botsCountController.text = clamped.toString();
    }
  }

  // Status Pill Widget for expanded view
  Widget _StatusPill({
    required Color color,
    required int count,
    required String label,
  }) {
    return Container(
      margin: EdgeInsets.only(right: GeistSpacing.xs),
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.xs, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 4),
          GeistText.bodySmall('$count', customColor: color),
          SizedBox(width: 2),
          GeistText.bodySmall(
            label,
            customColor: GeistColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  

  void _addLog(
    String message,
    ProxyTestLogLevel level, {
    String? proxyAddress,
  }) {}

  Widget _buildProxiesTable(ProxiesState proxiesState) {
    final selectedTypes = ref.watch(selectedProxyTypesProvider);
    final filteredState = ProxiesState(
      proxies: proxiesState.filteredByTypes(selectedTypes),
      isLoading: proxiesState.isLoading,
      isTesting: proxiesState.isTesting,
      error: proxiesState.error,
    );
    return ProxyDataTable(
      proxiesState: filteredState,
      selectedProxyId: _selectedProxyId,
      onlyUntested: _onlyUntested,
      onProxySelected: (proxyId) {
        setState(() {
          _selectedProxyId = _selectedProxyId == proxyId ? null : proxyId;
        });
      },
    );
  }

  Future<void> _importProxies() async {
    await showDialog(
      context: context,
      builder: (context) => ProxyImportDialog(
        onImport: (proxies) {
          final proxiesNotifier = ref.read(proxiesProvider.notifier);
          proxiesNotifier.addProxies(proxies);
          context.showSuccessToast('Imported ${proxies.length} proxies');
        },
      ),
    );
  }

  Future<void> _exportProxies() async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Proxies',
        fileName: 'proxies.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (path != null) {
        final proxiesState = ref.read(proxiesProvider);
        final proxies = proxiesState.proxies;

        final content = proxies.map((p) => '${p.address}:${p.port}').join('\n');
        await File(path).writeAsString(content);

        context.showSuccessToast('Exported ${proxies.length} proxies');
      }
    } catch (e) {
      context.showErrorToast('Export failed: $e');
    }
  }

  Widget _buildMoreOptionsDropdown() {
    return GeistActionDropdown(
      label: 'More Options',
      actions: [
        DropdownAction(
          icon: Icons.delete_sweep,
          title: 'Delete All',
          onTap: () => _deleteAllDirectly(context),
        ),
        DropdownAction(
          icon: Icons.delete_outline,
          title: 'Delete Not Working',
          onTap: () => ref.read(proxiesProvider.notifier).deleteNotWorking(),
        ),
        DropdownAction(
          icon: Icons.filter_alt_off,
          title: 'Delete Duplicates',
          onTap: () => ref.read(proxiesProvider.notifier).deleteDuplicates(),
        ),
        DropdownAction(
          icon: Icons.remove_circle_outline,
          title: 'Delete Untested',
          onTap: () => ref.read(proxiesProvider.notifier).deleteUntested(),
        ),
      ],
    );
  }

  void _deleteAllDirectly(BuildContext context) {
    ref.read(proxiesProvider.notifier).clearAll();
    context.showSuccessToast('All proxies deleted');
  }

  void _confirmDeleteSelected(BuildContext context) {
    if (_selectedProxyId == null) return;

    if (_showDeleteSelectedConfirmation) {
      // Confirm deletion
      ref.read(proxiesProvider.notifier).deleteProxy(_selectedProxyId!);
      setState(() {
        _selectedProxyId = null;
        _showDeleteSelectedConfirmation = false;
      });
      context.showSuccessToast('Selected proxy deleted');
    } else {
      // Show confirmation state
      setState(() {
        _showDeleteSelectedConfirmation = true;
      });
    }
  }

  Future<void> _startProxyTesting() async {
    _evaluateBotsCount();
    setState(() {
      _isRunning = true;
    });

    final proxiesState = ref.read(proxiesProvider);
    final allProxies = _onlyUntested
        ? proxiesState.proxies
              .where((p) => p.status == ProxyStatus.untested)
              .toList()
        : proxiesState.proxies;

    final uniqueProxies = <ProxyModel>[];
    final seenAddresses = <String>{};

    for (final proxy in allProxies) {
      final address = '${proxy.address}:${proxy.port}';
      if (!seenAddresses.contains(address)) {
        seenAddresses.add(address);
        uniqueProxies.add(proxy);
      }
    }

    if (uniqueProxies.isEmpty) {
      setState(() => _isRunning = false);
      _addLog('No proxies to test', ProxyTestLogLevel.warning);
      context.showWarningToast('No proxies to test');
      return;
    }

    if (uniqueProxies.length < allProxies.length) {
      _addLog(
        'Removed ${allProxies.length - uniqueProxies.length} duplicate proxies',
        ProxyTestLogLevel.info,
      );
    }

    try {
      final service = ref.read(proxyTesterServiceProvider);
      await service.runTesting(
        proxies: uniqueProxies,
        concurrency: _botsCount,
        testSingleProxy: (p) => _testSingleProxy(p),
        flushPendingUpdates: () => _flushPendingUpdates(persist: true),
        shouldContinue: () => _isRunning,
      );
    } catch (e) {
      context.showErrorToast('Testing failed: $e');
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  Future<void> _stopProxyTesting() async {
    setState(() => _isRunning = false);

    // Stop all testing isolates
    for (final isolate in _testingIsolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _testingIsolates.clear();

    _testingController?.close();
    _testingController = null;

    _periodicPersistTimer?.cancel();
    _periodicPersistTimer = null;
    _pendingFlushTimer?.cancel();
    _pendingFlushTimer = null;
    _flushPendingUpdates(persist: true);

    setState(() {});
  }

  Future<void> _testSingleProxy(ProxyModel proxy) async {
    if (!_isRunning) return;

    final proxyAddress = '${proxy.address}:${proxy.port}';

    // Get current proxy state to avoid overwriting successful tests
    final currentProxy = ref
        .read(proxiesProvider)
        .proxies
        .firstWhere((p) => p.id == proxy.id);

    // If proxy is already marked as ALIVE or DEAD, don't test it again
    if (currentProxy.status == ProxyStatus.alive ||
        currentProxy.status == ProxyStatus.dead) {
      _addLog(
        'Skipping $proxyAddress - already marked as ${currentProxy.status}',
        ProxyTestLogLevel.info,
        proxyAddress: proxyAddress,
      );
      return;
    }

    // Update status to testing
    final testingProxy = ProxyModel(
      id: proxy.id,
      address: proxy.address,
      port: proxy.port,
      type: proxy.type,
      status: ProxyStatus.testing,
      username: proxy.username,
      password: proxy.password,
      lastChecked: currentProxy.lastChecked,
      lastUsed: currentProxy.lastUsed,
      successCount: currentProxy.successCount,
      failureCount: currentProxy.failureCount,
      responseTime: currentProxy.responseTime,
      country: currentProxy.country,
      metadata: currentProxy.metadata,
    );
    _queueProxyUpdate(testingProxy);
    _addLog(
      'Testing proxy $proxyAddress...',
      ProxyTestLogLevel.info,
      proxyAddress: proxyAddress,
    );

    try {
      final stopwatch = Stopwatch()..start();

      // First, test basic connectivity to proxy
      final socket = await Socket.connect(
        proxy.address,
        proxy.port,
        timeout: Duration(seconds: _timeout),
      );

      // Test proxy based on type
      final bool testSuccess;
      if (proxy.type == ProxyType.http) {
        testSuccess = await _testHttpProxy(socket, proxy);
      } else {
        testSuccess = await _testSocksProxy(socket, proxy);
      }

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds;

      socket.close();

      // Update proxy status based on test result
      final newStatus = testSuccess ? ProxyStatus.alive : ProxyStatus.dead;

      // Log the result
      if (newStatus == ProxyStatus.alive) {
        _addLog(
          '$proxyAddress - ALIVE (${responseTime}ms)',
          ProxyTestLogLevel.success,
          proxyAddress: proxyAddress,
        );
      } else {
        _addLog(
          '$proxyAddress - DEAD (Connection failed)',
          ProxyTestLogLevel.error,
          proxyAddress: proxyAddress,
        );
      }

      final shouldUpdate =
          newStatus == ProxyStatus.alive ||
          currentProxy.status != ProxyStatus.alive;

      if (shouldUpdate) {
        final updatedProxy = ProxyModel(
          id: proxy.id,
          address: proxy.address,
          port: proxy.port,
          type: proxy.type,
          status: newStatus,
          username: proxy.username,
          password: proxy.password,
          lastChecked: DateTime.now(),
          lastUsed: proxy.lastUsed,
          successCount: newStatus == ProxyStatus.alive
              ? proxy.successCount + 1
              : proxy.successCount,
          failureCount: newStatus == ProxyStatus.dead
              ? proxy.failureCount + 1
              : proxy.failureCount,
          responseTime: newStatus == ProxyStatus.alive
              ? responseTime
              : proxy.responseTime,
          country: proxy.country,
          metadata: proxy.metadata,
        );
        _queueProxyUpdate(updatedProxy);
      } else {
        _addLog(
          'Preserving ALIVE status for $proxyAddress',
          ProxyTestLogLevel.info,
          proxyAddress: proxyAddress,
        );
      }
    } catch (e) {
      _addLog(
        '$proxyAddress - ERROR: $e',
        ProxyTestLogLevel.error,
        proxyAddress: proxyAddress,
      );

      if (currentProxy.status != ProxyStatus.alive) {
        final updatedProxy = ProxyModel(
          id: proxy.id,
          address: proxy.address,
          port: proxy.port,
          type: proxy.type,
          status: ProxyStatus.dead,
          username: proxy.username,
          password: proxy.password,
          lastChecked: DateTime.now(),
          lastUsed: proxy.lastUsed,
          successCount: proxy.successCount,
          failureCount: proxy.failureCount + 1,
          responseTime: 0,
          country: proxy.country,
          metadata: proxy.metadata,
        );
        _queueProxyUpdate(updatedProxy);
      } else {
        _addLog(
          'Preserving ALIVE status for $proxyAddress despite error',
          ProxyTestLogLevel.info,
          proxyAddress: proxyAddress,
        );
      }
    }

  }

  Future<bool> _testHttpProxy(Socket socket, ProxyModel proxy) async {
    return await _testHttpProxySimple(socket, proxy, _testUrl, 0);
  }

  Future<bool> _testSocksProxy(Socket socket, ProxyModel proxy) async {
    return await _testSocksProxySimple(socket, proxy, _testUrl, 0);
  }

  Future<bool> _testSocksProxySimple(
    Socket socket,
    ProxyModel proxy,
    String testUrl,
    int redirectCount,
  ) async {
    const maxRedirects = 5;
    if (redirectCount >= maxRedirects) {
      _addLog(
        'Too many SOCKS redirects ($redirectCount), stopping',
        ProxyTestLogLevel.warning,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      return false;
    }

    try {
      final uri = Uri.parse(testUrl);
      final isHttps = uri.scheme.toLowerCase() == 'https';

      // Perform SOCKS handshake to destination
      bool connected = false;
      if (proxy.type == ProxyType.socks4) {
        connected = await _socks4Connect(socket, proxy, uri);
      } else {
        connected = await _socks5Connect(socket, proxy, uri);
      }
      if (!connected) {
        _addLog(
          'SOCKS connect failed to ${uri.host}:${uri.port}',
          ProxyTestLogLevel.error,
          proxyAddress: '${proxy.address}:${proxy.port}',
        );
        return false;
      }

      if (isHttps) {
        // Wrap the tunnel with TLS and perform HTTPS GET
        final secureSocket = await SecureSocket.secure(
          socket,
          host: uri.host,
          onBadCertificate: (_) => true,
        );

        final httpRequest =
            'GET ${uri.path.isEmpty ? '/' : uri.path}${uri.hasQuery ? '?${uri.query}' : ''} HTTP/1.1\r\n';
        final fullRequest =
            '${httpRequest}Host: ${uri.host}\r\nUser-Agent: BulletDroid/1.0\r\nConnection: close\r\n\r\n';

        _addLog(
          'Sending HTTPS request via SOCKS: ${httpRequest.trim()}',
          ProxyTestLogLevel.info,
          proxyAddress: '${proxy.address}:${proxy.port}',
        );
        secureSocket.write(fullRequest);
        await secureSocket.flush();

        final completer = Completer<bool>();
        final responseBuffer = StringBuffer();

        StreamSubscription<List<int>>? sub;
        sub = secureSocket.listen(
          (data) {
            if (completer.isCompleted) return;
            responseBuffer.write(String.fromCharCodes(data));
            final response = responseBuffer.toString();

            if (response.contains('\r\n\r\n') || response.contains('\n\n')) {
              final lines = response.split('\n');
              final statusLine = lines.first.trim();
              _addLog(
                'HTTPS via SOCKS status: $statusLine',
                ProxyTestLogLevel.info,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );

              if (_isRedirectStatus(statusLine)) {
                final redirectLocation = _extractLocationHeader(response);
                if (redirectLocation != null) {
                  final absoluteUrl = _makeAbsoluteUrl(redirectLocation, uri);
                  _addLog(
                    'HTTPS redirect via SOCKS to: $absoluteUrl',
                    ProxyTestLogLevel.info,
                    proxyAddress: '${proxy.address}:${proxy.port}',
                  );
                  sub?.cancel();
                  secureSocket.close();
                  // Open a new proxy connection for redirect
                  Socket.connect(
                        proxy.address,
                        proxy.port,
                        timeout: Duration(seconds: _timeout),
                      )
                      .then((newSocket) async {
                        final result = await _testSocksProxySimple(
                          newSocket,
                          proxy,
                          absoluteUrl,
                          redirectCount + 1,
                        );
                        await newSocket.close();
                        if (!completer.isCompleted) completer.complete(result);
                      })
                      .catchError((e) {
                        if (!completer.isCompleted) completer.complete(false);
                      });
                  return;
                } else {
                  if (!completer.isCompleted) completer.complete(false);
                  return;
                }
              }

              if (statusLine.contains('200')) {
                final hasSuccessKey =
                    _successKey.isEmpty ||
                    response.toLowerCase().contains(_successKey.toLowerCase());
                if (!completer.isCompleted) completer.complete(hasSuccessKey);
              } else {
                if (!completer.isCompleted) completer.complete(false);
              }
            }
          },
          onError: (error) {
            if (!completer.isCompleted) completer.complete(false);
          },
          onDone: () {
            if (!completer.isCompleted) {
              final response = responseBuffer.toString();
              if (response.isNotEmpty) {
                final statusLine = response.split('\n').first.trim();
                final result =
                    statusLine.contains('200') &&
                    (_successKey.isEmpty ||
                        response.toLowerCase().contains(
                          _successKey.toLowerCase(),
                        ));
                completer.complete(result);
              } else {
                completer.complete(false);
              }
            }
          },
          cancelOnError: true,
        );

        final res = await completer.future.timeout(
          Duration(seconds: _timeout),
          onTimeout: () => false,
        );
        return res;
      } else {
        // Plain HTTP over SOCKS tunnel
        String request = 'GET ${uri.toString()} HTTP/1.1\r\n';
        request += 'Host: ${uri.host}\r\n';
        request += 'User-Agent: BulletDroid/1.0\r\n';
        request += 'Connection: close\r\n';
        request += '\r\n';

        socket.write(request);
        await socket.flush();

        final completer = Completer<bool>();
        final responseBuffer = StringBuffer();

        StreamSubscription<List<int>>? sub;
        sub = socket.listen(
          (data) {
            if (completer.isCompleted) return;
            responseBuffer.write(String.fromCharCodes(data));
            final response = responseBuffer.toString();

            if (response.contains('\r\n\r\n') || response.contains('\n\n')) {
              final lines = response.split('\n');
              final statusLine = lines.first.trim();
              _addLog(
                'HTTP via SOCKS status: $statusLine',
                ProxyTestLogLevel.info,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );

              if (_isRedirectStatus(statusLine)) {
                final redirectLocation = _extractLocationHeader(response);
                if (redirectLocation != null) {
                  final absoluteUrl = _makeAbsoluteUrl(redirectLocation, uri);
                  _addLog(
                    'HTTP redirect via SOCKS to: $absoluteUrl',
                    ProxyTestLogLevel.info,
                    proxyAddress: '${proxy.address}:${proxy.port}',
                  );
                  sub?.cancel();
                  socket.close().then((_) async {
                    try {
                      final newSocket = await Socket.connect(
                        proxy.address,
                        proxy.port,
                        timeout: Duration(seconds: _timeout),
                      );
                      final redirectResult = await _testSocksProxySimple(
                        newSocket,
                        proxy,
                        absoluteUrl,
                        redirectCount + 1,
                      );
                      await newSocket.close();
                      if (!completer.isCompleted) {
                        completer.complete(redirectResult);
                      }
                    } catch (e) {
                      if (!completer.isCompleted) completer.complete(false);
                    }
                  });
                  return;
                } else {
                  if (!completer.isCompleted) completer.complete(false);
                  return;
                }
              }

              if (statusLine.contains('200')) {
                final hasSuccessKey =
                    _successKey.isEmpty ||
                    response.toLowerCase().contains(_successKey.toLowerCase());
                if (!completer.isCompleted) completer.complete(hasSuccessKey);
              } else {
                if (!completer.isCompleted) completer.complete(false);
              }
            }
          },
          onError: (error) {
            if (!completer.isCompleted) completer.complete(false);
          },
          onDone: () {
            if (!completer.isCompleted) {
              final response = responseBuffer.toString();
              if (response.isNotEmpty) {
                final statusLine = response.split('\n').first.trim();
                final result =
                    statusLine.contains('200') &&
                    (_successKey.isEmpty ||
                        response.toLowerCase().contains(
                          _successKey.toLowerCase(),
                        ));
                completer.complete(result);
              } else {
                completer.complete(false);
              }
            }
          },
          cancelOnError: true,
        );

        final res = await completer.future.timeout(
          Duration(seconds: _timeout),
          onTimeout: () => false,
        );
        return res;
      }
    } catch (e) {
      _addLog(
        'SOCKS proxy test error: $e',
        ProxyTestLogLevel.error,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      return false;
    }
  }

  Future<bool> _socks4Connect(Socket socket, ProxyModel proxy, Uri uri) async {
    try {
      final port = uri.hasPort
          ? uri.port
          : (uri.scheme.toLowerCase() == 'https' ? 443 : 80);
      final username = proxy.username ?? '';
      final isIpv4 = _isIPv4(uri.host);

      final bytesBuilder = BytesBuilder();
      bytesBuilder.add([0x04, 0x01]);
      bytesBuilder.add([(port >> 8) & 0xFF, port & 0xFF]);
      if (isIpv4) {
        final octets = uri.host.split('.').map((e) => int.parse(e)).toList();
        bytesBuilder.add(octets);
      } else {
        bytesBuilder.add([0x00, 0x00, 0x00, 0x01]);
      }
      bytesBuilder.add(utf8.encode(username));
      bytesBuilder.add([0x00]);
      if (!isIpv4) {
        // Domain name and null terminator
        bytesBuilder.add(utf8.encode(uri.host));
        bytesBuilder.add([0x00]);
      }

      final request = bytesBuilder.toBytes();
      socket.add(request);
      await socket.flush();

      final resp = await _readExact(socket, 8, _timeout);
      if (resp.length != 8) return false;
      // resp[0] should be 0x00, resp[1] 0x5A for success
      return resp[1] == 0x5A;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _socks5Connect(Socket socket, ProxyModel proxy, Uri uri) async {
    try {
      // Greeting
      if (proxy.username != null && proxy.username!.isNotEmpty) {
        socket.add([
          0x05,
          0x02,
          0x00,
          0x02,
        ]); // VER=5, NMETHODS=2, METHODS: no-auth(0), user/pass(2)
      } else {
        socket.add([0x05, 0x01, 0x00]); // VER=5, NMETHODS=1, no-auth(0)
      }
      await socket.flush();
      final methodResp = await _readExact(socket, 2, _timeout);
      if (methodResp.length != 2 || methodResp[0] != 0x05) return false;
      final method = methodResp[1];
      if (method == 0xFF) return false; // no acceptable method
      if (method == 0x02) {
        // Username/Password auth
        final ok = await _socks5AuthUsernamePassword(
          socket,
          proxy.username ?? '',
          proxy.password ?? '',
        );
        if (!ok) return false;
      }

      // CONNECT request
      final port = uri.hasPort
          ? uri.port
          : (uri.scheme.toLowerCase() == 'https' ? 443 : 80);
      final host = uri.host;
      final isIpv4 = _isIPv4(host);

      final builder = BytesBuilder();
      builder.add([0x05, 0x01, 0x00]); // VER=5, CMD=CONNECT, RSV=0
      if (isIpv4) {
        builder.add([0x01]); // ATYP=IPv4
        builder.add(host.split('.').map((e) => int.parse(e)).toList());
      } else {
        final hostBytes = utf8.encode(host);
        builder.add([0x03, hostBytes.length]); // ATYP=DOMAIN, LEN
        builder.add(hostBytes);
      }
      builder.add([(port >> 8) & 0xFF, port & 0xFF]);
      final req = builder.toBytes();
      socket.add(req);
      await socket.flush();

      // Read response header
      final head = await _readExact(socket, 4, _timeout);
      if (head.length != 4 || head[0] != 0x05) return false;
      final rep = head[1];
      if (rep != 0x00) return false; // failure
      final atyp = head[3];
      int addrLen;
      if (atyp == 0x01) {
        addrLen = 4;
      } else if (atyp == 0x03) {
        final lenBytes = await _readExact(socket, 1, _timeout);
        if (lenBytes.isEmpty) return false;
        addrLen = lenBytes[0];
      } else if (atyp == 0x04) {
        addrLen = 16;
      } else {
        return false;
      }
      // Read BND.ADDR and BND.PORT and ignore
      final bnd = await _readExact(socket, addrLen + 2, _timeout);
      if (bnd.length != addrLen + 2) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _socks5AuthUsernamePassword(
    Socket socket,
    String username,
    String password,
  ) async {
    try {
      final userBytes = utf8.encode(username);
      final passBytes = utf8.encode(password);
      final builder = BytesBuilder();
      builder.add([0x01, userBytes.length]);
      builder.add(userBytes);
      builder.add([0x01, passBytes.length]);
      builder.add(passBytes);
      socket.add(builder.toBytes());
      await socket.flush();

      final resp = await _readExact(socket, 2, _timeout);
      if (resp.length != 2) return false;
      return resp[1] == 0x00;
    } catch (_) {
      return false;
    }
  }

  Future<Uint8List> _readExact(
    Socket socket,
    int length,
    int timeoutSeconds,
  ) async {
    final completer = Completer<Uint8List>();
    final buffer = BytesBuilder();
    StreamSubscription<List<int>>? sub;
    sub = socket.listen(
      (data) {
        buffer.add(data);
        if (buffer.length >= length) {
          sub?.cancel();
          final bytes = buffer.toBytes();
          completer.complete(Uint8List.fromList(bytes.sublist(0, length)));
        }
      },
      onError: (e) {
        sub?.cancel();
        if (!completer.isCompleted) completer.complete(Uint8List(0));
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(Uint8List(0));
      },
      cancelOnError: true,
    );
    return completer.future.timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        sub?.cancel();
        return Uint8List(0);
      },
    );
  }

  bool _isIPv4(String host) {
    final parts = host.split('.');
    if (parts.length != 4) return false;
    for (final p in parts) {
      final n = int.tryParse(p);
      if (n == null || n < 0 || n > 255) return false;
    }
    return true;
  }

  Future<bool> _testHttpProxySimple(
    Socket socket,
    ProxyModel proxy,
    String testUrl,
    int redirectCount,
  ) async {
    const maxRedirects = 5;

    if (redirectCount >= maxRedirects) {
      _addLog(
        'Too many redirects ($redirectCount), stopping',
        ProxyTestLogLevel.warning,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      return false;
    }

    try {
      final uri = Uri.parse(testUrl);
      final host = uri.host;
      final port = uri.port;
      final isHttps = uri.scheme == 'https';

      if (redirectCount > 0) {
        _addLog(
          'Following redirect #$redirectCount to: $testUrl',
          ProxyTestLogLevel.info,
          proxyAddress: '${proxy.address}:${proxy.port}',
        );
      }

      String request;
      if (isHttps) {
        request = 'CONNECT $host:$port HTTP/1.1\r\n';
        request += 'Host: $host:$port\r\n';
        if (proxy.username != null && proxy.password != null) {
          final credentials = base64Encode(
            utf8.encode('${proxy.username}:${proxy.password}'),
          );
          request += 'Proxy-Authorization: Basic $credentials\r\n';
        }
        request += '\r\n';
      } else {
        request = 'GET $testUrl HTTP/1.1\r\n';
        request += 'Host: $host\r\n';
        request += 'User-Agent: BulletDroid/1.0\r\n';
        if (proxy.username != null && proxy.password != null) {
          final credentials = base64Encode(
            utf8.encode('${proxy.username}:${proxy.password}'),
          );
          request += 'Proxy-Authorization: Basic $credentials\r\n';
        }
        request += 'Connection: close\r\n';
        request += '\r\n';
      }

      socket.write(request);
      await socket.flush();

      final completer = Completer<bool>();
      final responseBuffer = StringBuffer();

      socket.listen(
        (data) {
          responseBuffer.write(String.fromCharCodes(data));
          final response = responseBuffer.toString();

          if (response.contains('\r\n\r\n') || response.contains('\n\n')) {
            final lines = response.split('\n');
            final statusLine = lines.first.trim();
            _addLog(
              'Response: $statusLine',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );

            // Check for successful response
            if (statusLine.contains('200') ||
                statusLine.toLowerCase().contains('connection established')) {
              if (isHttps && _successKey.isNotEmpty) {
                _performSSLHandshakeAndRequest(socket, uri, proxy, completer);
                return;
              } else {
                final hasSuccessKey =
                    _successKey.isEmpty ||
                    response.toLowerCase().contains(_successKey.toLowerCase());
                completer.complete(hasSuccessKey);
              }
            }
            // Check for redirects
            else if (!isHttps && _isRedirectStatus(statusLine)) {
              final redirectLocation = _extractLocationHeader(response);
              if (redirectLocation != null) {
                _addLog(
                  'Redirect detected: $statusLine -> $redirectLocation',
                  ProxyTestLogLevel.info,
                  proxyAddress: '${proxy.address}:${proxy.port}',
                );

                final absoluteUrl = _makeAbsoluteUrl(redirectLocation, uri);

                // Close current socket and create new one for redirect
                socket.close().then((_) async {
                  try {
                    final newSocket = await Socket.connect(
                      proxy.address,
                      proxy.port,
                      timeout: Duration(seconds: _timeout),
                    );
                    final redirectResult = await _testHttpProxySimple(
                      newSocket,
                      proxy,
                      absoluteUrl,
                      redirectCount + 1,
                    );
                    await newSocket.close();
                    completer.complete(redirectResult);
                  } catch (e) {
                    _addLog(
                      'Failed to follow redirect: $e',
                      ProxyTestLogLevel.error,
                      proxyAddress: '${proxy.address}:${proxy.port}',
                    );
                    completer.complete(false);
                  }
                });
                return;
              } else {
                _addLog(
                  'Redirect without location header',
                  ProxyTestLogLevel.warning,
                  proxyAddress: '${proxy.address}:${proxy.port}',
                );
                completer.complete(false);
              }
            } else {
              _addLog(
                'Proxy returned error status: $statusLine',
                ProxyTestLogLevel.warning,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );
              completer.complete(false);
            }
          }
        },
        onError: (error) {
          _addLog(
            'Socket error: $error',
            ProxyTestLogLevel.error,
            proxyAddress: '${proxy.address}:${proxy.port}',
          );
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            final response = responseBuffer.toString();
            if (response.isNotEmpty) {
              final statusLine = response.split('\n').first.trim();
              final result = statusLine.contains('200');
              completer.complete(result);
            } else {
              completer.complete(false);
            }
          }
        },
      );

      return await completer.future.timeout(
        Duration(seconds: _timeout),
        onTimeout: () {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          return false;
        },
      );
    } catch (e) {
      _addLog(
        'HTTP proxy test error: $e',
        ProxyTestLogLevel.error,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      return false;
    }
  }

  bool _isRedirectStatus(String statusLine) {
    return statusLine.contains('301') ||
        statusLine.contains('302') ||
        statusLine.contains('303') ||
        statusLine.contains('307') ||
        statusLine.contains('308');
  }

  String? _extractLocationHeader(String response) {
    final lines = response.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim().toLowerCase();
      if (trimmedLine.startsWith('location:')) {
        final location = line.substring(line.indexOf(':') + 1).trim();
        return location;
      }
    }
    return null;
  }

  String _makeAbsoluteUrl(String location, Uri baseUri) {
    try {
      final locationUri = Uri.parse(location);

      if (locationUri.hasScheme) {
        return location;
      }

      final absoluteUri = baseUri.resolve(location);
      return absoluteUri.toString();
    } catch (e) {
      _addLog(
        'Error parsing redirect URL: $e',
        ProxyTestLogLevel.warning,
        proxyAddress: 'unknown',
      );
      return location;
    }
  }

  Future<void> _performSSLHandshakeAndRequest(
    Socket socket,
    Uri uri,
    ProxyModel proxy,
    Completer<bool> completer,
  ) async {
    await _performSSLHandshakeAndRequestWithRedirects(
      socket,
      uri,
      proxy,
      completer,
      0,
    );
  }

  Future<void> _performSSLHandshakeAndRequestWithRedirects(
    Socket socket,
    Uri uri,
    ProxyModel proxy,
    Completer<bool> completer,
    int redirectCount,
  ) async {
    const maxRedirects = 5;

    if (redirectCount >= maxRedirects) {
      _addLog(
        'Too many HTTPS redirects ($redirectCount), stopping',
        ProxyTestLogLevel.warning,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
      return;
    }

    try {
      if (redirectCount == 0) {
        _addLog(
          'Initiating SSL/TLS handshake...',
          ProxyTestLogLevel.info,
          proxyAddress: '${proxy.address}:${proxy.port}',
        );

        await Future.delayed(Duration(milliseconds: 200));
      } else {
        _addLog(
          'Following HTTPS redirect #$redirectCount to: ${uri.toString()}',
          ProxyTestLogLevel.info,
          proxyAddress: '${proxy.address}:${proxy.port}',
        );
      }

      final secureSocket = await SecureSocket.secure(
        socket,
        host: uri.host,
        onBadCertificate: (certificate) {
          _addLog(
            'SSL certificate validation failed - accepting anyway for testing',
            ProxyTestLogLevel.warning,
            proxyAddress: '${proxy.address}:${proxy.port}',
          );
          return true;
        },
      );

      _addLog(
        'SSL/TLS handshake completed successfully',
        ProxyTestLogLevel.info,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );

      final httpRequest =
          'GET ${uri.path.isEmpty ? '/' : uri.path} HTTP/1.1\r\n';
      final fullRequest =
          '${httpRequest}Host: ${uri.host}\r\nUser-Agent: BulletDroid/1.0\r\nConnection: close\r\n\r\n';

      _addLog(
        'Sending HTTPS request: ${httpRequest.trim()}',
        ProxyTestLogLevel.info,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );

      secureSocket.write(fullRequest);
      await secureSocket.flush();

      _addLog(
        'HTTPS request sent successfully',
        ProxyTestLogLevel.info,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );

      final responseBuffer = StringBuffer();

      secureSocket.listen(
        (data) {
          if (completer.isCompleted) {
            return;
          }

          responseBuffer.write(String.fromCharCodes(data));
          final response = responseBuffer.toString();

          _addLog(
            'Received HTTPS response data: ${response.length} chars',
            ProxyTestLogLevel.info,
            proxyAddress: '${proxy.address}:${proxy.port}',
          );

          if (response.length <= 2000 ||
              response.toLowerCase().contains(_successKey.toLowerCase())) {
            _addLog(
              'HTTPS chunk: ${response.substring(response.length > 1000 ? response.length - 1000 : 0)}',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );
          }

          if (response.toLowerCase().contains(_successKey.toLowerCase())) {
            _addLog(
              'Success key "$_successKey" found in HTTPS response!',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );
            _addLog(
              'Completing with result: true',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );
            completer.complete(true);
            return;
          }

          if (response.contains('\r\n\r\n') || response.contains('\n\n')) {
            _addLog(
              'Complete HTTPS response received',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );

            final lines = response.split('\n');
            final statusLine = lines.isNotEmpty
                ? lines.first.trim()
                : 'No status line';
            _addLog(
              'HTTPS status line: $statusLine',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );

            if (_isRedirectStatus(statusLine)) {
              final redirectLocation = _extractLocationHeader(response);
              if (redirectLocation != null) {
                _addLog(
                  'HTTPS redirect detected: $statusLine -> $redirectLocation',
                  ProxyTestLogLevel.info,
                  proxyAddress: '${proxy.address}:${proxy.port}',
                );

                final absoluteUrl = _makeAbsoluteUrl(redirectLocation, uri);
                final redirectUri = Uri.parse(absoluteUrl);

                secureSocket.close();

                _handleHttpsRedirect(
                  proxy,
                  redirectUri,
                  completer,
                  redirectCount + 1,
                );
                return;
              } else {
                _addLog(
                  'HTTPS redirect without location header',
                  ProxyTestLogLevel.warning,
                  proxyAddress: '${proxy.address}:${proxy.port}',
                );
                completer.complete(false);
                return;
              }
            }

            if (statusLine.contains('200')) {
              final hasSuccessKey = response.toLowerCase().contains(
                _successKey.toLowerCase(),
              );
              _addLog(
                'Final success key check: "$_successKey" ${hasSuccessKey ? "found" : "not found"} in complete HTTPS response',
                ProxyTestLogLevel.info,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );
              _addLog(
                'Completing with result: $hasSuccessKey',
                ProxyTestLogLevel.info,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );
              completer.complete(hasSuccessKey);
              return;
            } else {
              _addLog(
                'HTTPS error status: $statusLine',
                ProxyTestLogLevel.warning,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );
              completer.complete(false);
              return;
            }
          }
        },
        onError: (error) {
          _addLog(
            'HTTPS response error: $error',
            ProxyTestLogLevel.error,
            proxyAddress: '${proxy.address}:${proxy.port}',
          );
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
        onDone: () {
          _addLog(
            'HTTPS connection closed',
            ProxyTestLogLevel.info,
            proxyAddress: '${proxy.address}:${proxy.port}',
          );
          if (!completer.isCompleted) {
            final response = responseBuffer.toString();
            if (response.isNotEmpty) {
              final hasSuccessKey = response.toLowerCase().contains(
                _successKey.toLowerCase(),
              );
              _addLog(
                'Final HTTPS verification result: $hasSuccessKey',
                ProxyTestLogLevel.info,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );
              completer.complete(hasSuccessKey);
            } else {
              _addLog(
                'No HTTPS response received',
                ProxyTestLogLevel.warning,
                proxyAddress: '${proxy.address}:${proxy.port}',
              );
              completer.complete(false);
            }
          }
        },
      );

      Timer(Duration(seconds: 40), () {
        if (!completer.isCompleted) {
          _addLog(
            'HTTPS request timeout',
            ProxyTestLogLevel.warning,
            proxyAddress: '${proxy.address}:${proxy.port}',
          );
          completer.complete(false);
        }
        secureSocket.close();
      });
    } catch (e) {
      _addLog(
        'SSL/TLS handshake error: $e',
        ProxyTestLogLevel.error,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
  }

  Future<void> _handleHttpsRedirect(
    ProxyModel proxy,
    Uri redirectUri,
    Completer<bool> completer,
    int redirectCount,
  ) async {
    try {
      _addLog(
        'Creating new connection for HTTPS redirect to: ${redirectUri.toString()}',
        ProxyTestLogLevel.info,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );

      final newSocket = await Socket.connect(
        proxy.address,
        proxy.port,
        timeout: Duration(seconds: _timeout),
      );

      String connectRequest =
          'CONNECT ${redirectUri.host}:${redirectUri.port} HTTP/1.1\r\n';
      connectRequest += 'Host: ${redirectUri.host}:${redirectUri.port}\r\n';
      if (proxy.username != null && proxy.password != null) {
        final credentials = base64Encode(
          utf8.encode('${proxy.username}:${proxy.password}'),
        );
        connectRequest += 'Proxy-Authorization: Basic $credentials\r\n';
      }
      connectRequest += '\r\n';

      newSocket.write(connectRequest);
      await newSocket.flush();

      final connectCompleter = Completer<bool>();
      final connectBuffer = StringBuffer();

      newSocket.listen(
        (data) {
          connectBuffer.write(String.fromCharCodes(data));
          final response = connectBuffer.toString();

          if (response.contains('\r\n\r\n') || response.contains('\n\n')) {
            final statusLine = response.split('\n').first.trim();
            _addLog(
              'Redirect CONNECT response: $statusLine',
              ProxyTestLogLevel.info,
              proxyAddress: '${proxy.address}:${proxy.port}',
            );

            if (statusLine.contains('200') ||
                statusLine.toLowerCase().contains('connection established')) {
              connectCompleter.complete(true);
            } else {
              connectCompleter.complete(false);
            }
          }
        },
        onError: (error) {
          if (!connectCompleter.isCompleted) {
            connectCompleter.complete(false);
          }
        },
        onDone: () {
          if (!connectCompleter.isCompleted) {
            connectCompleter.complete(false);
          }
        },
      );

      final connectSuccess = await connectCompleter.future.timeout(
        Duration(seconds: _timeout),
        onTimeout: () => false,
      );

      if (connectSuccess) {
        await _performSSLHandshakeAndRequestWithRedirects(
          newSocket,
          redirectUri,
          proxy,
          completer,
          redirectCount,
        );
      } else {
        _addLog(
          'Failed to establish CONNECT for redirect',
          ProxyTestLogLevel.error,
          proxyAddress: '${proxy.address}:${proxy.port}',
        );
        if (!completer.isCompleted) {
          completer.complete(false);
        }
        await newSocket.close();
      }
    } catch (e) {
      _addLog(
        'Failed to handle HTTPS redirect: $e',
        ProxyTestLogLevel.error,
        proxyAddress: '${proxy.address}:${proxy.port}',
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    }
  }
}

extension _ProxiesBottomSectionDimensions on _WorkingProxiesScreenState {
  double get _bottomSectionHeightExpanded {
    final double base = 460;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    return base + (safeBottom > 0 ? safeBottom / 2 : 0);
  }

  double get _bottomSectionHeightCollapsed {
    final double base = 150;
    final double safeBottom = MediaQuery.of(context).padding.bottom;
    return base + (safeBottom > 0 ? safeBottom / 2 : 0);
  }

  double get _collapseButtonOverlap => -11.0;
}

// Reusable Dropdown Component
class _GeistDropdown<T> extends StatefulWidget {
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final Widget? Function(T)? itemWidgetBuilder;
  final ValueChanged<T> onChanged;
  final bool isExpanded;
  final GlobalKey? dropdownKey;

  const _GeistDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.itemWidgetBuilder,
    required this.onChanged,
    this.isExpanded = false,
    this.dropdownKey,
  });

  @override
  State<_GeistDropdown<T>> createState() => _GeistDropdownState<T>();
}

class _GeistDropdownState<T> extends State<_GeistDropdown<T>> {
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
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _dropdownKey,
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
              children: [
                Expanded(
                  child: GeistText(
                    widget.itemLabelBuilder(widget.value),
                    variant: GeistTextVariant.bodyMedium,
                    fontWeight: FontWeight.bold,
                    customColor: GeistColors.black,
                    fontSize: 12.5,
                  ),
                ),
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

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              left: position.dx,
              top: position.dy + size.height,
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
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isLast = index == widget.items.length - 1;

                        return _buildDropdownItem(item: item, isLast: isLast);
                      }).toList(),
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
    setState(() {
      _isExpanded = false;
    });
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
                          ))
                    : GeistText(
                        widget.itemLabelBuilder(item),
                        variant: GeistTextVariant.bodyMedium,
                        customColor: GeistColors.gray800,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Proxy Import Dialog Widget
class _ProxyImportDialog extends StatefulWidget {
  final Function(List<ProxyModel>) onImport;

  const _ProxyImportDialog({required this.onImport});

  @override
  State<_ProxyImportDialog> createState() => _ProxyImportDialogState();
}

class _ProxyImportDialogState extends State<_ProxyImportDialog> {
  late TextEditingController _proxyListController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  ProxyType _selectedProxyType = ProxyType.http;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _proxyListController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _proxyListController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      child: AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GeistBorders.radiusLarge),
        ),
        title: GeistText.headingMedium('Import Proxies'),
        content: SingleChildScrollView(
          child: SizedBox(
            height: 415,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Load from File Button
                GeistButton(
                  text: 'Load from File',
                  variant: GeistButtonVariant.outline,
                  onPressed: _loadFromFile,
                  width: double.infinity,
                ),

                SizedBox(height: GeistSpacing.md),

                // Proxy List Text Field
                GeistText.bodyMedium('Proxies List'),
                SizedBox(height: GeistSpacing.sm),
                Expanded(
                  child: GeistInput(
                    controller: _proxyListController,
                    placeholder:
                        'Enter proxies (one per line)\n1.1.1.1:80\n2.2.2.2:8080\n3.3.3.3:3128:user:pass',
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 4,
                  ),
                ),

                // Advanced Syntax Information
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: GeistSpacing.md,
                    vertical: GeistSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: GeistColors.lightSurface,
                    borderRadius: BorderRadius.circular(
                      GeistBorders.radiusMedium,
                    ),
                    border: Border.all(color: GeistColors.lightBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GeistText.bodyMedium('Advanced Syntax:'),
                      SizedBox(height: GeistSpacing.xs),
                      GeistText.bodySmall(
                        'Type: (http)1.1.1.1:80',
                        customColor: GeistColors.lightTextSecondary,
                      ),
                      GeistText.bodySmall(
                        'Auth: 1.1.1.1:80:username:password',
                        customColor: GeistColors.lightTextSecondary,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: GeistSpacing.md),

                // Proxy Type Dropdown
                GeistText.bodyMedium('Proxy Type'),
                SizedBox(height: GeistSpacing.xs),
                _GeistDropdown<ProxyType>(
                  label: 'Proxy Type',
                  value: _selectedProxyType,
                  items: ProxyType.values,
                  itemLabelBuilder: (type) => type.name.toUpperCase(),
                  onChanged: (ProxyType newValue) {
                    setState(() {
                      _selectedProxyType = newValue;
                    });
                  },
                ),

                SizedBox(height: GeistSpacing.md),

                // Optional Authentication Fields
                Row(
                  children: [
                    Expanded(
                      child: GeistInput(
                        label: 'Username',
                        controller: _usernameController,
                        placeholder: 'Enter username',
                      ),
                    ),
                    SizedBox(width: GeistSpacing.md),
                    Expanded(
                      child: GeistInput(
                        label: 'Password',
                        controller: _passwordController,
                        placeholder: 'Enter password',
                        obscureText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          GeistButton(
            text: 'Cancel',
            variant: GeistButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          GeistButton(
            text: _isLoading ? 'Importing...' : 'Import Proxies',
            variant: GeistButtonVariant.filled,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _importProxies,
          ),
        ],
      ),
    );
  }

  Future<void> _loadFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();

        setState(() {
          _proxyListController.text = content;
        });
      }
    } catch (e) {
      context.showErrorToast('Failed to load file: $e');
    }
  }

  Future<void> _importProxies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final proxyLines = _proxyListController.text.split('\n');
      final proxies = <ProxyModel>[];
      final seenAddresses = <String>{};

      final globalUsername = _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim();
      final globalPassword = _passwordController.text.trim().isEmpty
          ? null
          : _passwordController.text.trim();

      for (final line in proxyLines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        ProxyModel? proxy;

        // Parse advanced syntax: (type)host:port
        if (trimmed.startsWith('(') && trimmed.contains(')')) {
          final typeEndIndex = trimmed.indexOf(')');
          if (typeEndIndex > 1) {
            final typeStr = trimmed.substring(1, typeEndIndex).toLowerCase();
            final addressPart = trimmed.substring(typeEndIndex + 1);

            final proxyType = _parseProxyType(typeStr);
            proxy = _parseProxyWithType(
              addressPart,
              proxyType,
              globalUsername,
              globalPassword,
            );
          }
        } else {
          // Standard parsing
          proxy = _parseProxyWithType(
            trimmed,
            _selectedProxyType,
            globalUsername,
            globalPassword,
          );
        }

        if (proxy != null) {
          final address = '${proxy.address}:${proxy.port}';
          if (!seenAddresses.contains(address)) {
            seenAddresses.add(address);
            proxies.add(proxy);
          }
        }
      }

      if (proxies.isNotEmpty) {
        widget.onImport(proxies);
        Navigator.of(context).pop();
      } else {
        context.showWarningToast('No valid proxies found');
      }
    } catch (e) {
      context.showErrorToast('Import failed: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ProxyType _parseProxyType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'http':
        return ProxyType.http;
      case 'socks4':
        return ProxyType.socks4;
      case 'socks5':
        return ProxyType.socks5;
      default:
        return ProxyType.http;
    }
  }

  ProxyModel? _parseProxyWithType(
    String proxyStr,
    ProxyType type,
    String? globalUsername,
    String? globalPassword,
  ) {
    try {
      final parts = proxyStr.split(':');
      if (parts.length < 2) return null;

      final address = parts[0].trim();
      final port = int.tryParse(parts[1].trim());
      if (port == null) return null;

      // Determine username/password
      String? username = globalUsername;
      String? password = globalPassword;

      // If proxy line has auth info, use it instead of global
      if (parts.length >= 4) {
        username = parts[2].trim().isEmpty ? null : parts[2].trim();
        password = parts[3].trim().isEmpty ? null : parts[3].trim();
      }

      // Generate unique ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (address.hashCode + port.hashCode).abs();
      final uniqueId = '${timestamp}_$random';

      return ProxyModel(
        id: uniqueId,
        address: address,
        port: port,
        type: type,
        status: ProxyStatus.untested,
        username: username,
        password: password,
      );
    } catch (e) {
      return null;
    }
  }
}

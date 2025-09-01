import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';

import 'package:bullet_droid/features/proxies/models/proxy_model.dart';
import 'package:bullet_droid/features/proxies/providers/proxies_provider.dart';

/// Data table for displaying proxies
class ProxyDataTable extends ConsumerStatefulWidget {
  final ProxiesState proxiesState;
  final String? selectedProxyId;
  final bool onlyUntested;
  final ValueChanged<String> onProxySelected;

  const ProxyDataTable({
    super.key,
    required this.proxiesState,
    required this.selectedProxyId,
    required this.onlyUntested,
    required this.onProxySelected,
  });

  @override
  ConsumerState<ProxyDataTable> createState() => _ProxyDataTableState();
}

class _ProxyDataTableState extends ConsumerState<ProxyDataTable> {
  final ScrollController _headerHorizontalController = ScrollController();
  final ScrollController _bodyHorizontalController = ScrollController();
  bool _isSyncingHorizontal = false;

  late Map<String, double> _columnWidths;

  bool _isResizing = false;
  bool _actuallyResizing = false;

  @override
  void initState() {
    super.initState();
    _initializeColumnWidths();

    // Keep header in sync with body horizontal scroll
    _bodyHorizontalController.addListener(_syncHeaderWithBody);
  }

  void _initializeColumnWidths() {
    _columnWidths = {
      'Type': 80,
      'Host': 150,
      'Port': 80,
      'Username': 120,
      'Password': 120,
      'Status': 100,
      'Uses': 80,
      'Ping': 80,
      'Country': 100,
      'Last Checked': 150,
    };
  }

  void _updateColumnWidth(String columnName, double delta) {
    setState(() {
      final currentWidth = _columnWidths[columnName] ?? 100;
      final newWidth = (currentWidth + delta).clamp(50.0, 500.0);
      _columnWidths[columnName] = newWidth;
    });
  }

  @override
  void dispose() {
    _headerHorizontalController.dispose();
    _bodyHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allProxies = widget.proxiesState.proxies;
    final displayProxies = widget.onlyUntested
        ? allProxies
              .where(
                (p) =>
                    p.status == ProxyStatus.untested ||
                    p.status == ProxyStatus.testing,
              )
              .toList()
        : allProxies;

    return Column(
      children: [
        Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [GeistColors.gray100, GeistColors.gray50],
            ),
            border: const Border(
              bottom: BorderSide(color: GeistColors.gray300, width: 1.5),
            ),
            boxShadow: [
              BoxShadow(
                color: GeistColors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: _headerHorizontalController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(children: _buildHeaderColumns()),
          ),
        ),

        // Data rows
        Expanded(
          child: displayProxies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.dns_outlined,
                        size: 48,
                        color: GeistColors.gray400,
                      ),
                      const SizedBox(height: GeistSpacing.md),
                      GeistText(
                        'No proxies available',
                        variant: GeistTextVariant.bodyLarge,
                        fontWeight: FontWeight.w500,
                        customColor: GeistColors.gray600,
                      ),
                      const SizedBox(height: GeistSpacing.xs),
                      GeistText(
                        'Import proxies to get started',
                        variant: GeistTextVariant.bodyMedium,
                        customColor: GeistColors.gray500,
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  controller: _bodyHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: _computeTableWidth(),
                    child: ListView.builder(
                      itemCount: displayProxies.length,
                      itemExtent: 52,
                      itemBuilder: (context, index) {
                        final proxy = displayProxies[index];
                        final isSelected = widget.selectedProxyId == proxy.id;
                        final isEven = index.isEven;
                        return Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? GeistColors.blue.withValues(alpha: 0.1)
                                : (isEven
                                      ? GeistColors.white
                                      : GeistColors.gray50),
                            border: const Border(
                              bottom: BorderSide(
                                color: GeistColors.gray200,
                                width: 0.8,
                              ),
                            ),
                          ),
                          child: Material(
                            color: GeistColors.transparent,
                            child: InkWell(
                              onTap: () => widget.onProxySelected(proxy.id),
                              child: SizedBox(
                                width: _computeTableWidth(),
                                child: Row(children: _buildDataColumns(proxy)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  void _syncHeaderWithBody() {
    if (_isSyncingHorizontal) return;
    _isSyncingHorizontal = true;
    if (_headerHorizontalController.hasClients) {
      _headerHorizontalController.jumpTo(_bodyHorizontalController.offset);
    }
    _isSyncingHorizontal = false;
  }

  double _computeTableWidth() {
    const keys = [
      'Type',
      'Host',
      'Port',
      'Username',
      'Password',
      'Status',
      'Uses',
      'Ping',
      'Country',
      'Last Checked',
    ];
    double width = 0;
    for (final key in keys) {
      width += _columnWidths[key] ?? 100;
    }
    return width;
  }

  List<Widget> _buildHeaderColumns() {
    return [
      _buildHeaderCell(
        'Type',
        width: _columnWidths['Type']!,
        columnKey: 'Type',
      ),
      _buildHeaderCell(
        'Host',
        width: _columnWidths['Host']!,
        columnKey: 'Host',
      ),
      _buildHeaderCell(
        'Port',
        width: _columnWidths['Port']!,
        columnKey: 'Port',
      ),
      _buildHeaderCell(
        'Username',
        width: _columnWidths['Username']!,
        columnKey: 'Username',
      ),
      _buildHeaderCell(
        'Password',
        width: _columnWidths['Password']!,
        columnKey: 'Password',
      ),
      _buildHeaderCell(
        'Status',
        width: _columnWidths['Status']!,
        columnKey: 'Status',
      ),
      _buildHeaderCell(
        'Uses',
        width: _columnWidths['Uses']!,
        columnKey: 'Uses',
      ),
      _buildHeaderCell(
        'Ping',
        width: _columnWidths['Ping']!,
        columnKey: 'Ping',
      ),
      _buildHeaderCell(
        'Country',
        width: _columnWidths['Country']!,
        columnKey: 'Country',
      ),
      _buildHeaderCell(
        'Last Checked',
        width: _columnWidths['Last Checked']!,
        columnKey: 'Last Checked',
        isLast: true,
      ),
    ];
  }

  List<Widget> _buildDataColumns(ProxyModel proxy) {
    return [
      _buildDataCell(
        proxy.type.name.toUpperCase(),
        width: _columnWidths['Type']!,
      ),
      _buildDataCell(proxy.address, width: _columnWidths['Host']!),
      _buildDataCell(proxy.port.toString(), width: _columnWidths['Port']!),
      _buildDataCell(proxy.username ?? '-', width: _columnWidths['Username']!),
      _buildDataCell(proxy.password ?? '-', width: _columnWidths['Password']!),
      _buildDataCell(
        proxy.status.name.toUpperCase(),
        width: _columnWidths['Status']!,
        color: _getStatusColor(proxy.status),
      ),
      _buildDataCell(
        proxy.successCount.toString(),
        width: _columnWidths['Uses']!,
      ),
      _buildDataCell(
        proxy.responseTime > 0 ? '${proxy.responseTime}ms' : '-',
        width: _columnWidths['Ping']!,
      ),
      _buildDataCell(proxy.country ?? '-', width: _columnWidths['Country']!),
      _buildDataCell(
        proxy.lastChecked != null
            ? _formatLastChecked(proxy.lastChecked!)
            : 'Never',
        width: _columnWidths['Last Checked']!,
      ),
    ];
  }

  Color? _getStatusColor(ProxyStatus status) {
    switch (status) {
      case ProxyStatus.alive:
        return GeistColors.successColor;
      case ProxyStatus.dead:
        return GeistColors.errorColor;
      case ProxyStatus.untested:
        return GeistColors.gray500;
      case ProxyStatus.testing:
        return GeistColors.blue;
    }
  }

  Widget _buildHeaderCell(
    String text, {
    double width = 100,
    String? columnKey,
    bool isLast = false,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          padding: const EdgeInsets.only(
            left: GeistSpacing.sm,
            right: GeistSpacing.md,
            top: GeistSpacing.sm,
            bottom: GeistSpacing.sm,
          ),
          child: GeistText(
            text,
            variant: GeistTextVariant.bodyMedium,
            fontWeight: FontWeight.w700,
            customColor: GeistColors.gray800,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            selectable: true,
          ),
        ),
        if (!isLast && columnKey != null)
          Positioned(
            right: -12,
            top: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              onEnter: (_) {
                setState(() {
                  _isResizing = true;
                });
              },
              onExit: (_) {
                if (!_actuallyResizing) {
                  setState(() {
                    _isResizing = false;
                  });
                }
              },
              child: GestureDetector(
                onHorizontalDragStart: (_) {
                  setState(() {
                    _isResizing = true;
                    _actuallyResizing = true;
                  });
                },
                onHorizontalDragUpdate: (details) {
                  _updateColumnWidth(columnKey, details.delta.dx);
                },
                onHorizontalDragEnd: (_) {
                  setState(() {
                    _isResizing = false;
                    _actuallyResizing = false;
                  });
                },
                onHorizontalDragCancel: () {
                  setState(() {
                    _isResizing = false;
                    _actuallyResizing = false;
                  });
                },
                child: Container(
                  width: 32,
                  color: Colors.transparent,
                  child: Center(
                    child: Container(
                      width: 2,
                      color: _isResizing
                          ? GeistColors.blue
                          : GeistColors.gray300,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDataCell(String text, {double width = 100, Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(GeistSpacing.sm),
      child: GeistText(
        text,
        variant: GeistTextVariant.bodySmall,
        customColor: color ?? GeistColors.gray800,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        selectable: true,
      ),
    );
  }

  String _formatLastChecked(DateTime lastChecked) {
    final now = DateTime.now();
    final difference = now.difference(lastChecked);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

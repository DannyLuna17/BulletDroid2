import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/features/runner/providers/runner_provider.dart';
import 'package:bullet_droid/features/runner/models/job_progress.dart';

/// Horizontally-scrollable data table for runner results.
/// Displays Bots/Hits/Custom/ToCheck/Logs with resizable columns and
/// synchronized header/body scrolling.
class RunnerDataTable extends ConsumerStatefulWidget {
  final TabController tabController;
  final String runnerId;
  final bool showProxyColumn;

  const RunnerDataTable({
    super.key,
    required this.tabController,
    required this.runnerId,
    required this.showProxyColumn,
  });

  @override
  ConsumerState<RunnerDataTable> createState() => _RunnerDataTableState();
}

class _RunnerDataTableState extends ConsumerState<RunnerDataTable> {
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

    widget.tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _initializeColumnWidths() {
    _columnWidths = {
      'Date': 120,
      'ID': 40,
      'Status': 130,
      'Data': 250,
      'Proxy': 150,
      'Elapsed': 100,
      'Time': 100,
      'Capture': 200,
      'Type': 100,
      'Details': 150,
      'Reason': 140,
      'Level': 80,
      'Source': 100,
      'Message': 100,
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
    final runnerInstance = ref.watch(runnerInstanceProvider(widget.runnerId));
    final jobProgress = ref.watch(
      activeRunnerJobProgressProvider(widget.runnerId),
    );

    final currentData = _getCurrentTabData(runnerInstance, jobProgress);

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
            border: Border(
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
        Expanded(
          child: currentData.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  controller: _bodyHorizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: _computeTableWidth(),
                    child: ListView.builder(
                      itemCount: currentData.length,
                      itemExtent: 52,
                      itemBuilder: (context, index) {
                        final isEven = index.isEven;
                        return Container(
                          decoration: BoxDecoration(
                            color: isEven
                                ? GeistColors.white
                                : GeistColors.gray50,
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
                              onTap: () {},
                              child: SizedBox(
                                width: _computeTableWidth(),
                                child: Row(
                                  children: _buildDataColumnsForCurrentTab(
                                    currentData[index],
                                  ),
                                ),
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
    final selectedTab = widget.tabController.index;
    double width = 0;
    List<String> keys;
    switch (selectedTab) {
      case 0:
        keys = [
          'ID',
          'Status',
          'Data',
          if (widget.showProxyColumn) 'Proxy',
          'Elapsed',
        ];
        break;
      case 1:
        keys = ['Date', 'Data', if (widget.showProxyColumn) 'Proxy', 'Capture'];
        break;
      case 2:
        keys = ['Date', 'Data', 'Type', 'Details'];
        break;
      case 3:
        keys = ['Date', 'Data', 'Reason'];
        break;
      case 4:
        keys = ['Date', 'Level', 'Source', 'Message'];
        break;
      default:
        keys = [];
    }
    for (final key in keys) {
      width += _columnWidths[key] ?? 100;
    }
    return width;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.table_chart_outlined,
            size: 48,
            color: GeistColors.gray400,
          ),
          SizedBox(height: GeistSpacing.md),
          const Text(
            'No data available',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: GeistColors.gray600,
            ),
          ),
          SizedBox(height: GeistSpacing.xs),
          const Text(
            'Start a job to see results here',
            style: TextStyle(color: GeistColors.gray500),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getCurrentTabData(dynamic runnerInstance, JobProgress? jobProgress) {
    final selectedTab = widget.tabController.index;
    switch (selectedTab) {
      case 0:
        return runnerInstance?.botResults ?? [];
      case 1:
        return jobProgress?.hits ?? [];
      case 2:
        return jobProgress?.customs ?? [];
      case 3:
        return jobProgress?.toChecks ?? [];
      case 4:
        return [];
      default:
        return [];
    }
  }

  List<Widget> _buildDataColumnsForCurrentTab(dynamic data) {
    final selectedTab = widget.tabController.index;
    switch (selectedTab) {
      case 0:
        return _buildBotDataColumns(data as BotExecutionResult);
      case 1:
        return _buildValidDataColumns(data as ValidDataResult);
      case 2:
        return _buildValidDataColumns(data as ValidDataResult);
      case 3:
        return _buildValidDataColumns(data as ValidDataResult);
      case 4:
        return [];
      default:
        return [];
    }
  }

  List<Widget> _buildHeaderColumns() {
    final selectedTab = widget.tabController.index;
    switch (selectedTab) {
      case 0:
        final columns = [
          _buildHeaderCell('ID', width: _columnWidths['ID']!, columnKey: 'ID'),
          _buildHeaderCell(
            'Status',
            width: _columnWidths['Status']!,
            columnKey: 'Status',
          ),
          _buildHeaderCell(
            'Data',
            width: _columnWidths['Data']!,
            columnKey: 'Data',
          ),
        ];
        if (widget.showProxyColumn) {
          columns.add(
            _buildHeaderCell(
              'Proxy',
              width: _columnWidths['Proxy']!,
              columnKey: 'Proxy',
            ),
          );
          columns.add(
            _buildHeaderCell(
              'Elapsed',
              width: _columnWidths['Elapsed']!,
              columnKey: 'Elapsed',
              isLast: true,
            ),
          );
        } else {
          columns.add(
            _buildHeaderCell(
              'Elapsed',
              width: _columnWidths['Elapsed']!,
              columnKey: 'Elapsed',
              isLast: true,
            ),
          );
        }
        return columns;
      case 1:
        final columns = [
          _buildHeaderCell(
            'Date',
            width: _columnWidths['Date']!,
            columnKey: 'Date',
          ),
          _buildHeaderCell(
            'Data',
            width: _columnWidths['Data']!,
            columnKey: 'Data',
          ),
        ];
        if (widget.showProxyColumn) {
          columns.add(
            _buildHeaderCell(
              'Proxy',
              width: _columnWidths['Proxy']!,
              columnKey: 'Proxy',
            ),
          );
          columns.add(
            _buildHeaderCell(
              'Capture',
              width: _columnWidths['Capture']!,
              columnKey: 'Capture',
              isLast: true,
            ),
          );
        } else {
          columns.add(
            _buildHeaderCell(
              'Capture',
              width: _columnWidths['Capture']!,
              columnKey: 'Capture',
              isLast: true,
            ),
          );
        }
        return columns;
      case 2:
        return [
          _buildHeaderCell(
            'Date',
            width: _columnWidths['Date']!,
            columnKey: 'Date',
          ),
          _buildHeaderCell(
            'Data',
            width: _columnWidths['Data']!,
            columnKey: 'Data',
          ),
          _buildHeaderCell(
            'Type',
            width: _columnWidths['Type']!,
            columnKey: 'Type',
          ),
          _buildHeaderCell(
            'Details',
            width: _columnWidths['Details']!,
            columnKey: 'Details',
            isLast: true,
          ),
        ];
      case 3:
        return [
          _buildHeaderCell(
            'Date',
            width: _columnWidths['Date']!,
            columnKey: 'Date',
          ),
          _buildHeaderCell(
            'Data',
            width: _columnWidths['Data']!,
            columnKey: 'Data',
          ),
          _buildHeaderCell(
            'Reason',
            width: _columnWidths['Reason']!,
            columnKey: 'Reason',
            isLast: true,
          ),
        ];
      case 4:
        return [
          _buildHeaderCell(
            'Date',
            width: _columnWidths['Date']!,
            columnKey: 'Date',
          ),
          _buildHeaderCell(
            'Level',
            width: _columnWidths['Level']!,
            columnKey: 'Level',
          ),
          _buildHeaderCell(
            'Source',
            width: _columnWidths['Source']!,
            columnKey: 'Source',
          ),
          _buildHeaderCell(
            'Message',
            width: _columnWidths['Message']!,
            columnKey: 'Message',
            isLast: true,
          ),
        ];
      default:
        return [];
    }
  }

  List<Widget> _buildBotDataColumns(BotExecutionResult result) {
    final columns = [
      _buildDataCell(result.botId.toString(), width: _columnWidths['ID']!),
      _buildDataCell(result.statusString, width: _columnWidths['Status']!),
      _buildDataCell(result.data, width: _columnWidths['Data']!),
    ];
    if (widget.showProxyColumn) {
      columns.add(
        _buildDataCell(result.proxy ?? 'NONE', width: _columnWidths['Proxy']!),
      );
    }
    columns.add(
      _buildDataCell(
        '${result.timestamp.millisecondsSinceEpoch}ms',
        width: _columnWidths['Elapsed']!,
      ),
    );
    return columns;
  }

  List<Widget> _buildValidDataColumns(ValidDataResult result) {
    final formatter = DateFormat('MM/dd HH:mm:ss');
    final selectedTab = widget.tabController.index;
    switch (selectedTab) {
      case 1:
        final columns = [
          _buildDataCell(
            formatter.format(result.completionTime),
            width: _columnWidths['Date']!,
          ),
          _buildDataCell(result.data, width: _columnWidths['Data']!),
        ];
        if (widget.showProxyColumn) {
          columns.add(
            _buildDataCell(
              result.proxy ?? 'NONE',
              width: _columnWidths['Proxy']!,
            ),
          );
        }
        columns.add(
          _buildDataCell(
            result.captures?.entries
                    .map((e) => '${e.key}=${e.value}')
                    .join(', ') ??
                '',
            width: _columnWidths['Capture']!,
          ),
        );
        return columns;
      case 2:
        return [
          _buildDataCell(
            formatter.format(result.completionTime),
            width: _columnWidths['Date']!,
          ),
          _buildDataCell(result.data, width: _columnWidths['Data']!),
          _buildDataCell(result.status.name, width: _columnWidths['Type']!),
          _buildDataCell(
            result.customStatus ?? '',
            width: _columnWidths['Details']!,
          ),
        ];
      case 3:
        return [
          _buildDataCell(
            formatter.format(result.completionTime),
            width: _columnWidths['Date']!,
          ),
          _buildDataCell(result.data, width: _columnWidths['Data']!),
          _buildDataCell(result.status.name, width: _columnWidths['Reason']!),
        ];
      default:
        return [];
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
          padding: EdgeInsets.only(
            left: GeistSpacing.sm,
            right: GeistSpacing.md,
            top: GeistSpacing.sm,
            bottom: GeistSpacing.sm,
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: GeistColors.gray800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

  Widget _buildDataCell(String text, {double width = 100}) {
    return Container(
      width: width,
      padding: EdgeInsets.all(GeistSpacing.sm),
      child: SelectableText(
        text,
        maxLines: 1,
        style: const TextStyle(color: GeistColors.gray800, fontSize: 14),
      ),
    );
  }
}

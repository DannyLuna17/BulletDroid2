import 'package:flutter/material.dart';
import 'package:bullet_droid/core/design_tokens/colors.dart';
import 'package:bullet_droid/core/design_tokens/spacing.dart';
import 'package:bullet_droid/core/design_tokens/borders.dart';

import 'package:bullet_droid/core/design_tokens/breakpoints.dart';
import 'package:bullet_droid/core/components/atoms/geist_text.dart';
import 'package:bullet_droid/core/components/atoms/status_indicator.dart';

/// Data table component
class GeistDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final bool sortAscending;
  final int? sortColumnIndex;
  final Function(int columnIndex, bool ascending)? onSort;
  final bool showCheckboxColumn;
  final Function(bool? value)? onSelectAll;
  final bool isLoading;
  final String? emptyMessage;
  final double? minColumnWidth;
  final double? maxColumnWidth;
  final bool enableHorizontalScroll;
  final ScrollController? horizontalScrollController;
  final ScrollController? verticalScrollController;
  final double? fixedHeight;
  final bool stickyHeader;
  final Map<String, double>? columnWidths;
  final Function(String columnKey, double width)? onColumnResize;

  const GeistDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.sortAscending = true,
    this.sortColumnIndex,
    this.onSort,
    this.showCheckboxColumn = false,
    this.onSelectAll,
    this.isLoading = false,
    this.emptyMessage,
    this.minColumnWidth = 100,
    this.maxColumnWidth = 300,
    this.enableHorizontalScroll = true,
    this.horizontalScrollController,
    this.verticalScrollController,
    this.fixedHeight,
    this.stickyHeader = true,
    this.columnWidths,
    this.onColumnResize,
  });

  @override
  State<GeistDataTable> createState() => _GeistDataTableState();
}

class _GeistDataTableState extends State<GeistDataTable> {
  late final ScrollController _headerHorizontalScrollController;
  late ScrollController _bodyHorizontalScrollController;
  late ScrollController _verticalScrollController;
  late Map<String, double> _columnWidths;
  bool _isSyncingHorizontal = false;

  @override
  void initState() {
    super.initState();
    _bodyHorizontalScrollController =
        widget.horizontalScrollController ?? ScrollController();
    _headerHorizontalScrollController = ScrollController();
    _verticalScrollController =
        widget.verticalScrollController ?? ScrollController();

    _bodyHorizontalScrollController.addListener(_syncHeaderWithBody);
    _initializeColumnWidths();
  }

  @override
  void dispose() {
    _headerHorizontalScrollController.dispose();
    if (widget.horizontalScrollController == null) {
      _bodyHorizontalScrollController.dispose();
    }
    if (widget.verticalScrollController == null) {
      _verticalScrollController.dispose();
    }
    super.dispose();
  }

  void _initializeColumnWidths() {
    _columnWidths = Map.from(widget.columnWidths ?? {});

    // Set default widths for columns without specified widths
    for (int i = 0; i < widget.columns.length; i++) {
      final column = widget.columns[i];
      final key = column.label.toString();
      if (!_columnWidths.containsKey(key)) {
        _columnWidths[key] = widget.minColumnWidth ?? 100;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GeistBreakpoints.isMobile(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: GeistBorders.tableRadius,
        border: Border.all(
          color: GeistColors.lightBorder,
          width: GeistBorders.widthThin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.stickyHeader) _buildHeader(isMobile),
          Expanded(
            child: widget.isLoading
                ? _buildLoadingState()
                : widget.rows.isEmpty
                ? _buildEmptyState()
                : _buildDataRows(isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: GeistColors.gray50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(GeistBorders.radiusMedium),
          topRight: Radius.circular(GeistBorders.radiusMedium),
        ),
        border: Border(
          bottom: BorderSide(
            color: GeistColors.lightBorder,
            width: GeistBorders.widthThin,
          ),
        ),
      ),
      child: widget.enableHorizontalScroll
          ? SingleChildScrollView(
              controller: _headerHorizontalScrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: _buildHeaderRow(isMobile),
            )
          : _buildHeaderRow(isMobile),
    );
  }

  Widget _buildHeaderRow(bool isMobile) {
    return Row(
      children: [
        if (widget.showCheckboxColumn) _buildCheckboxHeader(),
        ...widget.columns.asMap().entries.map((entry) {
          final index = entry.key;
          final column = entry.value;
          return _buildHeaderCell(column, index, isMobile);
        }),
      ],
    );
  }

  Widget _buildCheckboxHeader() {
    return Container(
      width: 48,
      height: GeistSpacing.tableHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.tableCellPadding),
      child: Checkbox(
        value: _areAllRowsSelected(),
        onChanged: widget.onSelectAll,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildHeaderCell(DataColumn column, int index, bool isMobile) {
    final key = column.label.toString();
    final width = _columnWidths[key] ?? widget.minColumnWidth ?? 100;
    final isSort = widget.sortColumnIndex == index;

    return Container(
      width: width,
      height: GeistSpacing.tableHeaderHeight,
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.tableCellPadding),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: column.onSort != null ? () => _handleSort(index) : null,
              child: Row(
                children: [
                  Expanded(
                    child: GeistText.labelMedium(
                      column.label.toString(),
                      color: GeistTextColor.primary,
                    ),
                  ),
                  if (column.onSort != null) ...[
                    SizedBox(width: GeistSpacing.xs),
                    Icon(
                      isSort
                          ? (widget.sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward)
                          : Icons.unfold_more,
                      size: 14,
                      color: isSort
                          ? GeistColors.blue
                          : GeistColors.lightTextTertiary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.onColumnResize != null) _buildResizeHandle(key),
        ],
      ),
    );
  }

  Widget _buildResizeHandle(String columnKey) {
    return GestureDetector(
      onPanUpdate: (details) =>
          _handleColumnResize(columnKey, details.delta.dx),
      child: Container(
        width: 8,
        height: GeistSpacing.tableHeaderHeight,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 1,
            height: 16,
            color: GeistColors.lightBorder,
          ),
        ),
      ),
    );
  }

  Widget _buildDataRows(bool isMobile) {
    final double tableWidth = _computeTableWidth();

    if (widget.enableHorizontalScroll) {
      return SingleChildScrollView(
        controller: _bodyHorizontalScrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: ListView.builder(
            controller: _verticalScrollController,
            itemCount: widget.rows.length,
            itemExtent: GeistSpacing.tableRowHeight,
            itemBuilder: (context, index) {
              final row = widget.rows[index];
              return _buildDataRow(row, index, isMobile);
            },
          ),
        ),
      );
    }

    // No horizontal scrolling: simple virtualized vertical list
    return ListView.builder(
      controller: _verticalScrollController,
      itemCount: widget.rows.length,
      itemExtent: GeistSpacing.tableRowHeight,
      itemBuilder: (context, index) {
        final row = widget.rows[index];
        return _buildDataRow(row, index, isMobile);
      },
    );
  }

  double _computeTableWidth() {
    double width = 0;
    if (widget.showCheckboxColumn) {
      width += 48;
    }
    for (int i = 0; i < widget.columns.length; i++) {
      final key = widget.columns[i].label.toString();
      width += _columnWidths[key] ?? widget.minColumnWidth ?? 100;
    }
    return width;
  }

  void _syncHeaderWithBody() {
    if (_isSyncingHorizontal) return;
    _isSyncingHorizontal = true;
    if (_headerHorizontalScrollController.hasClients) {
      _headerHorizontalScrollController.jumpTo(
        _bodyHorizontalScrollController.offset,
      );
    }
    _isSyncingHorizontal = false;
  }

  Widget _buildDataRow(DataRow row, int index, bool isMobile) {
    final isSelected = row.selected ?? false;
    final isEven = index % 2 == 0;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? GeistColors.blue.withValues(alpha: 0.05)
            : isEven
            ? GeistColors.lightSurface
            : GeistColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: GeistColors.lightBorder,
            width: GeistBorders.widthThin,
          ),
        ),
      ),
      child: InkWell(
        onTap: row.onSelectChanged != null
            ? () => row.onSelectChanged!(!isSelected)
            : null,
        child: Row(
          children: [
            if (widget.showCheckboxColumn) _buildCheckboxCell(row),
            ...row.cells.asMap().entries.map((entry) {
              final cellIndex = entry.key;
              final cell = entry.value;
              return _buildDataCell(cell, cellIndex, isMobile);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxCell(DataRow row) {
    return Container(
      width: 48,
      height: GeistSpacing.tableRowHeight,
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.tableCellPadding),
      child: Checkbox(
        value: row.selected ?? false,
        onChanged: row.onSelectChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildDataCell(DataCell cell, int index, bool isMobile) {
    final columnKey = widget.columns[index].label.toString();
    final width = _columnWidths[columnKey] ?? widget.minColumnWidth ?? 100;

    return Container(
      width: width,
      height: GeistSpacing.tableRowHeight,
      padding: EdgeInsets.symmetric(horizontal: GeistSpacing.tableCellPadding),
      child: Align(alignment: Alignment.centerLeft, child: cell.child),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(GeistColors.blue),
            ),
            SizedBox(height: GeistSpacing.md),
            GeistText.bodyMedium(
              'Loading data...',
              color: GeistTextColor.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: GeistColors.lightTextTertiary,
            ),
            SizedBox(height: GeistSpacing.md),
            GeistText.bodyMedium(
              widget.emptyMessage ?? 'No data available',
              color: GeistTextColor.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _handleSort(int columnIndex) {
    if (widget.onSort != null) {
      final ascending = widget.sortColumnIndex == columnIndex
          ? !widget.sortAscending
          : true;
      widget.onSort!(columnIndex, ascending);
    }
  }

  void _handleColumnResize(String columnKey, double delta) {
    setState(() {
      final currentWidth =
          _columnWidths[columnKey] ?? widget.minColumnWidth ?? 100;
      final newWidth = (currentWidth + delta)
          .clamp(widget.minColumnWidth ?? 50, widget.maxColumnWidth ?? 500)
          .toDouble();
      _columnWidths[columnKey] = newWidth;
    });

    if (widget.onColumnResize != null) {
      widget.onColumnResize!(columnKey, _columnWidths[columnKey]!);
    }
  }

  bool _areAllRowsSelected() {
    return widget.rows.isNotEmpty &&
        widget.rows.every((row) => row.selected ?? false);
  }
}

/// Enhanced data column with additional properties
class DataColumn {
  final Widget label;
  final String? tooltip;
  final bool numeric;
  final VoidCallback? onSort;
  final bool sortable;

  const DataColumn({
    required this.label,
    this.tooltip,
    this.numeric = false,
    this.onSort,
    this.sortable = false,
  });
}

/// Enhanced data row with additional properties
class DataRow {
  final List<DataCell> cells;
  final bool? selected;
  final ValueChanged<bool?>? onSelectChanged;
  final Color? color;

  const DataRow({
    required this.cells,
    this.selected,
    this.onSelectChanged,
    this.color,
  });
}

/// Enhanced data cell with additional properties
class DataCell {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool showEditIcon;
  final VoidCallback? onLongPress;

  const DataCell(
    this.child, {
    this.onTap,
    this.tooltip,
    this.showEditIcon = false,
    this.onLongPress,
  });
}

/// Specialized data table variants for common use cases
class GeistDataTableVariants {
  /// Simple data table for basic tabular data
  static Widget simple({
    required List<String> headers,
    required List<List<String>> rows,
    bool sortAscending = true,
    int? sortColumnIndex,
    Function(int columnIndex, bool ascending)? onSort,
  }) {
    final columns = headers
        .map(
          (header) => DataColumn(
            label: GeistText.labelMedium(header, selectable: true),
            sortable: onSort != null,
            onSort: onSort != null ? () {} : null,
          ),
        )
        .toList();

    final dataRows = rows
        .map(
          (row) => DataRow(
            cells: row
                .map(
                  (cell) =>
                      DataCell(GeistText.bodyMedium(cell, selectable: true)),
                )
                .toList(),
          ),
        )
        .toList();

    return GeistDataTable(
      columns: columns,
      rows: dataRows,
      sortAscending: sortAscending,
      sortColumnIndex: sortColumnIndex,
      onSort: onSort,
    );
  }

  /// Technical data table with monospace content
  static Widget technical({
    required List<String> headers,
    required List<List<String>> rows,
    bool sortAscending = true,
    int? sortColumnIndex,
    Function(int columnIndex, bool ascending)? onSort,
  }) {
    final columns = headers
        .map(
          (header) => DataColumn(
            label: GeistText.labelMedium(header, selectable: true),
            sortable: onSort != null,
            onSort: onSort != null ? () {} : null,
          ),
        )
        .toList();

    final dataRows = rows
        .map(
          (row) => DataRow(
            cells: row
                .map(
                  (cell) =>
                      DataCell(GeistText.codeMedium(cell, selectable: true)),
                )
                .toList(),
          ),
        )
        .toList();

    return GeistDataTable(
      columns: columns,
      rows: dataRows,
      sortAscending: sortAscending,
      sortColumnIndex: sortColumnIndex,
      onSort: onSort,
    );
  }

  /// Status data table with status indicators
  static Widget status({
    required List<String> headers,
    required List<List<dynamic>> rows, // Can contain StatusIndicatorState
    bool sortAscending = true,
    int? sortColumnIndex,
    Function(int columnIndex, bool ascending)? onSort,
  }) {
    final columns = headers
        .map(
          (header) => DataColumn(
            label: GeistText.labelMedium(header, selectable: true),
            sortable: onSort != null,
            onSort: onSort != null ? () {} : null,
          ),
        )
        .toList();

    final dataRows = rows
        .map(
          (row) => DataRow(
            cells: row
                .map(
                  (cell) => DataCell(
                    cell is StatusIndicatorState
                        ? StatusIndicator(
                            state: cell,
                            variant: StatusIndicatorVariant.pill,
                          )
                        : GeistText.bodyMedium(
                            cell.toString(),
                            selectable: true,
                          ),
                  ),
                )
                .toList(),
          ),
        )
        .toList();

    return GeistDataTable(
      columns: columns,
      rows: dataRows,
      sortAscending: sortAscending,
      sortColumnIndex: sortColumnIndex,
      onSort: onSort,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid/core/utils/logging.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:bullet_droid/features/hits_db/models/hit_record.dart';
import 'package:bullet_droid/features/hits_db/services/hits_db_service.dart';
import 'package:bullet_droid/shared/providers/hive_provider.dart';
import 'package:bullet_droid/features/runner/models/job_progress.dart';

// Provider for the hits database service
final hitsDbServiceProvider = Provider<HitsDbService>((ref) {
  final hitsBox = ref.watch(hitsBoxProvider);
  return HitsDbService(hitsBox);
});

// Provider for the hits database state
final hitsDbProvider = StateNotifierProvider<HitsDbNotifier, HitsDbState>((
  ref,
) {
  final service = ref.watch(hitsDbServiceProvider);
  return HitsDbNotifier(service);
});

// State class for the hits database
class HitsDbState {
  final List<HitRecord> hits;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String selectedConfig;
  final String selectedType;
  final bool isBottomSectionExpanded;
  final Map<String, double> columnWidths;
  final int totalHits;
  final List<String> availableConfigs;
  final List<String> availableTypes;
  final bool isExporting;

  const HitsDbState({
    this.hits = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedConfig = 'All',
    this.selectedType = 'All',
    this.isBottomSectionExpanded = true,
    this.columnWidths = const {
      'Data': 150.0,
      'Type': 100.0,
      'Config': 120.0,
      'Date': 140.0,
      'Wordlist': 120.0,
      'Proxy': 100.0,
      'Captured': 250.0,
    },
    this.totalHits = 0,
    this.availableConfigs = const [],
    this.availableTypes = const [],
    this.isExporting = false,
  });

  HitsDbState copyWith({
    List<HitRecord>? hits,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? selectedConfig,
    String? selectedType,
    bool? isBottomSectionExpanded,
    Map<String, double>? columnWidths,
    int? totalHits,
    List<String>? availableConfigs,
    List<String>? availableTypes,
    bool? isExporting,
  }) {
    return HitsDbState(
      hits: hits ?? this.hits,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedConfig: selectedConfig ?? this.selectedConfig,
      selectedType: selectedType ?? this.selectedType,
      isBottomSectionExpanded:
          isBottomSectionExpanded ?? this.isBottomSectionExpanded,
      columnWidths: columnWidths ?? this.columnWidths,
      totalHits: totalHits ?? this.totalHits,
      availableConfigs: availableConfigs ?? this.availableConfigs,
      availableTypes: availableTypes ?? this.availableTypes,
      isExporting: isExporting ?? this.isExporting,
    );
  }
}

// Notifier class for the hits database
class HitsDbNotifier extends StateNotifier<HitsDbState> {
  final HitsDbService _service;
  static const _uuid = Uuid();

  HitsDbNotifier(this._service) : super(const HitsDbState()) {
    _loadInitialData();
  }

  /// Load initial data from the database
  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load UI state first
      await _loadUiState();

      // Then load data
      await _refreshData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh all data from the database
  Future<void> _refreshData() async {
    final hits = _service.getHits(
      searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      configFilter: state.selectedConfig,
      typeFilter: state.selectedType,
    );

    final availableConfigs = ['All', ..._service.getUniqueConfigNames()];
    final availableTypes = ['All', ..._service.getUniqueTypes()];
    final totalHits = _service.getHitsCount();

    state = state.copyWith(
      hits: hits,
      isLoading: false,
      error: null,
      availableConfigs: availableConfigs,
      availableTypes: availableTypes,
      totalHits: totalHits,
    );
  }

  /// Update search query and refresh data
  Future<void> updateSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await _refreshData();
  }

  /// Update selected config filter and refresh data
  Future<void> updateSelectedConfig(String config) async {
    state = state.copyWith(selectedConfig: config);
    await _refreshData();
  }

  /// Update selected type filter and refresh data
  Future<void> updateSelectedType(String type) async {
    state = state.copyWith(selectedType: type);
    await _refreshData();
  }

  /// Toggle bottom section expanded state
  void toggleBottomSection() {
    state = state.copyWith(
      isBottomSectionExpanded: !state.isBottomSectionExpanded,
    );
    _saveUiState();
  }

  /// Update column width
  void updateColumnWidth(String columnKey, double newWidth) {
    final newWidths = Map<String, double>.from(state.columnWidths);
    newWidths[columnKey] = newWidth.clamp(50.0, 500.0);
    state = state.copyWith(columnWidths: newWidths);
    _saveUiState();
  }

  /// Add a new hit record from job progress
  Future<void> addHitFromJobProgress(
    ValidDataResult validResult,
    String configId,
    String configName,
    String wordlistId,
    String wordlistName,
    String jobId,
  ) async {
    try {
      final hitRecord = HitRecord(
        id: _uuid.v4(),
        data: validResult.data,
        type: validResult.status == BotStatus.SUCCESS
            ? 'SUCCESS'
            : validResult.status == BotStatus.CUSTOM
            ? 'CUSTOM'
            : validResult.status == BotStatus.RETRY
            ? 'RETRY'
            : validResult.status == BotStatus.TOCHECK
            ? 'TOCHECK'
            : 'FAILED',
        configId: configId,
        configName: configName,
        date: validResult.completionTime,
        wordlistId: wordlistId,
        wordlistName: wordlistName,
        proxy: validResult.proxy,
        capturedData: validResult.captures ?? {},
        jobId: jobId,
      );

      await _service.addHit(hitRecord);
      await _refreshData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete all hits
  Future<void> deleteAllHits() async {
    try {
      await _service.deleteAllHits();
      await _refreshData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete filtered hits
  Future<void> deleteFilteredHits() async {
    try {
      await _service.deleteFilteredHits(
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        configFilter: state.selectedConfig,
        typeFilter: state.selectedType,
      );
      await _refreshData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete duplicate hits
  Future<void> deleteDuplicateHits() async {
    try {
      await _service.deleteDuplicateHits();
      await _refreshData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Delete a single hit by ID
  Future<void> deleteHit(String hitId) async {
    try {
      await _service.deleteHit(hitId);
      await _refreshData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Export hits to TXT file
  Future<bool> exportHitsToTxt({
    bool includeProxy = false,
    bool includeCapturedData = false,
    bool includeConfig = false,
    bool includeDate = false,
    bool includeWordlist = false,
  }) async {
    state = state.copyWith(isExporting: true);

    try {
      final success = await _service.exportHitsToTxtWithPicker(
        hits: state.hits,
        includeProxy: includeProxy,
        includeCapturedData: includeCapturedData,
        includeConfig: includeConfig,
        includeDate: includeDate,
        includeWordlist: includeWordlist,
      );

      state = state.copyWith(isExporting: false);
      return success;
    } catch (e) {
      state = state.copyWith(isExporting: false, error: e.toString());
      return false;
    }
  }

  /// Get statistics about the hits database
  Map<String, dynamic> getStats() {
    return _service.getStats();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh data manually
  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true);
    await _refreshData();
  }

  /// Load UI state from persistence
  Future<void> _loadUiState() async {
    try {
      final box = await Hive.openBox('hits_db_ui_state');

      final isExpanded = box.get('isBottomSectionExpanded', defaultValue: true);

      final savedColumnWidths = box.get(
        'columnWidths',
        defaultValue: <String, double>{},
      );
      final columnWidths = Map<String, double>.from(state.columnWidths);

      for (final entry in savedColumnWidths.entries) {
        if (columnWidths.containsKey(entry.key)) {
          columnWidths[entry.key] = entry.value;
        }
      }

      state = state.copyWith(
        isBottomSectionExpanded: isExpanded,
        columnWidths: columnWidths,
      );
    } catch (e) {
      Log.w('Error loading UI state: $e');
    }
  }

  /// Save UI state to persistence
  Future<void> _saveUiState() async {
    try {
      final box = await Hive.openBox('hits_db_ui_state');

      await box.put('isBottomSectionExpanded', state.isBottomSectionExpanded);
      await box.put('columnWidths', state.columnWidths);
    } catch (e) {
      Log.w('Error saving UI state: $e');
    }
  }
}

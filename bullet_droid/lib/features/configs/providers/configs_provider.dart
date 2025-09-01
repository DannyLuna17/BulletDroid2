import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bullet_droid2/bullet_droid.dart';
import 'package:hive/hive.dart';
import 'package:bullet_droid/core/utils/logging.dart';

import 'package:bullet_droid/features/configs/models/config_summary.dart';
import 'package:bullet_droid/shared/providers/hive_provider.dart';
import 'package:bullet_droid/features/configs/services/config_import_service.dart';

// Provider for managing loaded configs
final configsProvider = StateNotifierProvider<ConfigsNotifier, ConfigsState>((
  ref,
) {
  final configMetadataBox = ref.watch(configMetadataBoxProvider);
  final importService = ConfigImportService();
  return ConfigsNotifier(configMetadataBox, importService);
});

// Provider for filtered configs based on search and tags
final filteredConfigsProvider = Provider<List<ConfigSummary>>((ref) {
  final state = ref.watch(configsProvider);
  final configs = state.configs;

  if (state.searchQuery.isEmpty && state.selectedTags.isEmpty) {
    return configs;
  }

  return configs.where((config) {
    // Search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      final matchesSearch =
          config.name.toLowerCase().contains(query) ||
          config.author.toLowerCase().contains(query) ||
          (config.description?.toLowerCase().contains(query) ?? false);

      if (!matchesSearch) return false;
    }

    // Tag filter
    if (state.selectedTags.isNotEmpty) {
      final hasAllTags = state.selectedTags.every(
        (tag) => config.tags.contains(tag),
      );
      if (!hasAllTags) return false;
    }

    return true;
  }).toList();
});

// State class
class ConfigsState {
  final List<ConfigSummary> configs;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final List<String> selectedTags;

  ConfigsState({
    this.configs = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedTags = const [],
  });

  ConfigsState copyWith({
    List<ConfigSummary>? configs,
    bool? isLoading,
    String? error,
    String? searchQuery,
    List<String>? selectedTags,
  }) {
    return ConfigsState(
      configs: configs ?? this.configs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

// Notifier class
class ConfigsNotifier extends StateNotifier<ConfigsState> {
  final Box _configMetadataBox;
  final ConfigImportService _importService;

  ConfigsNotifier(this._configMetadataBox, this._importService)
    : super(ConfigsState()) {
    _loadCachedConfigs();
  }

  Future<void> _loadCachedConfigs() async {
    try {
      final cachedConfigs = <ConfigSummary>[];

      for (final key in _configMetadataBox.keys) {
        final data = _configMetadataBox.get(key);
        if (data != null) {
          try {
            final Map<String, dynamic> jsonMap = _convertToStringMap(data);
            final config = ConfigSummary.fromJson(jsonMap);
            cachedConfigs.add(config);
          } catch (e) {
            // Skip invalid entries and remove them from cache
            Log.w('Error loading config $key: $e');
            await _configMetadataBox.delete(key);
          }
        }
      }

      // Sort by creation time (newest first)
      cachedConfigs.sort(
        (a, b) => (b.lastChecked ?? b.createdAt ?? DateTime(2000)).compareTo(
          a.lastChecked ?? a.createdAt ?? DateTime(2000),
        ),
      );

      state = state.copyWith(configs: cachedConfigs);
      Log.i('Loaded ${cachedConfigs.length} configs from cache');
    } catch (e) {
      // If there's an error loading cached configs, start with empty list
      Log.w('Error loading cached configs: $e');
      state = state.copyWith(configs: []);
    }
  }

  Map<String, dynamic> _convertToStringMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(
        data.map((key, value) {
          return MapEntry(key.toString(), _convertValue(value));
        }),
      );
    } else {
      throw Exception(
        'Invalid data format: Expected Map but got ${data.runtimeType}',
      );
    }
  }

  dynamic _convertValue(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value.map((key, val) {
          return MapEntry(key.toString(), _convertValue(val));
        }),
      );
    } else if (value is List) {
      return value.map((item) => _convertValue(item)).toList();
    } else {
      return value;
    }
  }

  Future<void> loadConfigFromFile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Use service to pick and parse config
      final picked = await _importService.pickConfigAndParse();

      if (picked != null) {
        final config = picked.config;
        final filePath = picked.filePath;

        // Create config summary
        final configId = DateTime.now().millisecondsSinceEpoch.toString();
        final summary = ConfigSummary(
          id: configId,
          name: config.settings.name,
          author: config.settings.author,
          filePath: filePath,
          createdAt: DateTime.now(),
          tags: _extractTags(config),
          description: config.settings.additionalInfo,
          metadata: {...config.settings.toJson(), ...config.metadata.toJson()},
        );

        // Cache metadata
        await _configMetadataBox.put(configId, summary.toJson());

        // Update state
        final updatedConfigs = [...state.configs, summary];
        state = state.copyWith(configs: updatedConfigs, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load config: ${e.toString()}',
      );
    }
  }

  List<String> _extractTags(Config config) {
    final tags = <String>[];

    // Extract tags based on config properties
    if (config.settings.needsProxies) {
      tags.add('Proxies');
    }

    // Check for specific block types by ID
    for (final block in config.blocks) {
      if (block.id.contains('REQUEST') && !tags.contains('HTTP')) {
        tags.add('HTTP');
      }
      if (block.id.contains('PARSE') && !tags.contains('Parser')) {
        tags.add('Parser');
      }
      if (block.id.contains('KEYCHECK') && !tags.contains('KeyCheck')) {
        tags.add('KeyCheck');
      }
    }

    return tags;
  }

  Future<void> deleteConfig(String configId) async {
    try {
      // Remove from cache
      await _configMetadataBox.delete(configId);

      // Update state
      final updatedConfigs = state.configs
          .where((c) => c.id != configId)
          .toList();
      state = state.copyWith(configs: updatedConfigs);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete config: ${e.toString()}');
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleTag(String tag) {
    final selectedTags = List<String>.from(state.selectedTags);
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    state = state.copyWith(selectedTags: selectedTags);
  }

  void clearFilters() {
    state = state.copyWith(searchQuery: '', selectedTags: []);
  }

  Future<void> clearCache() async {
    try {
      await _configMetadataBox.clear();
      state = state.copyWith(configs: []);
      Log.i('Cleared config cache');
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear cache: ${e.toString()}');
    }
  }

  Future<void> reloadConfigs() async {
    await _loadCachedConfigs();
  }
}

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:bullet_droid/features/wordlists/models/wordlist_model.dart';
import 'package:bullet_droid/shared/providers/hive_provider.dart';
import 'package:bullet_droid/shared/utils/wordlist_utils.dart';
import 'package:bullet_droid/core/utils/logging.dart';
import 'package:bullet_droid/features/wordlists/services/wordlist_import_service.dart';

// Provider for managing loaded wordlists
final wordlistsProvider =
    StateNotifierProvider<WordlistsNotifier, WordlistsState>((ref) {
      final wordlistMetadataBox = ref.watch(wordlistMetadataBoxProvider);
      final importService = WordlistImportService();
      return WordlistsNotifier(wordlistMetadataBox, importService);
    });

// Provider for filtered wordlists based on search
final filteredWordlistsProvider = Provider<List<WordlistModel>>((ref) {
  final state = ref.watch(wordlistsProvider);
  final wordlists = state.wordlists;

  if (state.searchQuery.isEmpty) {
    return wordlists;
  }

  return wordlists.where((wordlist) {
    final query = state.searchQuery.toLowerCase();
    return wordlist.name.toLowerCase().contains(query) ||
        wordlist.type.toLowerCase().contains(query);
  }).toList();
});

// State class
class WordlistsState {
  final List<WordlistModel> wordlists;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const WordlistsState({
    this.wordlists = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  WordlistsState copyWith({
    List<WordlistModel>? wordlists,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return WordlistsState(
      wordlists: wordlists ?? this.wordlists,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Notifier class
class WordlistsNotifier extends StateNotifier<WordlistsState> {
  final Box _wordlistMetadataBox;
  final WordlistImportService _importService;

  WordlistsNotifier(this._wordlistMetadataBox, this._importService)
    : super(const WordlistsState()) {
    _loadCachedWordlists();
  }

  Future<void> _loadCachedWordlists() async {
    state = state.copyWith(isLoading: true);

    try {
      final wordlists = <WordlistModel>[];

      for (final key in _wordlistMetadataBox.keys) {
        final data = _wordlistMetadataBox.get(key);
        if (data != null) {
          try {
            // Convert to proper Map<String, dynamic> format
            final Map<String, dynamic> jsonMap = _convertToStringMap(data);
            final wordlist = WordlistModel.fromJson(jsonMap);

            // Recalculate processed line count from file
            WordlistModel finalWordlist = wordlist;
            try {
              final file = File(wordlist.path);
              if (await file.exists()) {
                final processedLines = await WordlistUtils.readAndProcessFile(
                  file,
                );
                if (processedLines.length != wordlist.totalLines) {
                  finalWordlist = wordlist.copyWith(
                    totalLines: processedLines.length,
                  );
                  await _wordlistMetadataBox.put(
                    wordlist.id,
                    finalWordlist.toJson(),
                  );
                }
              }
            } catch (_) {}

            wordlists.add(finalWordlist);
          } catch (e) {
            // Skip invalid entries and remove them from cache
            Log.w('Error loading wordlist $key: $e');
            await _wordlistMetadataBox.delete(key);
          }
        }
      }

      state = state.copyWith(wordlists: wordlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load cached wordlists: ${e.toString()}',
      );
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

  Future<void> loadWordlistFromFile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Use service to pick and process lines
      final picked = await _importService.pickAndRead();

      if (picked != null) {
        final lines = picked.lines;
        final filePath = picked.filePath;
        final fileName = picked.fileName;

        // Create wordlist model
        final wordlistId = DateTime.now().millisecondsSinceEpoch.toString();
        final wordlist = WordlistModel(
          id: wordlistId,
          name: fileName,
          path: filePath,
          type: _detectWordlistType(lines),
          totalLines: lines.length,
          createdAt: DateTime.now(),
          purpose: '',
        );

        // Cache metadata
        await _wordlistMetadataBox.put(wordlistId, wordlist.toJson());

        // Update state
        final updatedWordlists = [...state.wordlists, wordlist];
        state = state.copyWith(wordlists: updatedWordlists, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load wordlist: ${e.toString()}',
      );
    }
  }

  Future<void> addWordlistFromFile({
    required String filePath,
    required String fileName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final lines = await _importService.readFromPath(filePath);

      // Extract name without extension
      String name = fileName;
      if (name.endsWith('.txt')) {
        name = name.substring(0, name.length - 4);
      } else if (name.endsWith('.csv')) {
        name = name.substring(0, name.length - 4);
      }

      // Create wordlist model with default type that can be changed later
      final wordlistId = DateTime.now().millisecondsSinceEpoch.toString();
      final wordlist = WordlistModel(
        id: wordlistId,
        name: name,
        path: filePath,
        type: 'Default',
        totalLines: lines.length,
        createdAt: DateTime.now(),
      );

      // Cache metadata
      await _wordlistMetadataBox.put(wordlistId, wordlist.toJson());

      // Update state
      final updatedWordlists = [...state.wordlists, wordlist];
      state = state.copyWith(wordlists: updatedWordlists, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to add wordlist: ${e.toString()}',
      );
    }
  }

  Future<void> updateWordlistType(String wordlistId, String type) async {
    try {
      final wordlistIndex = state.wordlists.indexWhere(
        (w) => w.id == wordlistId,
      );
      if (wordlistIndex != -1) {
        final updatedWordlist = state.wordlists[wordlistIndex].copyWith(
          type: type,
        );

        // Update cache
        await _wordlistMetadataBox.put(wordlistId, updatedWordlist.toJson());

        // Update state
        final updatedWordlists = List<WordlistModel>.from(state.wordlists);
        updatedWordlists[wordlistIndex] = updatedWordlist;
        state = state.copyWith(wordlists: updatedWordlists);
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to update wordlist type: ${e.toString()}',
      );
    }
  }

  String _detectWordlistType(List<String> lines) {
    if (lines.isEmpty) return 'Unknown';

    final sampleLines = lines.take(10);

    bool hasColon = false;
    bool hasComma = false;

    for (final line in sampleLines) {
      if (line.contains(':')) hasColon = true;
      if (line.contains(',')) hasComma = true;
    }

    if (hasColon) return 'UserPass';
    if (hasComma) return 'CSV';
    return 'Lines';
  }

  Future<void> deleteWordlist(String wordlistId) async {
    try {
      // Remove from cache
      await _wordlistMetadataBox.delete(wordlistId);

      // Update state
      final updatedWordlists = state.wordlists
          .where((w) => w.id != wordlistId)
          .toList();
      state = state.copyWith(wordlists: updatedWordlists);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete wordlist: ${e.toString()}',
      );
    }
  }

  Future<void> deleteAllWordlists() async {
    try {
      // Clear cache
      await _wordlistMetadataBox.clear();

      // Update state
      state = state.copyWith(wordlists: []);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to delete all wordlists: ${e.toString()}',
      );
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> clearCache() async {
    try {
      await _wordlistMetadataBox.clear();
      state = state.copyWith(wordlists: []);
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear cache: ${e.toString()}');
    }
  }

  Future<void> reloadWordlists() async {
    await _loadCachedWordlists();
  }
}

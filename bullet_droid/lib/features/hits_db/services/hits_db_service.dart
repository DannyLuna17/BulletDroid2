import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bullet_droid/features/hits_db/models/hit_record.dart';

class HitsDbService {
  final Box _hitsBox;

  HitsDbService(this._hitsBox);

  /// Add a new hit record to the database
  Future<void> addHit(HitRecord hit) async {
    await _hitsBox.put(hit.id, hit);
  }

  /// Add multiple hit records to the database
  Future<void> addHits(List<HitRecord> hits) async {
    final Map<String, HitRecord> entries = {};
    for (final hit in hits) {
      entries[hit.id] = hit;
    }
    await _hitsBox.putAll(entries);
  }

  /// Get all hit records from the database
  List<HitRecord> getAllHits() {
    return _hitsBox.values.cast<HitRecord>().toList();
  }

  /// Get hit records with pagination
  List<HitRecord> getHits({
    int? limit,
    int? offset,
    String? searchQuery,
    String? configFilter,
    String? typeFilter,
  }) {
    List<HitRecord> hits = getAllHits();

    // Apply filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      hits = hits.where((hit) {
        final searchLower = searchQuery.toLowerCase();

        // Search across all in the table
        final searchableText = [
          hit.data,
          hit.type,
          hit.configName,
          hit.wordlistName,
          hit.proxy ?? '',
          ...hit.capturedData.entries.map((e) => '${e.key}: ${e.value}'),
          ...hit.capturedData.keys,
          ...hit.capturedData.values,
        ].join(' ').toLowerCase();

        return searchableText.contains(searchLower);
      }).toList();
    }

    if (configFilter != null && configFilter != 'All') {
      hits = hits.where((hit) => hit.configName == configFilter).toList();
    }

    if (typeFilter != null && typeFilter != 'All') {
      hits = hits.where((hit) => hit.type == typeFilter).toList();
    }

    // Sort by date (newest first)
    hits.sort((a, b) => b.date.compareTo(a.date));

    // Apply pagination
    if (offset != null && offset > 0) {
      hits = hits.skip(offset).toList();
    }

    if (limit != null && limit > 0) {
      hits = hits.take(limit).toList();
    }

    return hits;
  }

  /// Get total count of hits
  int getHitsCount() {
    return _hitsBox.length;
  }

  /// Get filtered hits count
  int getFilteredHitsCount({
    String? searchQuery,
    String? configFilter,
    String? typeFilter,
  }) {
    return getHits(
      searchQuery: searchQuery,
      configFilter: configFilter,
      typeFilter: typeFilter,
    ).length;
  }

  /// Get unique config names for filter dropdown
  List<String> getUniqueConfigNames() {
    final Set<String> configNames = {};
    for (final hit in getAllHits()) {
      configNames.add(hit.configName);
    }
    return configNames.toList()..sort();
  }

  /// Get unique types for filter dropdown
  List<String> getUniqueTypes() {
    final Set<String> types = {};
    for (final hit in getAllHits()) {
      types.add(hit.type);
    }
    return types.toList()..sort();
  }

  /// Delete a specific hit record
  Future<void> deleteHit(String id) async {
    await _hitsBox.delete(id);
  }

  /// Delete multiple hit records
  Future<void> deleteHits(List<String> ids) async {
    await _hitsBox.deleteAll(ids);
  }

  /// Delete all hit records
  Future<void> deleteAllHits() async {
    await _hitsBox.clear();
  }

  /// Delete filtered hit records
  Future<void> deleteFilteredHits({
    String? searchQuery,
    String? configFilter,
    String? typeFilter,
  }) async {
    final filteredHits = getHits(
      searchQuery: searchQuery,
      configFilter: configFilter,
      typeFilter: typeFilter,
    );

    final idsToDelete = filteredHits.map((hit) => hit.id).toList();
    await deleteHits(idsToDelete);
  }

  /// Delete duplicate hit records
  Future<void> deleteDuplicateHits() async {
    final allHits = getAllHits();
    final seen = <String>{};
    final duplicateIds = <String>[];

    for (final hit in allHits) {
      final key = '${hit.data}|${hit.capturedData.toString()}';
      if (seen.contains(key)) {
        duplicateIds.add(hit.id);
      } else {
        seen.add(key);
      }
    }

    await deleteHits(duplicateIds);
  }

  /// Export hits to TXT file
  Future<bool> exportHitsToTxt({
    required List<HitRecord> hits,
    required String filename,
    bool includeProxy = false,
    bool includeCapturedData = false,
    bool includeConfig = false,
    bool includeDate = false,
    bool includeWordlist = false,
  }) async {
    try {
      // Get the user's Downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null) {
          downloadsDir = Directory('$userProfile\\Downloads');
        }
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !downloadsDir.existsSync()) {
        // Fallback to Documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final file = File(
        '${downloadsDir.path}${Platform.pathSeparator}$filename',
      );

      // Create the content lines
      final lines = hits
          .map(
            (hit) => hit.toFormattedString(
              includeProxy: includeProxy,
              includeCapturedData: includeCapturedData,
              includeConfig: includeConfig,
              includeDate: includeDate,
              includeWordlist: includeWordlist,
            ),
          )
          .toList();

      // Write to file
      await file.writeAsString(lines.join('\n'));

      return true;
    } catch (e) {
      debugPrint('Error exporting hits to TXT: $e');
      return false;
    }
  }

  /// Export hits to TXT file with file picker
  Future<bool> exportHitsToTxtWithPicker({
    required List<HitRecord> hits,
    bool includeProxy = false,
    bool includeCapturedData = false,
    bool includeConfig = false,
    bool includeDate = false,
    bool includeWordlist = false,
  }) async {
    try {
      // Create the content lines
      final lines = hits
          .map(
            (hit) => hit.toFormattedString(
              includeProxy: includeProxy,
              includeCapturedData: includeCapturedData,
              includeConfig: includeConfig,
              includeDate: includeDate,
              includeWordlist: includeWordlist,
            ),
          )
          .toList();

      // Convert content to bytes
      final content = lines.join('\n');
      final bytes = utf8.encode(content);

      // Use file picker to save with bytes
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Hits',
        fileName: 'hits_export.txt',
        type: FileType.custom,
        allowedExtensions: ['txt'],
        bytes: bytes,
      );

      return result != null;
    } catch (e) {
      debugPrint('Error exporting hits to TXT with picker: $e');
      return false;
    }
  }

  /// Get statistics about the hits database
  Map<String, dynamic> getStats() {
    final hits = getAllHits();
    final stats = <String, dynamic>{
      'totalHits': hits.length,
      'configBreakdown': <String, int>{},
      'typeBreakdown': <String, int>{},
      'recentHits': hits.take(10).toList(),
    };

    // Calculate config breakdown
    for (final hit in hits) {
      final config = hit.configName;
      stats['configBreakdown'][config] =
          (stats['configBreakdown'][config] ?? 0) + 1;
    }

    // Calculate type breakdown
    for (final hit in hits) {
      final type = hit.type;
      stats['typeBreakdown'][type] = (stats['typeBreakdown'][type] ?? 0) + 1;
    }

    return stats;
  }
}

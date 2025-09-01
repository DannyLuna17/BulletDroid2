import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:bullet_droid/core/utils/logging.dart';

import 'package:bullet_droid/features/proxies/models/proxy_model.dart';
import 'package:bullet_droid/shared/providers/hive_provider.dart';

/// Keeps a list of proxies cached in the `proxyLists` Hive box, provides
/// helpers for import, de-duplication, bulk updates and status changes.
/// Provider for proxy state management
final proxiesProvider = StateNotifierProvider<ProxiesNotifier, ProxiesState>((
  ref,
) {
  final proxyListsBox = ref.watch(proxyListsBoxProvider);
  return ProxiesNotifier(proxyListsBox);
});

// Provider for selected proxy types filter
final selectedProxyTypesProvider = StateProvider<Set<ProxyType>>((ref) => {});

// State class
class ProxiesState {
  final List<ProxyModel> proxies;
  final bool isLoading;
  final bool isTesting;
  final String? error;

  ProxiesState({
    this.proxies = const [],
    this.isLoading = false,
    this.isTesting = false,
    this.error,
  });

  List<ProxyModel> get aliveProxies =>
      proxies.where((p) => p.status == ProxyStatus.alive).toList();

  List<ProxyModel> get deadProxies =>
      proxies.where((p) => p.status == ProxyStatus.dead).toList();

  List<ProxyModel> get untestedProxies =>
      proxies.where((p) => p.status == ProxyStatus.untested).toList();

  // Apply a types filter if provided
  List<ProxyModel> filteredByTypes(Set<ProxyType> types) {
    if (types.isEmpty) return proxies;
    return proxies.where((p) => types.contains(p.type)).toList();
  }

  ProxiesState copyWith({
    List<ProxyModel>? proxies,
    bool? isLoading,
    bool? isTesting,
    String? error,
  }) {
    return ProxiesState(
      proxies: proxies ?? this.proxies,
      isLoading: isLoading ?? this.isLoading,
      isTesting: isTesting ?? this.isTesting,
      error: error,
    );
  }
}

// Notifier class
class ProxiesNotifier extends StateNotifier<ProxiesState> {
  final Box _proxyListsBox;

  ProxiesNotifier(this._proxyListsBox) : super(ProxiesState()) {
    _loadCachedProxies();
  }

  // Recursively convert Map<dynamic, dynamic> to Map<String, dynamic>
  static Map<String, dynamic>? _convertDynamicMap(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final Map<String, dynamic> converted = {};
      for (final entry in data.entries) {
        final key = entry.key.toString();
        final value = entry.value;

        if (value is Map) {
          converted[key] = _convertDynamicMap(value);
        } else if (value is List) {
          converted[key] = value.map((item) {
            if (item is Map) {
              return _convertDynamicMap(item);
            }
            return item;
          }).toList();
        } else {
          converted[key] = value;
        }
      }
      return converted;
    }

    return null;
  }

  // Clear corrupted cache data
  void _clearCorruptedCache() {
    try {
      _proxyListsBox.delete('proxies');
      Log.i('Cleared corrupted proxy cache');
    } catch (e) {
      Log.w('Error clearing corrupted cache: $e');
    }
  }

  void _loadCachedProxies() {
    try {
      Log.i('Loading cached proxies...');
      final cachedProxies = _proxyListsBox.get('proxies', defaultValue: []);

      if (cachedProxies is List) {
        final proxies = <ProxyModel>[];

        for (final item in cachedProxies) {
          try {
            if (item is Map) {
              // Use recursive conversion to handle nested Maps
              final convertedMap = _convertDynamicMap(item);
              if (convertedMap != null) {
                final proxy = ProxyModel.fromJson(convertedMap);
                proxies.add(proxy);
              }
            }
          } catch (conversionError) {
            Log.w('Error converting individual proxy: $conversionError');
          }
        }

        state = state.copyWith(proxies: proxies);
        Log.i('Successfully loaded ${proxies.length} cached proxies');
      } else {
        Log.i('No cached proxies found or invalid format');
        state = state.copyWith(proxies: []);
      }
    } catch (e) {
      Log.w('Error loading cached proxies: $e');
      _clearCorruptedCache();
      state = state.copyWith(proxies: []);
    }
  }

  Future<void> _saveProxies() async {
    try {
      await _proxyListsBox.put(
        'proxies',
        state.proxies.map((p) => p.toJson()).toList(),
      );
    } catch (e) {
      Log.w('Error saving proxies to cache: $e');
    }
  }

  void addProxy(ProxyModel proxy) {
    final updatedProxies = [...state.proxies, proxy];
    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  // Efficient bulk add with de-duplication and single persistence write
  void addProxies(List<ProxyModel> proxiesToAdd) {
    if (proxiesToAdd.isEmpty) return;

    final existingProxies = state.proxies;
    final seenKeys = <String>{
      for (final p in existingProxies) '${p.address}:${p.port}',
    };

    final deduplicatedToAdd = <ProxyModel>[];
    for (final proxy in proxiesToAdd) {
      final key = '${proxy.address}:${proxy.port}';
      if (!seenKeys.contains(key)) {
        seenKeys.add(key);
        deduplicatedToAdd.add(proxy);
      }
    }

    if (deduplicatedToAdd.isEmpty) return;

    final updatedProxies = [...existingProxies, ...deduplicatedToAdd];
    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  void deleteProxy(String proxyId) {
    final updatedProxies = state.proxies.where((p) => p.id != proxyId).toList();
    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  void updateProxyStatus(String proxyId, ProxyStatus status) {
    final updatedProxies = state.proxies.map((p) {
      if (p.id == proxyId) {
        return ProxyModel(
          id: p.id,
          address: p.address,
          port: p.port,
          type: p.type,
          status: status,
          username: p.username,
          password: p.password,
          lastChecked: DateTime.now(),
          lastUsed: p.lastUsed,
          successCount: p.successCount,
          failureCount: p.failureCount,
          responseTime: p.responseTime,
          country: p.country,
          metadata: p.metadata,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  Future<void> importFromFile(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final file = File(filePath);
      final lines = await file.readAsLines();
      final newProxies = <ProxyModel>[];

      for (final line in lines) {
        if (line.trim().isNotEmpty) {
          final proxy = line.parseProxy();
          if (proxy != null) {
            newProxies.add(proxy);
          }
        }
      }

      // Use bulk add to avoid repeated writes and ensure de-duplication
      addProxies(newProxies);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to import proxies: ${e.toString()}',
      );
    }
  }

  void clearAll() {
    state = state.copyWith(proxies: []);
    _saveProxies();
  }

  void deleteNotWorking() {
    final updatedProxies = state.proxies
        .where((p) => p.status != ProxyStatus.dead)
        .toList();
    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  void deleteDuplicates() {
    final seen = <String>{};
    final updatedProxies = <ProxyModel>[];

    for (final proxy in state.proxies) {
      final key = '${proxy.address}:${proxy.port}';
      if (!seen.contains(key)) {
        seen.add(key);
        updatedProxies.add(proxy);
      }
    }

    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  void deleteUntested() {
    final updatedProxies = state.proxies
        .where((p) => p.status != ProxyStatus.untested)
        .toList();
    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  void updateProxy(ProxyModel updatedProxy) {
    final updatedProxies = state.proxies.map((p) {
      if (p.id == updatedProxy.id) {
        return updatedProxy;
      }
      return p;
    }).toList();

    state = state.copyWith(proxies: updatedProxies);
    _saveProxies();
  }

  // Apply a batch of proxy updates in a single state change to minimize rebuilds.
  void updateProxiesBatch(
    List<ProxyModel> updatedProxiesList, {
    bool persist = false,
  }) {
    if (updatedProxiesList.isEmpty) return;

    final idToUpdated = {for (final p in updatedProxiesList) p.id: p};
    final updatedProxies = state.proxies
        .map((p) => idToUpdated[p.id] ?? p)
        .toList();
    state = state.copyWith(proxies: updatedProxies);

    if (persist) {
      _saveProxies();
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:bullet_droid/features/wordlists/models/custom_wordlist_type.dart';

final customWordlistTypesProvider =
    StateNotifierProvider<
      CustomWordlistTypesNotifier,
      CustomWordlistTypesState
    >((ref) {
      final box = Hive.box('customWordlistTypes');
      return CustomWordlistTypesNotifier(box);
    });

class CustomWordlistTypesState {
  final List<CustomWordlistType> types;
  final bool isLoading;
  final String? error;

  const CustomWordlistTypesState({
    this.types = const [],
    this.isLoading = false,
    this.error,
  });

  CustomWordlistTypesState copyWith({
    List<CustomWordlistType>? types,
    bool? isLoading,
    String? error,
  }) {
    return CustomWordlistTypesState(
      types: types ?? this.types,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomWordlistTypesNotifier
    extends StateNotifier<CustomWordlistTypesState> {
  final Box _box;

  CustomWordlistTypesNotifier(this._box)
    : super(const CustomWordlistTypesState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final types = <CustomWordlistType>[];
      for (final key in _box.keys) {
        final data = _box.get(key);
        if (data is Map) {
          try {
            types.add(
              CustomWordlistType.fromJson(
                Map<String, dynamic>.from(
                  data.map((k, v) => MapEntry(k.toString(), v)),
                ),
              ),
            );
          } catch (_) {}
        }
      }
      state = state.copyWith(types: types, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load custom wordlist types: $e',
      );
    }
  }

  Future<void> addType({
    required String name,
    required String regex,
    required String separator,
    required List<String> slices,
  }) async {
    final trimmedName = name.trim();
    final trimmedRegex = regex.trim();
    final trimmedSeparator = separator.trim();
    final cleanedSlices = slices
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (trimmedName.isEmpty || trimmedRegex.isEmpty || cleanedSlices.isEmpty) {
      throw Exception('Invalid custom wordlist type data');
    }

    if (_nameExists(trimmedName)) {
      throw Exception('A custom type with this name already exists');
    }

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final type = CustomWordlistType(
      id: id,
      name: trimmedName,
      regex: trimmedRegex,
      separator: trimmedSeparator,
      slices: cleanedSlices,
    );

    await _box.put(id, type.toJson());
    state = state.copyWith(types: [...state.types, type]);
  }

  Future<String> addPlaceholder() async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final placeholder = CustomWordlistType(
      id: id,
      name: '',
      regex: '',
      separator: '',
      slices: [],
      isPlaceholder: true,
    );

    await _box.put(id, placeholder.toJson());
    state = state.copyWith(types: [...state.types, placeholder]);
    return id;
  }

  Future<void> updateType(CustomWordlistType type) async {
    final trimmedName = type.name.trim();
    final trimmedRegex = type.regex.trim();
    final cleanedSlices = type.slices
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (trimmedName.isEmpty || trimmedRegex.isEmpty || cleanedSlices.isEmpty) {
      throw Exception('Name, regex, and at least one slice are required');
    }

    // Check name uniqueness (excluding self)
    if (state.types.any((t) => t.id != type.id && t.name == trimmedName)) {
      throw Exception('A custom type with this name already exists');
    }

    // Validate Regex
    try {
      RegExp(trimmedRegex);
    } catch (e) {
      throw Exception('Invalid regex');
    }

    final updatedType = type.copyWith(
      name: trimmedName,
      regex: trimmedRegex,
      separator: type.separator.trim(),
      slices: cleanedSlices,
      isPlaceholder: false, // No longer a placeholder
    );

    await _box.put(updatedType.id, updatedType.toJson());

    state = state.copyWith(
      types: state.types
          .map((t) => t.id == updatedType.id ? updatedType : t)
          .toList(),
    );
  }

  Future<void> deleteType(String id) async {
    await _box.delete(id);
    state = state.copyWith(
      types: state.types.where((t) => t.id != id).toList(),
    );
  }

  CustomWordlistType? getByName(String name) {
    final target = name.trim();
    for (final t in state.types) {
      if (t.name == target) return t;
    }
    return null;
  }

  bool _nameExists(String name) {
    final target = name.trim();
    return state.types.any((t) => t.name == target);
  }
}

class CustomWordlistType {
  final String id;
  final String name;
  final String regex;
  final String separator;
  final List<String> slices;
  final bool isPlaceholder;

  const CustomWordlistType({
    required this.id,
    required this.name,
    required this.regex,
    required this.separator,
    required this.slices,
    this.isPlaceholder = false,
  });

  factory CustomWordlistType.fromJson(Map<String, dynamic> json) {
    return CustomWordlistType(
      id: json['id'] as String,
      name: (json['name'] as String? ?? '').trim(),
      regex: (json['regex'] as String? ?? '').trim(),
      separator: (json['separator'] as String? ?? '').trim(),
      slices: List<String>.from(
        json['slices'] ?? [],
      ).map((s) => s.trim()).toList(),
      isPlaceholder: json['isPlaceholder'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.trim(),
      'regex': regex.trim(),
      'separator': separator.trim(),
      'slices': slices.map((s) => s.trim()).toList(),
      'isPlaceholder': isPlaceholder,
    };
  }

  CustomWordlistType copyWith({
    String? id,
    String? name,
    String? regex,
    String? separator,
    List<String>? slices,
    bool? isPlaceholder,
  }) {
    return CustomWordlistType(
      id: id ?? this.id,
      name: name ?? this.name,
      regex: regex ?? this.regex,
      separator: separator ?? this.separator,
      slices: slices ?? this.slices,
      isPlaceholder: isPlaceholder ?? this.isPlaceholder,
    );
  }
}

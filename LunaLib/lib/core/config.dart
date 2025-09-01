import '../blocks/base/block_instance.dart';
import 'config_settings.dart';

class Config {
  ConfigMetadata metadata;
  List<BlockInstance> blocks;
  ConfigSettings settings;

  Config({
    required this.metadata,
    List<BlockInstance>? blocks,
    ConfigSettings? settings,
  })  : blocks = blocks ?? [],
        settings = settings ?? ConfigSettings();

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'settings': settings.toJson(),
    };
  }
}

class ConfigMetadata {
  String name;
  String author;
  String category;
  String description;
  String version;

  ConfigMetadata({
    required this.name,
    this.author = '',
    this.category = 'Default',
    this.description = '',
    this.version = '1.0.0',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'category': category,
      'description': description,
      'version': version,
    };
  }

  void fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? '';
    author = json['author'] ?? '';
    category = json['category'] ?? 'Default';
    description = json['description'] ?? '';
    version = json['version'] ?? '1.0.0';
  }
}

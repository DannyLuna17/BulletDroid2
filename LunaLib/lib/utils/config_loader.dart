import '../core/config.dart';
import '../core/config_settings.dart';
import '../parsing/loli_parser.dart';
import '../core/app_configuration.dart';
import '../services/file_system_service.dart';

/// Result of loading a config file with metadata
class ConfigLoadResult {
  final Config config;
  final String filePath;
  final DateTime loadedAt;
  final int fileSizeBytes;
  final bool hasErrors;
  final List<String> errors;

  ConfigLoadResult({
    required this.config,
    required this.filePath,
    required this.loadedAt,
    required this.fileSizeBytes,
    this.hasErrors = false,
    this.errors = const [],
  });
}

/// Utility class for loading .loli configuration files
class ConfigLoader {
  /// Load a single .loli file from the given path
  static Future<Config> loadFromFile(String filePath) async {
    // Validate file extension
    // Disable file extension validation for now, testing .svb files
    // if (!filePath.toLowerCase().endsWith('.loli')) {
    //   throw FormatException(
    //       'Invalid file extension. Expected .loli file: $filePath');
    // }

    // Check if file exists
    if (!await fileSystemService.exists(filePath)) {
      throw Exception('File not found: $filePath');
    }

    try {
      // Read file content
      final content = await fileSystemService.readFile(filePath);

      // Parse config using existing parser
      return LoliParser.parseConfig(content);
    } catch (e) {
      if (e.toString().contains('Permission denied')) {
        throw Exception('Permission denied: Cannot read file $filePath');
      } else if (e is FormatException) {
        throw FormatException('Failed to parse config: ${e.message}');
      } else {
        throw Exception('Failed to load config file: $e');
      }
    }
  }

  /// Load multiple .loli files from a directory
  static Future<List<Config>> loadFromDirectory(String directoryPath,
      {bool recursive = false}) async {
    final configs = <Config>[];

    try {
      final files = await fileSystemService.listDirectory(directoryPath,
          extension: '.loli');

      for (final filePath in files) {
        try {
          final config = await loadFromFile(filePath);
          configs.add(config);
        } catch (e) {
          // ignore: avoid_print
          if (AppConfiguration.debugMode) print('Error loading $filePath: $e');
        }
      }
    } catch (e) {
      throw Exception(
          'Directory not found or cannot be accessed: $directoryPath');
    }

    return configs;
  }

  /// Check if a file is a valid .loli file
  static Future<bool> isValidLoliFile(String filePath) async {
    try {
      await loadFromFile(filePath);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Load config with metadata about the file
  static Future<ConfigLoadResult> loadWithMetadata(String filePath) async {
    final errors = <String>[];
    Config? config;
    bool hasErrors = false;

    try {
      config = await loadFromFile(filePath);
    } catch (e) {
      hasErrors = true;
      errors.add(e.toString());
      config = Config(
        metadata: ConfigMetadata(name: 'Failed to load'),
        blocks: [],
        settings: ConfigSettings(),
      );
    }

    int fileSize = 0;
    try {
      fileSize = await fileSystemService.getFileSize(filePath);
    } catch (e) {
      // ignore: avoid_print
      if (AppConfiguration.debugMode) print('Error getting file size: $e');
    }

    return ConfigLoadResult(
      config: config,
      filePath: filePath,
      loadedAt: DateTime.now(),
      fileSizeBytes: fileSize,
      hasErrors: hasErrors,
      errors: errors,
    );
  }
}

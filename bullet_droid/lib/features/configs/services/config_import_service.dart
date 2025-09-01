import 'package:file_picker/file_picker.dart';
import 'package:bullet_droid2/bullet_droid.dart';

/// Service that encapsulates config file picking and parsing.
class ConfigImportService {
  /// Open a file picker and parse the selected config.
  /// Returns null if the user cancels.
  Future<({Config config, String filePath})?> pickConfigAndParse() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.first.path!;
    final config = await ConfigLoader.loadFromFile(path);
    return (config: config, filePath: path);
  }

  /// Parse a config at a known path.
  Future<Config> parseFromFile(String filePath) async {
    return ConfigLoader.loadFromFile(filePath);
  }
}

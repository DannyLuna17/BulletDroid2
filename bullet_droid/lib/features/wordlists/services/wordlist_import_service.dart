import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:bullet_droid/shared/utils/wordlist_utils.dart';

/// Service for file picking and preprocessing for wordlists.
class WordlistImportService {
  
  /// Let the user pick a .txt and return the processed lines and path.
  /// Returns null if the user cancels.
  Future<({List<String> lines, String filePath, String fileName})?>
  pickAndRead() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['txt'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final path = result.files.first.path!;
    final name = result.files.first.name;
    final lines = await WordlistUtils.readAndProcessFile(File(path));
    return (lines: lines, filePath: path, fileName: name);
  }

  /// Read and process a known file path.
  Future<List<String>> readFromPath(String filePath) async {
    return WordlistUtils.readAndProcessFile(File(filePath));
  }
}

import 'dart:io';

class WordlistUtils {
  /// Process raw wordlist content into normalized data lines used by runners.
  static List<String> processContent(String content) {
    return content
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Read a file and return processed data lines using [processContent].
  static Future<List<String>> readAndProcessFile(File file) async {
    final content = await file.readAsString();
    return processContent(content);
  }
}

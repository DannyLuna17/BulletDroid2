import 'dart:io' as io;
import 'dart:typed_data';

/// Abstract interface for file system operations
/// Allows for platform-specific implementations
abstract class FileSystemService {
  /// Read a text file and return its contents
  Future<String> readFile(String path);

  /// Read a file as bytes
  Future<Uint8List> readFileBytes(String path);

  /// Write text to a file
  Future<void> writeFile(String path, String content);

  /// Write bytes to a file
  Future<void> writeFileBytes(String path, Uint8List bytes);

  /// Check if a file exists
  Future<bool> exists(String path);

  /// Delete a file
  Future<void> deleteFile(String path);

  /// List files in a directory
  Future<List<String>> listDirectory(String path, {String? extension});

  /// Get file size in bytes
  Future<int> getFileSize(String path);
}

/// Default implementation using dart:io
/// For use in Dart console applications and Flutter mobile
class DefaultFileSystemService implements FileSystemService {
  @override
  Future<String> readFile(String path) async {
    final file = io.File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    return await file.readAsString();
  }

  @override
  Future<Uint8List> readFileBytes(String path) async {
    final file = io.File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    return await file.readAsBytes();
  }

  @override
  Future<void> writeFile(String path, String content) async {
    final file = io.File(path);
    await file.writeAsString(content);
  }

  @override
  Future<void> writeFileBytes(String path, Uint8List bytes) async {
    final file = io.File(path);
    await file.writeAsBytes(bytes);
  }

  @override
  Future<bool> exists(String path) async {
    final file = io.File(path);
    return await file.exists();
  }

  @override
  Future<void> deleteFile(String path) async {
    final file = io.File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<List<String>> listDirectory(String path, {String? extension}) async {
    final dir = io.Directory(path);
    if (!await dir.exists()) {
      return [];
    }

    final entities = await dir.list().toList();
    final files = <String>[];

    for (var entity in entities) {
      if (entity is io.File) {
        final filePath = entity.path;
        if (extension == null || filePath.endsWith(extension)) {
          files.add(filePath);
        }
      }
    }

    return files;
  }

  @override
  Future<int> getFileSize(String path) async {
    final file = io.File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }
    return await file.length();
  }
}

/// Global instance of FileSystemService, could be replaced with platform-specific implementations
FileSystemService fileSystemService = DefaultFileSystemService();

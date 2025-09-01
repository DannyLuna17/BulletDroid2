/// Represents a multipart content item for HTTP requests
enum MultipartContentType { String, File }

/// Multipart content for REQUEST blocks
class MultipartContent {
  final MultipartContentType type;
  final String name;
  final String value;
  final String contentType;

  MultipartContent({
    required this.type,
    required this.name,
    required this.value,
    this.contentType = '',
  });

  @override
  String toString() {
    if (type == MultipartContentType.String) {
      return 'MultipartContent.String(name: $name, value: $value)';
    } else {
      return 'MultipartContent.File(name: $name, path: $value, contentType: $contentType)';
    }
  }
}

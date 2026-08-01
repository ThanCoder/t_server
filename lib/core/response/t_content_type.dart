import 'dart:io';

enum TContentType {
  jpg('.jpg', 'image/jpeg'),
  png('.png', 'image/png'),
  mp4('.mp4', 'video/mp4'),
  pdf('.pdf', 'application/pdf'),
  json('.json', 'application/json'),
  text('.txt', 'text/plain');

  const TContentType(this.extension, this.mimeType);

  final String extension;
  final String mimeType;

  ContentType get contentType {
    final parts = mimeType.split('/');
    return ContentType(parts[0], parts[1]);
  }

  static TContentType? fromExtension(String extension) {
    final value = extension.toLowerCase();

    for (final type in values) {
      if (type.extension == value) {
        return type;
      }
    }

    return null;
  }
}

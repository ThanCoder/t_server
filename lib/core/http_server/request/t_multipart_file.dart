import 'dart:io';

class TMultipartFile {
  final String name;
  final String filename;
  final String? contentType;
  final List<int> bytes;

  const TMultipartFile({
    required this.name,
    required this.filename,
    required this.contentType,
    required this.bytes,
  });

  int get length => bytes.length;

  Future<File> saveAs(File destination) async {
    await destination.writeAsBytes(bytes);
    return destination;
  }
}

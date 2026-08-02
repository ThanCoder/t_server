import 'package:t_server/core/http_server/request/t_multipart_file.dart';

class TMultipartForm {
  final Map<String, String> fields = {};

  final List<TMultipartFile> files = [];

  TMultipartFile? file(String name) {
    for (final file in files) {
      if (file.name == name) {
        return file;
      }
    }

    return null;
  }

  @override
  String toString() {
    return 'fields: $fields';
  }
}

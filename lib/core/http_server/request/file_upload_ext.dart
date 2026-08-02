import 'dart:convert';
import 'dart:io';

import 'package:t_server/core/http_server/request/request_helper_fun.dart';
import 'package:t_server/core/http_server/request/t_request.dart';

extension FileUploadExt on TRequest {
  Future<void> uploadFile(File destination) async {
    final contentType = raw.headers.contentType;

    final boundary = contentType?.parameters['boundary'];

    if (boundary == null) {
      throw FormatException('Request is not multipart/form-data');
    }

    final delimiter = '--$boundary';

    print('delimiter: $delimiter');

    final chunks = <List<int>>[];

    await for (final chunk in raw) {
      chunks.add(chunk);
    }

    final bytes = chunks.expand((e) => e).toList();

    print('total bytes: ${bytes.length}');

    final separator = utf8.encode('\r\n\r\n');

    final headerEnd = indexOfBytes(bytes, separator);

    final headerBytes = bytes.sublist(0, headerEnd);

    final headerText = utf8.decode(headerBytes, allowMalformed: true);

    final filename = getFilename(headerText);
    final fieldName = getFieldName(headerText);

    print('FILE');
    print('name: $fieldName');
    print('filename: $filename');
  }
}


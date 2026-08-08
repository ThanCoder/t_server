import 'package:t_server/core/http_server/request/multipart_parser.dart';
import 'package:t_server/core/http_server/request/t_multipart_form.dart';
import 'package:t_server/core/http_server/request/t_request.dart';

extension MultipartFormExt on TRequest {
  Future<TMultipartForm> multipart() async {
    final contentType = raw.headers.contentType;

    if (contentType == null || contentType.mimeType != 'multipart/form-data') {
      throw FormatException('Request body is not multipart/form-data');
    }

    final boundary = contentType.parameters['boundary'];

    if (boundary == null || boundary.isEmpty) {
      throw FormatException('Multipart boundary not found');
    }

    final parser = TMultipartParser(raw, boundary);

    await parser.parse();

    final form = TMultipartForm();

    return form;
  }
}

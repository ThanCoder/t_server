import 'dart:convert';
import 'dart:io';

import 'package:t_server/core/http_server/response/t_response.dart';

class TRequest {
  final HttpRequest raw;
  TRequest(this.raw);

  late final TResponse response = TResponse(this, raw.response);

  Uri get uri => raw.uri;
  HttpHeaders get header => raw.headers;
  String get method => raw.method;
  String get path => raw.uri.path;
  int get contentLength => raw.contentLength;

  Map<String, String> get query => raw.uri.queryParameters;

  String? _body;

  /// Text Body
  Future<String> get bodyText async {
    if (_body != null) {
      return _body!;
    }
    _body = await utf8.decodeStream(raw);
    return _body!;
  }

  /// json Body
  Future<dynamic> get bodyJson async {
    final contentType = raw.headers.contentType;

    if (contentType?.mimeType != 'application/json') {
      throw FormatException('Request body is not application/json');
    }

    final text = await bodyText;
    if (text.isEmpty) return null;
    return jsonDecode(text);
  }
}

String? getContentType(String headerText) {
  for (final line in headerText.split('\r\n')) {
    if (!line.toLowerCase().startsWith('content-type:')) {
      continue;
    }

    return line.substring('Content-Type:'.length).trim();
  }

  return null;
}


import 'dart:io';

import 'package:t_server/core/response/t_response.dart';

class TRequest {
  final HttpRequest raw;
  const TRequest(this.raw);

  Uri get uri => raw.uri;

  HttpHeaders get header => raw.headers;
  String get method => raw.method;
  String get path => raw.uri.path;

  TResponse get response => TResponse(raw.response);
}

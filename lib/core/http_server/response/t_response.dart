import 'dart:convert';
import 'dart:io';

import 'package:t_server/core/http_server/request/t_request.dart';
import 'package:t_server/t_server.dart';

part 'handlers/download_handler.dart';
part 'handlers/stream_handler.dart';

abstract class ITResponse {
  HttpResponse get _raw;
  TRequest get _request;

  Future<void> send(
    dynamic body, {
    required ContentType contentType,
    int statusCode = HttpStatus.ok,
  });
}

class TResponse extends ITResponse with DownloadHandler, StreamHandler {
  @override
  final HttpResponse _raw;
  @override
  final TRequest _request;
  TResponse(this._request, this._raw);

  bool _closed = false;
  bool get isClosed => _closed;

  /// ### Send Text
  /// await ctx.request.response.text('text');
  Future<void> text(String value, {int statusCode = HttpStatus.ok}) {
    return send(value, contentType: ContentType.text, statusCode: statusCode);
  }

  /// ### Send Html
  /// `await ctx.request.response.html('<h1>hello user</h1>');`
  Future<void> html(String value, {int statusCode = HttpStatus.ok}) {
    return send(value, contentType: ContentType.html, statusCode: statusCode);
  }

  /// ### Send json
  /// `await ctx.request.response.json({'name': 'thanCoder'});`
  ///
  Future<void> json(Object value, {int statusCode = HttpStatus.ok}) {
    return send(
      jsonEncode(value),
      contentType: ContentType.json,
      statusCode: statusCode,
    );
  }

  /// ### Send json String
  /// `await ctx.request.response.jsonString([jsonEncode(jsonString)]);`
  ///
  Future<void> jsonString(String jsonString, {int statusCode = HttpStatus.ok}) {
    return send(
      jsonString,
      contentType: ContentType.json,
      statusCode: statusCode,
    );
  }

  @override
  Future<void> send(
    dynamic body, {
    required ContentType contentType,
    int statusCode = HttpStatus.ok,
  }) async {
    if (_closed) return;

    _raw
      ..statusCode = statusCode
      ..headers.contentType = contentType
      ..write(body);

    await _raw.close();

    _closed = true;
  }

  //****************File******************* */
}

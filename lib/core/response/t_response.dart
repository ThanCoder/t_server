import 'dart:convert';
import 'dart:io';

import 'package:t_server/core/request/t_request.dart';
import 'package:t_server/t_server.dart';

class TResponse {
  final HttpResponse _raw;
  final TRequest _request;
  TResponse(this._request, this._raw);

  bool _closed = false;
  bool get isClosed => _closed;

  /// ### Send Text
  /// HttpStatus.ok
  Future<void> text(String value, {int statusCode = HttpStatus.ok}) {
    return _send(value, contentType: ContentType.text, statusCode: statusCode);
  }

  /// ### Send Html
  /// `await ctx.request.response.json('<h1>hello user</h1>');`
  Future<void> html(String value, {int statusCode = HttpStatus.ok}) {
    return _send(value, contentType: ContentType.html, statusCode: statusCode);
  }

  /// ### Send json
  /// `await ctx.request.response.json({'name': 'thanCoder'});`
  ///
  Future<void> json(Object value, {int statusCode = HttpStatus.ok}) {
    return _send(
      jsonEncode(value),
      contentType: ContentType.json,
      statusCode: statusCode,
    );
  }

  Future<void> _send(
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
  Future<void> file(File file, {required TContentType contentType}) async {
    if (!await file.exists()) {
      await text('File Not Found', statusCode: HttpStatus.notFound);
      return;
    }
    final size = await file.length();

    final range = _request.header.value(HttpHeaders.rangeHeader);
    print('range: $range');
    // partial 206
    if (range != null) {
      final val = range.split('=').last;
      final parts = val.split('-');
      final start = int.tryParse(parts[0]) ?? 0;
      final httpEnd = int.tryParse(parts[1]);
      final end = httpEnd == null ? size : httpEnd + 1;
      final length = end - start;

      print('start: $start');
      print('end: $end');

      _raw
        ..statusCode = HttpStatus.partialContent
        ..headers.contentLength = length
        ..headers.contentType = contentType.contentType
        ..headers.set(HttpHeaders.acceptRangesHeader, 'bytes')
        ..headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-${end - 1}/$size',
        );

      await file.openRead(start, end).pipe(_raw);
      return;
    }

    // send full file
    _raw
      ..statusCode = HttpStatus.ok
      ..headers.contentType = contentType.contentType
      ..headers.contentLength = size;

    await file.openRead().pipe(_raw);
  }
}

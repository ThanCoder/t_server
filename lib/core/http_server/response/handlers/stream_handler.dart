part of '../t_response.dart';

mixin StreamHandler on ITResponse {
  //****************Video Stream******************* */
  /// Supported Parial Stream `206`
  Future<void> videoStream(
    File file, {
    required TContentType contentType,
  }) async {
    if (!await file.exists()) {
      await send(
        'File Not Found!',
        contentType: .text,
        statusCode: HttpStatus.notFound,
      );
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

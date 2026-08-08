part of '../t_response.dart';

mixin DownloadHandler on ITResponse {
  /// Supported Parial Stream `206`
  ///
  /// Pause,Resume
  Future<void> download(File file) async {
    if (!await file.exists()) {
      await send(
        'File Not Found!',
        contentType: .text,
        statusCode: HttpStatus.notFound,
      );
      // await text('File Not Found', statusCode: HttpStatus.notFound);
      return;
    }

    final size = await file.length();

    final name = file.path.split('/').last;
    final encodedName = Uri.encodeComponent(name);

    // Common headers
    _raw.headers
      ..set(
        HttpHeaders.contentDisposition,
        "attachment; filename*=UTF-8''$encodedName",
      )
      ..set(HttpHeaders.acceptRangesHeader, 'bytes');

    final range = _request.header.value(HttpHeaders.rangeHeader);

    // =========================
    // Full download - 200
    // =========================
    if (range == null) {
      _raw
        ..statusCode = HttpStatus.ok
        ..headers.contentLength = size;

      await file.openRead().pipe(_raw);
      return;
    }

    // =========================
    // Parse Range
    // =========================

    final value = range.split('=').last;
    final parts = value.split('-');

    var start = int.tryParse(parts[0]) ?? 0;
    final httpEnd = int.tryParse(parts[1]);

    // start is outside file
    if (start >= size) {
      _raw
        ..statusCode = HttpStatus.requestedRangeNotSatisfiable
        ..headers.set(HttpHeaders.contentRangeHeader, 'bytes */$size');

      await _raw.close();
      return;
    }

    // HTTP end is inclusive
    var finalHttpEnd = httpEnd ?? (size - 1);

    // Don't allow end beyond file
    if (finalHttpEnd >= size) {
      finalHttpEnd = size - 1;
    }

    // Dart openRead end is exclusive
    final readEnd = finalHttpEnd + 1;

    // Invalid range
    if (readEnd <= start) {
      _raw
        ..statusCode = HttpStatus.requestedRangeNotSatisfiable
        ..headers.set(HttpHeaders.contentRangeHeader, 'bytes */$size');

      await _raw.close();
      return;
    }

    final length = readEnd - start;

    // =========================
    // Partial download - 206
    // =========================

    _raw
      ..statusCode = HttpStatus.partialContent
      ..headers.contentLength = length
      ..headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$finalHttpEnd/$size',
      );

    await file.openRead(start, readEnd).pipe(_raw);
  }
}

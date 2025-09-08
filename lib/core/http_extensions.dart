import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';
import 'package:t_server/core/t_logger.dart';

import 't_encoder.dart';

extension HttpExtensions on HttpRequest {
  ///
  /// send text String
  ///
  void sendText(String text) {
    response
      ..headers.contentType = ContentType.text
      ..write(text)
      ..close();
  }

  ///
  /// send html String
  ///
  void sendHtml(String html) {
    response
      ..headers.contentType = ContentType.html
      ..write(html)
      ..close();
  }

  ///
  /// send json encoded String
  ///
  void sendJson(String jsonStr) {
    response
      ..headers.contentType = ContentType.json
      ..write(jsonStr)
      ..close();
  }

  ///
  /// `/?path=[path]` query parameters
  ///
  Map<String, dynamic> get getQueryParameters {
    return uri.queryParameters;
  }

  // Map<String, dynamic> getParams() {
  //   // final path = uri.queryParameters;
  //   return {};
  // }

  ///
  /// get request body -> map
  ///
  Future<String> getBody() async {
    final content = await utf8.decoder.bind(this).join();
    return content;
  }

  ///
  /// send file
  /// partial download 206
  ///
  Future<void> sendFile(String filePath) async {
    try {
      final file = File(filePath);
      final name = file.path.split('/').last;
      final fileLength = file.lengthSync();

      if (file.existsSync()) {
        final rangeHeader = headers.value(HttpHeaders.rangeHeader);
        if (rangeHeader != null) {
          // partial download 206 အတွက်
          // Example: Range: bytes=1000-
          final match = RegExp(r"bytes=(\d+)-(\d*)").firstMatch(rangeHeader);
          final start = int.parse(match!.group(1)!);
          final end = match.group(2)!.isNotEmpty
              ? int.parse(match.group(2)!)
              : fileLength - 1;

          final chunkSize = end - start + 1;

          response
            ..statusCode = HttpStatus.partialContent
            ..headers.add(
              HttpHeaders.contentTypeHeader,
              "application/octet-stream",
            )
            ..headers.add(HttpHeaders.acceptRangesHeader, "bytes")
            ..headers.add(
              HttpHeaders.contentRangeHeader,
              "bytes $start-$end/$fileLength",
            )
            ..headers.add(HttpHeaders.contentLengthHeader, chunkSize)
            ..headers.set(
              'Content-Disposition',
              'attachment; filename="${TEncoder.encodeRFC5987(name)}"',
            );

          final raf = file.openSync();
          raf.setPositionSync(start);
          response.add(raf.readSync(chunkSize));
          await response.close();
          raf.close();
        } else {
          // full file send
          response.headers.set('Content-Type', 'text/plain; charset=utf-8');
          response.headers.set(
            'Content-Disposition',
            'attachment; filename="${TEncoder.encodeRFC5987(name)}"',
          );
          response.headers.set('Content-Length', fileLength);

          // UTF-8 stream နဲ့ pipe လုပ်
          await file.openRead().pipe(response);
        }
      } else {
        response
          ..statusCode = HttpStatus.notFound
          ..write('File not found')
          ..close();
      }
    } catch (e) {
      TLogger.instance.showLog(e.toString(), tag: 'sendFile');
      response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error')
        ..close();
    }
  }

  ///
  /// upload from client
  ///
  Future<void> uploadFile(String outPath) async {
    try {
      final contentType = headers.contentType;
      if (contentType == null ||
          !contentType.mimeType.startsWith('multipart/form-data')) {
        response
          ..statusCode = HttpStatus.unsupportedMediaType
          ..write('Only multipart/form-data supported')
          ..close();
        return;
      }

      // parse multipart form
      final transformer = MimeMultipartTransformer(
        contentType.parameters['boundary']!,
      );
      final bodyStream = cast<List<int>>().transform(transformer);

      await for (MimeMultipart part in bodyStream) {
        final headers = part.headers;
        if (headers['content-disposition'] != null &&
            headers['content-disposition']!.contains('filename=')) {
          // extract filename
          final contentDisposition = headers['content-disposition']!;
          final filename =
              RegExp(
                r'filename="(.+)"',
              ).firstMatch(contentDisposition)?.group(1) ??
              'upload_${DateTime.now().millisecondsSinceEpoch}';

          final file = File('$outPath/$filename');
          await file.create(recursive: true);

          final sink = file.openWrite();
          await part.pipe(sink);
          await sink.close();
          TLogger.instance.showLog(
            "Uploaded file: ${file.path}",
            tag: 'uploadFile',
          );
        }
      }

      response
        ..statusCode = HttpStatus.ok
        ..write('Upload successful')
        ..close();
    } catch (e) {
      TLogger.instance.showLog(e.toString(), tag: 'uploadFile');
      response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error')
        ..close();
    }
  }

  ///
  /// send video streamming
  ///
  Future<void> sendVideoStream(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        response
          ..statusCode = HttpStatus.notFound
          ..write('File not found')
          ..close();
        return;
      }

      final total = await file.length();
      int start = 0;
      int end = total - 1;

      final rangeHeader = headers.value(HttpHeaders.rangeHeader);
      if (rangeHeader != null) {
        final match = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(rangeHeader);
        if (match != null) {
          start = int.parse(match.group(1)!);
          if (match.group(2) != null && match.group(2)!.isNotEmpty) {
            end = int.parse(match.group(2)!);
          }
        }
        response.statusCode = HttpStatus.partialContent;
      }

      final length = end - start + 1;

      response.headers
        ..set(HttpHeaders.contentTypeHeader, 'video/mp4')
        ..set(HttpHeaders.acceptRangesHeader, 'bytes')
        ..set(HttpHeaders.contentLengthHeader, length.toString())
        ..set(HttpHeaders.contentRangeHeader, 'bytes $start-$end/$total');

      final stream = file.openRead(start, end + 1);
      await stream.pipe(response);
    } catch (e) {
      TLogger.instance.showLog(e.toString(), tag: 'sendVideoStream');
      response
        ..statusCode = HttpStatus.internalServerError
        ..write('Server Error')
        ..close();
    }
  }
}

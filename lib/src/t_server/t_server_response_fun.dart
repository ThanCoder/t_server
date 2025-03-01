//send body
import 'dart:io';

void tServerSend(
  HttpRequest req, {
  String body = 'new route',
  ContentType? contentType,
  int httpStatus = 200,
}) {
  contentType ??= ContentType.text;
  req.response
    ..statusCode = httpStatus
    ..write(body)
    ..close();
}

//send file
Future<void> tServerSendFile(HttpRequest req, String filePath) async {
  final file = File(filePath);
  if (!await file.exists()) {
    req.response
      ..statusCode = HttpStatus.notFound
      ..write('File Not Found')
      ..close();
    return;
  }
  //file ရှိရင်
  req.response.headers
    ..set(HttpHeaders.contentTypeHeader, 'application/octet-stream')
    ..set(HttpHeaders.contentLengthHeader, file.lengthSync())
    ..set(
      HttpHeaders.contentDisposition,
      'attachment;filename=${file.path.split('/').last}',
    );
  //send file
  await file.openRead().pipe(req.response);
}

Future<void> tServerStreamVideo(HttpRequest req, String videoPath) async {
  final File videoFile = File(videoPath);
  if (!await videoFile.exists()) {
    req.response
      ..statusCode = HttpStatus.notFound
      ..write('Video not found')
      ..close();
    return;
  }

  final int fileSize = await videoFile.length();
  final HttpResponse response = req.response;

  response.headers.set(HttpHeaders.contentTypeHeader, 'video/mp4');
  response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');

  final String? range = req.headers.value(HttpHeaders.rangeHeader);
  if (range != null && range.startsWith('bytes=')) {
    final parts = range.substring(6).split('-');
    final int start = int.parse(parts[0]);
    final int end =
        parts.length > 1 && parts[1].isNotEmpty
            ? int.parse(parts[1])
            : fileSize - 1;
    final int contentLength = end - start + 1;

    response
      ..statusCode = HttpStatus.partialContent
      ..headers.set(
        HttpHeaders.contentRangeHeader,
        'bytes $start-$end/$fileSize',
      )
      ..headers.set(HttpHeaders.contentLengthHeader, contentLength);

    await videoFile.openRead(start, end + 1).pipe(response);
  } else {
    response.headers.set(HttpHeaders.contentLengthHeader, fileSize);
    await videoFile.openRead().pipe(response);
  }
}

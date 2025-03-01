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

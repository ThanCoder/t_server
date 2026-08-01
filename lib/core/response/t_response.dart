import 'dart:io';

class TResponse {
  final HttpResponse raw;
  const TResponse(this.raw);

  Future<void> text(String value) async {
    raw
      ..headers.contentType = ContentType.text
      ..write(value);

    await raw.close();
  }
}

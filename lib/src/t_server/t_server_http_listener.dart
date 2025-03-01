import 'dart:io';

class TServerHttpListener {
  String url;
  String method;
  void Function(HttpRequest req) onRequest;
  TServerHttpListener({
    required this.url,
    required this.method,
    required this.onRequest,
  });
}

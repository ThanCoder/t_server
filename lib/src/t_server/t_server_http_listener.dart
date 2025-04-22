import 'dart:io';

///
/// server http listener
///
class TServerHttpListener {
  ///
  /// url path
  ///
  String url;

  ///
  /// GET,POST,DELETE,PUT
  ///
  String method;

  ///
  /// listener callback
  ///
  void Function(HttpRequest req) onRequest;

  ///
  /// constructor
  ///
  TServerHttpListener({
    required this.url,
    required this.method,
    required this.onRequest,
  });
}

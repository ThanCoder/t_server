import 'dart:io';

///
/// server socket listener
///
class TServerSocketListener {
  ///
  /// socket url path
  ///
  String url;
  ///
  /// socket listener
  ///
  void Function(HttpRequest req, WebSocket socket) onListen;
  ///
  /// constructor
  ///
  TServerSocketListener({required this.url, required this.onListen});
}

import 'dart:io';

class TServerSocketListener {
  String url;
  void Function(HttpRequest req, WebSocket socket) onListen;
  TServerSocketListener({required this.url, required this.onListen});
}

import 'dart:io';

import 'index.dart';

class TServer {
  static final TServer instance = TServer._();
  TServer._();
  factory TServer() => instance;

  late HttpServer _httpServer;
  void Function(String msg)? onError;
  final List<TServerHttpListener> _httpListener = [];
  final List<TServerSocketListener> _webSocktetlistenerList = [];

  Future<TServer> startServer({int port = 3300, bool shared = true}) async {
    try {
      //all clear
      _httpListener.clear();
      _webSocktetlistenerList.clear();

      _httpServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: shared,
      );
      _httpServer.listen(_onListen);
    } catch (e) {
      if (onError != null) {
        onError!(e.toString());
      }
    }
    return this;
  }

  void _onListen(HttpRequest req) {
    final method = req.method;
    final url = req.uri.path;
    //for websocket
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      _handleWebSocket(req);
      return;
    }
    //for http
    for (final _listener in _httpListener) {
      if (_listener.method == method && _listener.url == url) {
        _listener.onRequest(req);
        return;
      }
    }

    // No matching route, return 404 response
    req.response
      ..statusCode = HttpStatus.notFound
      ..write('404 Not Found')
      ..close();
  }

  //set listener http
  void get(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'GET', onRequest: onReq),
    );
  }

  //post
  void post(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'POST', onRequest: onReq),
    );
  }

  //delete
  void delete(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'DELETE', onRequest: onReq),
    );
  }

  //put
  void put(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'PUT', onRequest: onReq),
    );
  }
  /////////////////

  //websocket set listener
  void onSocket(
    String url,
    void Function(HttpRequest http, WebSocket socket) onListen,
  ) {
    final socketListener = TServerSocketListener(url: url, onListen: onListen);
    _webSocktetlistenerList.add(socketListener);
  }

  //web socket
  void _handleWebSocket(HttpRequest req) async {
    try {
      final url = req.uri.path;
      for (final _listener in _webSocktetlistenerList) {
        if (_listener.url == url) {
          final socket = await WebSocketTransformer.upgrade(req);
          _listener.onListen(req, socket);
          return;
        }
      }

      // No matching route, return 404 response
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('404 Not Found')
        ..close();
    } catch (e) {
      if (onError != null) {
        onError!('websocket: ${e.toString()}');
      }
    }
  }

  //stop server
  Future<void> stopServer({bool force = false}) async {
    try {
      _httpServer.close(force: force);
    } catch (e) {}
  }
}

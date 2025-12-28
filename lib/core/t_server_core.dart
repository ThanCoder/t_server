import 'dart:io';

import 'package:t_server/core/index.dart';
import 'package:t_server/core/interfaces/t_router_interface.dart';
import 'package:t_server/core/method.dart';
import 'package:t_server/core/routers/t_socket_handler.dart';

final serverParams = <String, Map<String, String>>{};

/// --- TServer ---
/// Main server class
class TServer {
  ///
  /// --- Static ---
  ///
  static TServer? _instance;
  static TServer get getInstance {
    _instance ??= TServer();
    return _instance!;
  }

  TRouterInterface? _router;
  TSocketRouter? _socketRouter;
  HttpServer? _server;

  TServer() {
    serverParams.clear();
  }
  void setRouter(TRouterInterface router) {
    _router = router;
  }

  void setSocketRouter(TSocketRouter socketRouter) {
    _socketRouter = socketRouter;
  }

  Future<void> start(
    String host,
    int port, {
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
    void Function()? onStartServer,
  }) async {
    _server = await HttpServer.bind(
      host,
      port,
      backlog: backlog,
      v6Only: v6Only,
      shared: shared,
    );
    onStartServer?.call();

    await for (var req in _server!) {
      // WebSocket upgrade check
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        final socket = await WebSocketTransformer.upgrade(req);
        _socketRouter?.handle(req, socket);
        continue;
      }
      if (_router == null) {
        req.sendHtml('<h1>Router Not Found!</h1>');
      }

      // HTTP request
      final params = <String, String>{};
      final route = _router?.find(
        Method.fromName(req.method),
        req.uri.path,
        params,
      );

      if (route != null) {
        serverParams[req.uri.path] = params;
        route.handler(req);
      } else {
        req.sendNotFoundHtml();
      }
    }
  }

  Future<void> stop({bool force = false}) async {
    await _server?.close(force: force);
  }

  int get port => _server!.port;
}

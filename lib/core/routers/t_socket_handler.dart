import 'dart:io';

import 'package:t_server/core/routers/route_handler.dart';

/// Stores WebSocket handlers
class TSocketRouter {
  final _handlers = <SocketHandler>[];

  void add(SocketHandler handler) => _handlers.add(handler);

  void handle(HttpRequest req, WebSocket socket) {
    for (var h in _handlers) {
      h(req, socket);
    }
  }
}

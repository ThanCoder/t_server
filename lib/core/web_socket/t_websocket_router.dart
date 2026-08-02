import 'package:t_server/core/web_socket/t_websocket_handler.dart';
import 'package:t_server/core/web_socket/middleware/t_websocket_middleware.dart';
import 'package:t_server/core/web_socket/t_websocket_route.dart';

class TWebSocketRouter {
  final List<TWebsocketRoute> _routes = [];

  void route(
    String path,
    TWebSocketHandler handler, {
    List<TWebSocketMiddleware> middlewares = const [],
  }) {
    _routes.add(
      TWebsocketRoute(path: path, handler: handler, middlewares: middlewares),
    );
  }

  TWebsocketRoute? find(String path) {
    for (var route in _routes) {
      if (route.path == path) {
        return route;
      }
    }
    return null;
  }
}

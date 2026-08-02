// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:t_server/core/web_socket/t_websocket_handler.dart';
import 'package:t_server/core/web_socket/middleware/t_websocket_middleware.dart';

class TWebsocketRoute {
  final String path;
  final TWebSocketHandler handler;
  final List<TWebSocketMiddleware> middlewares;
  const TWebsocketRoute({
    required this.path,
    required this.handler,
    this.middlewares = const [],
  });
}

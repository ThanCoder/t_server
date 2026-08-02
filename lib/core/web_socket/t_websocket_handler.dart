import 'package:t_server/core/web_socket/websocket_context.dart';

typedef TWebSocketHandler = Future<void> Function(TWebSocketContext ctx);

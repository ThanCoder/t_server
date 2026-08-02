import 'package:t_server/core/web_socket/t_websocket.dart';
import 'package:t_server/core/web_socket/message/t_websocket_message.dart';

typedef TWebSocketMessageHandler =
    Future<void> Function(TWebSocketMessage message);

typedef TWebSocketCloseHandler = Future<void> Function(TWebSocket socket);

typedef TWebSocketErrorHandler =
    Future<void> Function(TWebSocket socket, Object error);

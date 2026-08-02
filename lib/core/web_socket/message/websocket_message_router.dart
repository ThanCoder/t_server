import 'package:t_server/core/web_socket/t_websocket.dart';
import 'package:t_server/core/web_socket/message/t_websocket_message.dart';
import 'package:t_server/core/web_socket/message/websocket_message_handler.dart';

class TWebSocketMessageRouter {
  final Map<String, TWebSocketMessageHandler> _handlers = {};

  void on(String type, TWebSocketMessageHandler handler) {
    _handlers[type] = handler;
  }

  TWebSocketMessageHandler? find(String type) {
    return _handlers[type];
  }

  Future<void> handle(TWebSocket socket, TWebSocketMessage message) async {
    final handler = find(message.type);

    if (handler == null) {
      return;
    }

    await handler(message);
  }
}

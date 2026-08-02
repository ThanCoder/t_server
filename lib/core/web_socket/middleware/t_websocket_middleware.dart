import 'package:t_server/core/web_socket/websocket_context.dart';

typedef TWebSocketNext = Future<void> Function();

typedef TWebSocketMiddlewareCallback =
    Future<void> Function(TWebSocketContext ctx, TWebSocketNext next);

abstract class TWebSocketMiddleware {
  Future<void> handle(TWebSocketContext ctx, TWebSocketNext next);
}

class CallbackWebSocketMiddleware extends TWebSocketMiddleware {
  final TWebSocketMiddlewareCallback callback;

  CallbackWebSocketMiddleware(this.callback);

  @override
  Future<void> handle(TWebSocketContext ctx, TWebSocketNext next) async {
    await callback(ctx, next);
  }
}

import 'package:t_server/core/web_socket/middleware/t_websocket_middleware.dart';
import 'package:t_server/core/web_socket/websocket_context.dart';

class TWebSocketMiddlewareManager {
  Future<void> run(
    TWebSocketContext ctx,
    List<TWebSocketMiddleware> middlewares,
    TWebSocketNext finalHandler,
  ) async {
    var index = 0;

    Future<void> next() async {
      if (index >= middlewares.length) {
        await finalHandler();
        return;
      }

      final middleware = middlewares[index++];

      await middleware.handle(ctx, next);
    }

    await next();
  }
}

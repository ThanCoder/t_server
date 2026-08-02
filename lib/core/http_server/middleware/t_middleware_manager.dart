import 'package:t_server/core/http_server/t_context.dart';
import 'package:t_server/core/http_server/middleware/t_middleware.dart';

class TMiddlewareManager {
  Future<void> run(
    TContext ctx,
    List<TMiddleware> middlewares,
    TNext finalHandler,
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

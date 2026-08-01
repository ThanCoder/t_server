import 'package:t_server/core/context/t_context.dart';

typedef TNext = Future<void> Function();
typedef TMiddlewareCallback = Future<void> Function(TContext ctx, TNext next);

abstract class TMiddleware {
  Future<void> handle(TContext ctx, TNext next);
}

class CallbackMiddleware extends TMiddleware {
  final TMiddlewareCallback callback;
  CallbackMiddleware(this.callback);

  @override
  Future<void> handle(TContext ctx, TNext next) async {
    await callback(ctx, next);
  }
}

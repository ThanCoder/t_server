import 'dart:io';

import 'package:t_server/core/context/t_context.dart';
import 'package:t_server/core/method/t_method.dart';
import 'package:t_server/core/middleware/t_middleware.dart';
import 'package:t_server/core/middleware/t_middleware_manager.dart';
import 'package:t_server/core/request/t_request.dart';
import 'package:t_server/core/router/t_router.dart';

class TServer {
  HttpServer? _server;

  TServer();

  /// middleware
  final _middlewareManager = TMiddlewareManager();

  /// use middleware
  final List<TMiddleware> _globalMiddlewares = [];
  void use(TMiddleware middleware) {
    _globalMiddlewares.add(middleware);
  }

  /// Router
  TRouter? _router;

  /// Set Router
  void setRouter(TRouter router) {
    _router = router;
  }

  int? get port => _server?.port;

  InternetAddress? get getAddress => _server?.address;

  Future<void> start({
    String address = 'localhost',
    int port = 8080,
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    _server = await HttpServer.bind(address, port);
    _server!.listen(_handleRequest);
  }

  Future<void> _handleRequest(HttpRequest rawReq) async {
    final req = TRequest(rawReq);
    final ctx = TContext(req);
    try {
      //*********Middleware********** */
      await _middlewareManager.run(ctx, _globalMiddlewares, () async {
        //*********Router********** */
        await _handleRoutes(ctx);
      });
    } catch (e) {
      print('[TServer:_handleRequest]: $e');
      await ctx.request.response.text(
        'Internal Server Error',
        statusCode: HttpStatus.internalServerError,
      );
    }
  }

  Future<void> _handleRoutes(TContext ctx) async {
    if (_router == null) {
      await ctx.response.text('Router Not Found');
      return;
    }
    final method = TMethod.fromValue(ctx.request.method);
    final result = _router?.find(method, ctx.request.path);

    if (result == null) {
      ctx.response.text('404 Not Found!');
      return;
    }

    ctx.params.addAll(result.params);
    // local middlewares
    final middlewares = result.route.middlewares;
    await _middlewareManager.run(ctx, middlewares, () async {
      await result.route.handler(ctx);
    });
  }
}

import 'dart:io';

import 'package:t_server/core/http_server/t_context.dart';
import 'package:t_server/core/http_server/method/t_method.dart';
import 'package:t_server/core/http_server/middleware/t_middleware.dart';
import 'package:t_server/core/http_server/middleware/t_middleware_manager.dart';
import 'package:t_server/core/http_server/request/t_request.dart';
import 'package:t_server/core/http_server/router/http_router.dart';
import 'package:t_server/core/web_socket/t_websocket.dart';
import 'package:t_server/core/web_socket/t_websocket_manager.dart';
import 'package:t_server/core/web_socket/middleware/t_websocket_middleware.dart';
import 'package:t_server/core/web_socket/middleware/t_websocket_middleware_manager.dart';
import 'package:t_server/core/web_socket/t_websocket_router.dart';
import 'package:t_server/core/web_socket/websocket_context.dart';

class TServer {
  HttpServer? _server;

  TServer();

  /// middleware
  final _middlewareManager = TMiddlewareManager();

  /// use middleware
  final List<TMiddleware> _globalMiddlewares = [];

  /// ### Http Global Middleware
  ///
  /// callback `CallbackMiddleware`
  ///
  ///extends for custom -> `TMiddleware`
  void use(TMiddleware middleware) {
    _globalMiddlewares.add(middleware);
  }

  /// Router
  THttpRouter? _router;

  /// Set Router
  void setRouter(THttpRouter router) {
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

  /// ### Handle `HttpRequest`
  Future<void> _handleRequest(HttpRequest rawReq) async {
    final req = TRequest(rawReq);
    final ctx = TContext(req);
    if (WebSocketTransformer.isUpgradeRequest(rawReq)) {
      await _handleWebsocket(rawReq);
      return;
    }
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

  /// ### Handle `Routes`
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

  //****************Websocket*********************** */

  TWebSocketRouter? _webSocketRouter;

  /// ### WS Set Router
  void setWebSocketRouter(TWebSocketRouter router) {
    _webSocketRouter = router;
  }

  final _webSocketMiddlewareManager = TWebSocketMiddlewareManager();

  final List<TWebSocketMiddleware> _globalWebSocketMiddlewares = [];

  /// ### WS Global Middleware
  ///
  ///callback ->  `CallbackWebSocketMiddleware`
  ///
  ///extends for custom -> `TWebSocketMiddleware`
  void useWebSocket(TWebSocketMiddleware middleware) {
    _globalWebSocketMiddlewares.add(middleware);
  }

  final _webSocketManager = TWebSocketManager();

  /// ### Handle `Websocket`
  Future<void> _handleWebsocket(HttpRequest rawReq) async {
    final router = _webSocketRouter;

    if (router == null) {
      rawReq.response
        ..statusCode = HttpStatus.notFound
        ..write('WebSocket Router Not Found');

      await rawReq.response.close();
      return;
    }

    final route = router.find(rawReq.uri.path);

    if (route == null) {
      rawReq.response
        ..statusCode = HttpStatus.notFound
        ..write('WebSocket Route Not Found');

      await rawReq.response.close();
      return;
    }

    final rawSocket = await WebSocketTransformer.upgrade(rawReq);

    final socket = TWebSocket(
      rawSocket,
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      path: rawReq.uri.path,
      headers: rawReq.headers,
    );

    _webSocketManager.add(socket);

    rawSocket.done
        .then((_) {
          _webSocketManager.remove(socket.id);
        })
        .catchError((error) {
          _webSocketManager.remove(socket.id);
        });

    final middlewares = [..._globalWebSocketMiddlewares, ...route.middlewares];
    // create websocket context
    final ctx = TWebSocketContext(
      socket: socket,
      webSockets: _webSocketManager,
    );

    await _webSocketMiddlewareManager.run(ctx, middlewares, () async {
      await route.handler(ctx);
      socket.connect();

      await socket.done;
    });
  }
}

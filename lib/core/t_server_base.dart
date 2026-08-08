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

  /// ### Http Global Middleware
  /// callback
  void useCacllback(TMiddlewareCallback callback) {
    _globalMiddlewares.add(CallbackMiddleware(callback));
  }

  /// Router
  THttpRouter? _router;

  /// Set Router
  void setRouter(THttpRouter router) {
    _router = router;
  }

  int? get port => _server?.port;

  InternetAddress? get getAddress => _server?.address;

  bool _isOpened = false;
  bool get isOpened => _isOpened;

  /// ### Start Server
  /// Starts listening for HTTP requests on the specified [address] and
  /// [port].
  ///
  /// The [address] can either be a [String] or an
  /// [InternetAddress]. If [address] is a [String], [bind] will
  /// perform a [InternetAddress.lookup] and use the first value in the
  /// list. To listen on the loopback adapter, which will allow only
  /// incoming connections from the local host, use the value
  /// [InternetAddress.loopbackIPv4] or
  /// [InternetAddress.loopbackIPv6]. To allow for incoming
  /// connection from the network use either one of the values
  /// [InternetAddress.anyIPv4] or [InternetAddress.anyIPv6] to
  /// bind to all interfaces or the IP address of a specific interface.
  ///
  /// If an IP version 6 (IPv6) address is used, both IP version 6
  /// (IPv6) and version 4 (IPv4) connections will be accepted. To
  /// restrict this to version 6 (IPv6) only, use [v6Only] to set
  /// version 6 only. However, if the address is
  /// [InternetAddress.loopbackIPv6], only IP version 6 (IPv6) connections
  /// will be accepted.
  ///
  /// If [port] has the value 0 an ephemeral port will be chosen by
  /// the system. The actual port used can be retrieved using the
  /// [port] getter.
  ///
  /// The optional argument [backlog] can be used to specify the listen
  /// backlog for the underlying OS listen setup. If [backlog] has the
  /// value of 0 (the default) a reasonable value will be chosen by
  /// the system.
  ///
  /// The optional argument [shared] specifies whether additional `HttpServer`
  /// objects can bind to the same combination of `address`, `port` and `v6Only`.
  /// If `shared` is `true` and more `HttpServer`s from this isolate or other
  /// isolates are bound to the port, then the incoming connections will be
  /// distributed among all the bound `HttpServer`s. Connections can be
  /// distributed over multiple isolates this way.
  Future<void> start({
    String address = 'localhost',
    int port = 8080,
    int backlog = 0,
    bool v6Only = false,
    bool shared = false,
  }) async {
    if (isOpened) return;
    _server = await HttpServer.bind(
      address,
      port,
      backlog: backlog,
      v6Only: v6Only,
      shared: shared,
    );
    _server!.listen(_handleRequest);
    _isOpened = true;
  }

  /// ### Stop Server
  ///
  /// Permanently stops this [HttpServer] from listening for new
  /// connections.  This closes the [Stream] of [HttpRequest]s with a
  /// done event. The returned future completes when the server is
  /// stopped. For a server started using [bind] or [bindSecure] this
  /// means that the port listened on no longer in use.
  ///
  /// If [force] is `true`, active connections will be closed immediately.
  Future<void> stop({bool force = false}) async {
    if (!_isOpened) return;
    await _server?.close(force: force);
    _server = null;
  }
  //****************Http Request Handler*********************** */

  /// ### Handle `HttpRequest`
  Future<void> _handleRequest(HttpRequest rawReq) async {
    final req = TRequest(rawReq);
    final ctx = TContext(req);
    // websocket
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

  //****************Http Routes*********************** */

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

  void useWebSocketCallback(TWebSocketMiddlewareCallback callback) {
    _globalWebSocketMiddlewares.add(CallbackWebSocketMiddleware(callback));
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

    final ctx = TWebSocketContext(
      socket: socket,
      webSockets: _webSocketManager,
    );

    _webSocketManager.add(socket);

    await _webSocketMiddlewareManager.run(
      ctx,
      _globalWebSocketMiddlewares,
      () async {
        await _webSocketMiddlewareManager.run(ctx, route.middlewares, () async {
          await route.handler(ctx);
        });
      },
    );

    socket.connect();
  }
}

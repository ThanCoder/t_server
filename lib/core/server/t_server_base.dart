import 'dart:io';

import 'package:t_server/core/context/t_context.dart';
import 'package:t_server/core/method/t_method.dart';
import 'package:t_server/core/request/t_request.dart';
import 'package:t_server/core/router/t_router.dart';

class TServer {
  HttpServer? _server;
  final TRouter _router;
  TServer({required this._router});

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

    final result = _router.find(
      TMethod.fromValue(ctx.request.method),
      ctx.request.path,
    );

    if (result == null) {
      ctx.request.response.text('404 Not Found!');
      return;
    }

    ctx.params.addAll(result.params);
    await result.route.handler(ctx);
  }
}

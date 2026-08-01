import 'package:t_server/core/method/t_method.dart';
import 'package:t_server/core/middleware/t_middleware.dart';
import 'package:t_server/core/router/route_handler.dart';
import 'package:t_server/core/router/route_utils.dart';
import 'package:t_server/core/router/t_route.dart';
import 'package:t_server/core/router/route_result.dart';

class TRouter {
  final List<TRoute> _routes = [];

  /// GET
  void get(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.get, path, handler, middlewares: middlewares);
  }

  /// POST
  void post(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.post, path, handler, middlewares: middlewares);
  }

  /// PUT
  void put(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.put, path, handler, middlewares: middlewares);
  }

  /// DELETE
  void delete(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.delete, path, handler, middlewares: middlewares);
  }

  /// HEAD
  void head(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.head, path, handler, middlewares: middlewares);
  }

  /// OPTIONS
  void options(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.options, path, handler, middlewares: middlewares);
  }

  /// PATH
  void patch(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.patch, path, handler, middlewares: middlewares);
  }

  /// CONNECT
  void connect(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.connect, path, handler, middlewares: middlewares);
  }

  /// TRACE
  void trace(
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    _add(TMethod.trace, path, handler, middlewares: middlewares);
  }

  void _add(
    TMethod method,
    String path,
    THandler handler, {
    List<TMiddleware> middlewares = const [],
  }) {
    final normalized = RouteUtils.normalizePath(path);

    for (final route in _routes) {
      if (route.method != method) {
        continue;
      }
      if (route.normalizedPath == normalized) {
        throw StateError('Duplicate route: ${method.name} $path');
      }
    }

    _routes.add(
      TRoute(
        method: method,
        path: path,
        handler: handler,
        middlewares: middlewares,
      ),
    );
  }

  RouteResult? find(TMethod method, String path) {
    final routes = _routes.where((route) => route.method == method).toList();

    routes.sort((a, b) => b.score.compareTo(a.score));

    // 1. Static route
    for (final route in routes) {
      if (!route.isDynamic) {
        final params = route.match(path);

        if (params != null) {
          return RouteResult(route, params);
        }
      }
    }

    // 2. Dynamic route
    for (final route in routes) {
      if (route.isDynamic) {
        final params = route.match(path);

        if (params != null) {
          return RouteResult(route, params);
        }
      }
    }

    return null;
  }
}

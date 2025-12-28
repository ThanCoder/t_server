import 'package:t_server/core/interfaces/t_router_interface.dart';
import 'package:t_server/core/method.dart';
import 'package:t_server/core/routers/route_handler.dart';

/// --- Router ---
/// Stores multiple RouteHandler per HTTP method
class TRouter extends TRouterInterface {
  final _routes = <String, List<RouteHandler>>{};

  void add(Method method, String path, HttpHandler handler) {
    _routes
        .putIfAbsent(method.value, () => [])
        .add(RouteHandler(path, handler));
  }

  @override
  void get(String path, HttpHandler handler) => add(Method.get, path, handler);
  @override
  void post(String path, HttpHandler handler) =>
      add(Method.post, path, handler);
  @override
  void put(String path, HttpHandler handler) => add(Method.put, path, handler);
  @override
  void delete(String path, HttpHandler handler) =>
      add(Method.delete, path, handler);
  @override
  void path(String path, HttpHandler handler) =>
      add(Method.path, path, handler);

  @override
  RouteHandler? find(
    Method method,
    String path,
    Map<String, String> outParams,
  ) {
    final handlers = _routes[method.value];
    if (handlers == null) return null;

    for (var r in handlers) {
      final params = r.match(path);
      if (params != null) {
        outParams.addAll(params);
        return r;
      }
    }
    return null;
  }
}

import 'package:t_server/core/method/t_method.dart';
import 'package:t_server/core/router/route_handler.dart';
import 'package:t_server/core/router/t_route.dart';
import 'package:t_server/core/router/t_route_match.dart';

class TRouter {
  final List<TRoute> _routes = [];

  void _add(TMethod method, String path, THandler handler) {
    _routes.add(TRoute(method: method, path: path, handler: handler));
  }

  /// GET
  void get(String path, THandler handler) {
    _add(TMethod.get, path, handler);
  }

  /// POST
  void post(String path, THandler handler) {
    _add(TMethod.post, path, handler);
  }

  /// PUT
  void put(String path, THandler handler) {
    _add(TMethod.put, path, handler);
  }

  /// DELETE
  void delete(String path, THandler handler) {
    _add(TMethod.delete, path, handler);
  }

  /// HEAD
  void head(String path, THandler handler) {
    _add(TMethod.head, path, handler);
  }

  /// OPTIONS
  void options(String path, THandler handler) {
    _add(TMethod.options, path, handler);
  }

  /// PATH
  void patch(String path, THandler handler) {
    _add(TMethod.patch, path, handler);
  }

  /// CONNECT
  void connect(String path, THandler handler) {
    _add(TMethod.connect, path, handler);
  }

  /// TRACE
  void trace(String path, THandler handler) {
    _add(TMethod.trace, path, handler);
  }

  TRouteMatch? find(TMethod method, String path) {
    for (var route in _routes) {
      ///method မတူရင် ကျော်မယ်
      if (route.method != method) {
        continue;
      }
      final res = route.match(path);
      if (res != null) {
        return TRouteMatch(route, res);
      }
    }

    return null;
  }
}

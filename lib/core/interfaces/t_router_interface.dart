import 'package:t_server/core/method.dart';
import 'package:t_server/core/routers/route_handler.dart';

abstract class TRouterInterface {
  void get(String path, HttpHandler handler);
  void post(String path, HttpHandler handler);
  void put(String path, HttpHandler handler);
  void delete(String path, HttpHandler handler);
  void path(String path, HttpHandler handler);
  RouteHandler? find(Method method, String path, Map<String, String> outParams);
}

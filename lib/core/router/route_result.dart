import 'package:t_server/core/router/t_route.dart';

class RouteResult {
  final TRoute route;
  final Map<String, String> params;

  RouteResult(this.route, this.params);
}

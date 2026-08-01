import 'package:t_server/core/router/t_route.dart';

class TRouteMatch {
  final TRoute route;
  final Map<String, String> params;
  const TRouteMatch(this.route, this.params);
}

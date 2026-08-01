// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:t_server/core/method/t_method.dart';
import 'package:t_server/core/router/route_handler.dart';

class TRoute {
  final TMethod method;
  final String path;
  final THandler handler;
  const TRoute({
    required this.method,
    required this.path,
    required this.handler,
  });

  Map<String, String>? match(String requestPath) {
    final routeParts = path.split('/');
    final requestParts = requestPath.split('/');

    if (routeParts.length != requestParts.length) {
      return null;
    }

    final params = <String, String>{};

    for (var i = 0; i < routeParts.length; i++) {
      final routePart = routeParts[i];
      final requestPart = requestParts[i];
      if (routePart.startsWith(':')) {
        final name = routePart.substring(1);

        params[name] = requestPart;
        continue;
      }

      if (routePart != requestPart) {
        return null;
      }
    }

    return params;
  }

  @override
  String toString() {
    return 'Path: $path';
  }
}

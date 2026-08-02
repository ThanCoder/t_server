// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:t_server/core/http_server/method/t_method.dart';
import 'package:t_server/core/http_server/middleware/t_middleware.dart';
import 'package:t_server/core/http_server/router/route_handler.dart';
import 'package:t_server/core/http_server/router/route_utils.dart';

class TRoute {
  final TMethod method;
  final String path;
  final THandler handler;
  final List<TMiddleware> middlewares;
  const TRoute({
    required this.method,
    required this.path,
    required this.handler,
    this.middlewares = const [],
  });

  bool get isDynamic {
    return path.split('/').any((part) => part.startsWith(':'));
  }

  List<String> _splitPath(String path) {
    return path.split('/').where((e) => e.isNotEmpty).toList();
  }

  String get normalizedPath => RouteUtils.normalizePath(path);

  int get score {
    final parts = path.split('/').where((e) => e.isNotEmpty);

    var score = 0;

    for (final part in parts) {
      if (!part.startsWith(':')) {
        score++;
      }
    }

    return score;
  }

  Map<String, String>? match(String requestPath) {
    final routeParts = _splitPath(path);
    final requestParts = _splitPath(requestPath);

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

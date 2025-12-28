import 'dart:io';

typedef HttpHandler = void Function(HttpRequest req);
typedef SocketHandler = void Function(HttpRequest req, WebSocket socket);

/// --- RouteHandler ---
/// Stores a route template and handler function
class RouteHandler {
  final String template;
  final HttpHandler handler;
  const RouteHandler(this.template, this.handler);

  /// Match request URL against template
  /// Return path parameters if match, otherwise null
  Map<String, String>? match(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    final templateSegments = template
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();

    if (segments.length != templateSegments.length) return null;

    final params = <String, String>{};
    for (var i = 0; i < templateSegments.length; i++) {
      final seg = templateSegments[i];
      if (seg.startsWith(':')) {
        // path param
        final key = seg.substring(1);
        params[key] = segments[i];
      } else if (seg != segments[i]) {
        // literal mismatch
        return null;
      }
    }
    return params;
  }
}

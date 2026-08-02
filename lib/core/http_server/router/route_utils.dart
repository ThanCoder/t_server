class RouteUtils {
  static String normalizePath(String path) {
    final parts = path.split('/').where((e) => e.isNotEmpty).toList();

    if (parts.isEmpty) {
      return '/';
    }

    return '/${parts.map((part) => part.startsWith(':') ? ':' : part).join('/')}';
  }
}

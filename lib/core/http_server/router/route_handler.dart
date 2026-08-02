import 'package:t_server/core/http_server/t_context.dart';

typedef THandler = Future<void> Function(TContext ctx);

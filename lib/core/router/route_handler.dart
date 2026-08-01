import 'package:t_server/core/context/t_context.dart';

typedef THandler = Future<void> Function(TContext ctx);

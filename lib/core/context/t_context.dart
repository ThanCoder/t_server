import 'package:t_server/core/request/t_request.dart';

class TContext {
  final TRequest request;
  final params = <String, String>{};

  TContext(this.request);
}

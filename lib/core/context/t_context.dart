import 'package:t_server/core/request/t_request.dart';
import 'package:t_server/core/response/t_response.dart';

class TContext {
  final TRequest request;
  final params = <String, String>{};
  final state = <String, dynamic>{};

  TContext(this.request);

  Map<String, String> get query => request.query;

  Future<String> get bodyText => request.bodyText;

  Future<dynamic> get bodyJson => request.bodyJson;

  TResponse get response => request.response;
}

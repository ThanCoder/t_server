import 'dart:io';

final _paramsExpando = Expando<Map<String, String>>('httpRequestParams');

extension HttpRequestParams on HttpRequest {
  Map<String, String> get params => _paramsExpando[this] ?? {};

  void setParams(Map<String, String> p) {
    _paramsExpando[this] = p;
  }
}

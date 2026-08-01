class NotFoundTMethodError extends Error {
  final String inputMethod;

  NotFoundTMethodError(this.inputMethod);

  @override
  String toString() {
    return 'Unsupported HTTP method: $inputMethod';
  }
}

enum TMethod {
  get,
  post,
  put,
  patch,
  delete,
  head,
  options,
  connect,
  trace;

  static final Map<String, TMethod> _methods = {
    for (final method in values) method.name.toUpperCase(): method,
  };

  static TMethod fromValue(String val) {
    final method = _methods[val.toUpperCase()];

    if (method == null) {
      throw NotFoundTMethodError(val);
    }

    return method;
  }
}

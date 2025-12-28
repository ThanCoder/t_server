enum Method {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELTE'),
  path('PATH');

  final String value;
  const Method(this.value);

  static Method fromName(String name) {
    final upper = name.toUpperCase();
    if (upper == get.value) return get;
    if (upper == post.value) return post;
    if (upper == put.value) return put;
    if (upper == delete.value) return delete;
    if (upper == path.value) return path;
    throw Exception('not supported method: `$name`');
  }
}

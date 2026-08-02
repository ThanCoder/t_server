import 'dart:convert';

import 'package:t_server/core/http_server/request/request_helper_fun.dart';

enum TMultipartParserState { boundary, headers, body }

class TMultipartParser {
  final Stream<List<int>> stream;
  final String boundary;

  TMultipartParser(this.stream, this.boundary);

  Future<void> parse() async {
    final delimiter = utf8.encode('--$boundary');

    final buffer = <int>[];

    var state = TMultipartParserState.boundary;

    await for (final chunk in stream) {
      buffer.addAll(chunk);

      switch (state) {
        case TMultipartParserState.boundary:
          final index = indexOfBytes(buffer, delimiter);

          if (index == -1) {
            continue;
          }

          print('BOUNDARY FOUND');

          final afterBoundary = index + delimiter.length;

          buffer.removeRange(0, afterBoundary);

          state = TMultipartParserState.headers;

          print('STATE → HEADERS');
          break;

        case TMultipartParserState.headers:
          print('READ HEADERS');
          break;

        case TMultipartParserState.body:
          print('READ BODY');
          break;
      }
    }
  }
}

import 'package:t_server/t_server.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    final server = TServer();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(server.onError, isTrue);
    });
  });
}

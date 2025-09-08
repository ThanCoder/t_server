import 'package:t_server/core/http_extensions.dart';
import 'package:t_server/core/t_server.dart';

void main() async {
  TServer.instance.get('/', (req) {
    req.sendHtml('<h1>TServer</h1>');
  });
  TServer.instance.get('/download', (req) {
    final filePath = req.getQueryParameters['path'] ?? '';
    req.sendFile(filePath);
  });

  TServer.instance.startListen();
  print('Server Running On: http://localhost:${TServer.instance.getPort}');
}

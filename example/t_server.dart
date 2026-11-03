// ignore_for_file: unused_import

import 'dart:io';

import 'package:t_server/core/http_server/request/multipart_form_ext.dart';
import 'package:t_server/t_server.dart';

void main() async {
  final router = THttpRouter();
  final server = TServer();
  final ws = TWebSocketRouter();

  server.setRouter(router);
  server.setWebSocketRouter(ws);

  router.get('/', (ctx) async {
    await ctx.response.html('<h1>wellcome sever</h1>');
  });

  router.post('/upload', (ctx) async {
    final form = await ctx.request.multipartFile();
    print('form: $form');
    // final file = File('test.pdf');

    await ctx.response.text('OK');
  });

  // ws://localhost:8080/chat
  ws.route('/chat', (ctx) async {
    print('userId: ${ctx.userId}');

    ctx.onClose((socket) async {
      print('close');
    });
  });

  await server.start();
  print('Server running on http://${server.getAddress!.host}:${server.port}');
}

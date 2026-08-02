// ignore_for_file: unused_import

import 'dart:io';

import 'package:t_server/core/http_server/request/multipart_form_ext.dart';
import 'package:t_server/t_server.dart';

void main() async {
  final r = THttpRouter();
  final s = TServer();
  final ws = TWebSocketRouter();

  s.setRouter(r);
  s.setWebSocketRouter(ws);

  r.post('/upload', (ctx) async {
    final form = await ctx.request.multipart();
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

  await s.start();
  print('Server running on http://${s.getAddress!.host}:${s.port}');
}

// class Au extends TWebSocketMiddleware {
//   @override
//   Future<void> handle(TWebSocketContext ctx, TWebSocketNext next) {
//     throw UnimplementedError();
//   }
// }

// class UserAuth extends TMiddleware {
//   @override
//   Future<void> handle(TContext ctx, TNext next) async {
//     final key = ctx.query['key'];
//     if (key == null) {
//       await ctx.response.text('login failed');
//       return;
//     }
//     ctx.state['key'] = key;
//     await next();
//   }
// }


  // r.get('/video-stream', (ctx) async {
  //   final file = File('/home/thancoder/Videos/Zootopia.2016.720p.BluRay.mp4');
  //   await ctx.response.videoStream(file, contentType: TContentType.mp4);
  // });
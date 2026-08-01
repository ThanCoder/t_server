import 'dart:io';

import 'package:t_server/core/router/t_router.dart';
import 'package:t_server/t_server.dart';

void main() async {
  final r = TRouter();
  final s = TServer();

  s.setRouter(r);

  r.get('/download', (ctx) async {
    final file = File(ctx.query['path'] ?? '');
    await ctx.response.download(file);
  });

  await s.start();
  print('Server running on http://${s.getAddress!.host}:${s.port}');
}

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
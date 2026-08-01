import 'package:t_server/core/router/t_router.dart';
import 'package:t_server/t_server.dart';

void main() async {
  final r = TRouter();
  final s = TServer(router: r);

  r.get('/', (ctx) async {
    ctx.request.response.text('Home');
  });

  r.get('/about', (ctx) async {
    ctx.request.response.text('About');
  });
  r.get('/user/:id', (ctx) async {
    final id = ctx.params['id'];

    await ctx.request.response.text('User ID: $id');
  });

  r.get('/user/:id/post/:postId', (ctx) async {
    final id = ctx.params['id'];
    final postId = ctx.params['postId'];

    await ctx.request.response.text('User: $id, Post: $postId');
  });
 r.get('/user', (ctx) async {
    await ctx.request.response.text('i am get method');
  });
  r.post('/user', (ctx) async {
    await ctx.request.response.text('i am post method');
  });

  await s.start();
}

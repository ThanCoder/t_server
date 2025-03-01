import 'dart:io';

import 'package:t_server/t_server.dart';

void main() {
  TServer.instance.startServer(port: 3000);
  print('server is running on port 3000');

  //http request
  TServer.instance.get('/', (req) {
    tServerSend(req, body: 'hello TServer');
  });
  TServer.instance.post('/', (req) {
    tServerSend(req, body: 'TServer post request');
  });
  TServer.instance.put('/', (req) {
    tServerSend(req, body: 'TServer put request');
  });
  TServer.instance.delete('/', (req) {
    tServerSend(req, body: 'TServer delete request');
  });
  //send file
  TServer.instance.get('/download', (req) {
    tServerSendFile(req, 'your file path');
  });

  //stream video
  TServer.instance.get('/stream', (req) async {
    final path = req.uri.queryParameters['path'] ?? '';
    //path မရှိရင်
    if (path.isEmpty) {
      tServerSend(req, body: '`path` မရှိပါ', httpStatus: HttpStatus.notFound);
      return;
    }
    //send stream
    await tServerStreamVideo(req, path);
  });

  //websocket
  TServer.instance.onSocket('/ws', (http, socket) {
    socket.add('hello from Server');
    socket.listen(
      //listen on client
      (data) {
        //send client -> client ကိုပြန်ပို့မယ်
        socket.add('from Server - your text -> `$data`');
        //client text
        print(data);
      },
      //client disconneted
      onDone: () {
        print('client disconncted');
      },
      //on error
      onError: (err) {
        print('socket error ${err.toString()}');
      },
    );
  });
}

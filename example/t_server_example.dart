import 'dart:io';

import 'package:t_server/t_server.dart';

void main() {
  TServer.instance.startServer(port: 3000);
  print('server is running on port 3000');

  //http request
  TServer.instance.get('/', (req) {
    TServer.send(req, body: 'hello TServer');
  });
  TServer.instance.post('/', (req) {
    TServer.send(req, body: 'TServer post request');
  });
  TServer.instance.put('/', (req) {
    TServer.send(req, body: 'TServer put request');
  });
  TServer.instance.delete('/', (req) {
    TServer.send(req, body: 'TServer delete request');
  });
  //send file
  TServer.instance.get('/download', (req) {
    // TServer.sendFile(req, 'your file path');
    TServer.sendFile(req, 'your file path');
  });

  //stream video
  TServer.instance.get('/stream', (req) async {
    final path = req.uri.queryParameters['path'] ?? '';
    //path မရှိရင်
    if (path.isEmpty) {
      TServer.send(req, body: '`path` မရှိပါ', httpStatus: HttpStatus.notFound);
      return;
    }
    //send stream
    await TServer.sendStreamVideo(req, path);
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

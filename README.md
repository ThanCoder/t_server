## TServer Dart Core Lib

## Supported

- http
- websocket

## Example

```dart
TServer.instance.startServer(port: 3000);
  print('server is running on port http://localhost:3000');

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
  //send json
  TServer.instance.get('/json', (req) {
    TServer.sendJson(req, body: jsonEncode({'res': 'hello'}));
  });
  TServer.instance.get('/image', (req) {
    TServer.sendImage(
      req,
      '/home/thancoder/Pictures/DALL·E 2024-11-30 04.53.03 .webp',
    );
  });
  TServer.instance.get('/video', (req) {
    TServer.sendVideo(
      req,
      '/home/thancoder/Videos/AMAZING DRIFTING SKILLS.mp4',
    );
  });

  TServer.instance.get('/file', (req) {
    TServer.sendFile(
      req,
      '/home/thancoder/Pictures/DALL·E 2024-11-30 04.53.03 .webp',
    );
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
```

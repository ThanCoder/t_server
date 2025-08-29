# TServer Dart Core Lib

## Supported

- http
- websocket

## Example

```dart
//init
TServer.instance.startListen(port: 8080);
//dispose
TServer.instance.stop(force: true);

TServer.instance.get('/', (req) {
  req.sendHtml('<h1>Hello TServer</h1>');
});
TServer.instance.get('/text', (req) {
  req.sendText('Hello TServer text');
});
TServer.instance.get('/json', (req) {
  req.sendJson(jsonEncode({'res': 'hello TServer json result'}));
});
TServer.instance.get('/download', (req) {
  // download/?path=[path]
  final path = req.getQueryParameters['path'] ?? '';
  req.sendFile(path);
});
TServer.instance.get('/stream', (req) {
  // download/?path=[path]
  final path = req.getQueryParameters['path'] ?? '';
  req.sendVideoStream(path);
});
// post method
TServer.instance.post('/post', (req) async {
  final body = await req.getBody();
  debugPrint(body.toString());
});
TServer.instance.put('/put', (req) async {
  final body = await req.getBody();
  debugPrint(body.toString());
});
TServer.instance.delete('/delete', (req) async {
  // delete?id=[id]
  final id = req.getQueryParameters['id'] ?? '';
  debugPrint(id);
});
```

## WebSocket

```dart
TServer.instance.onSocketListen((req, socket) {
  // client connected
  debugPrint('client connected');
  socket.listen(
    (data) {
      // client send data
      debugPrint('client message: [$data]');
    },
    onDone: () {
      // client leave
      debugPrint('client leave');
    },
  );
});
```

## Upload File From Client User

```dart
// client file upload
TServer.instance.post('/upload', (req) {
  req.uploadFile('save dir path');
});

//from client user
final formData = FormData.fromMap({
  'file': await MultipartFile.fromFile(path, filename: path.getName()),
});

await dio.post(
  "${widget.hostUrl}/upload",
  data: formData,
  options: Options(
    contentType: 'multipart/form-data',
    sendTimeout: Duration(
      hours: 1,
    ), // 2GB ဆိုတာကြောင့် timeout ကြီးကြီးထား
    receiveTimeout: Duration(hours: 1),
  ),
  onSendProgress: (sent, total) {
  },
)

```

# TServer Dart Core Lib

## Supported

- http
- websocket

## Example

```dart
final server = TServer();
final router = TRouter();
final socketRouter = TSocketRouter();

router.get('/', (req) {
  req.sendHtml('<h1>index Page</h1>');
});

router.get('/index/:name', (req) {
  req.sendHtml('<h1>index Page Name: ${req.getParams['name']}</h1>');
});

// HTTP GET route with path param
router.get('/download/:name', (req) {
  final name = req.getParams['name'];
  req.sendText('Download file: $name');
});

router.get('/close-server', (req) async {
  await req.sendHtml('<h1>Closed Server</h1>');
  await server.stop(force: true);
});

// WebSocket route
socketRouter.add((req, socket) {
  socket.add('Hello WebSocket!');
});

server.setRouter(router);
server.setSocketRouter(socketRouter);

await server.start(
  'localhost',
  8080,
  onStartServer: () {
    print('Server Running On: http://localhost:${server.port}');
  },
);
```

## Server Get Body

```dart
// /download/:name
Map<String, dynamic> params =  req.getParams;
// /download?name=thancoder
Map<String, dynamic> query = req.getQueryParameters;
// client send body
final body = await req.getBody();
```

## Server HttpRequest

```dart
req.sendHtml('<h1>index Page Name: ${req.getParams['name']}</h1>');
req.send('dynamic');
req.sendHtml('[html]');
req.sendJson('[jsonStr]');
req.sendText('[text]');
req.sendFile('[filePath]');
req.sendVideoStream('[filePath]');
```

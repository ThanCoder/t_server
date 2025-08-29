import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:t_server/t_server.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TServerListener {
  @override
  void initState() {
    TServer.instance.addListener(this);
    super.initState();
    init();
  }

  @override
  void dispose() {
    TServer.instance.stop(force: true);
    TServer.instance.removeListener(this);
    super.dispose();
  }

  void init() async {
    TServer.instance.startListen(port: 8080);

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

    /*
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
          */
    // client file upload
    TServer.instance.post('/upload', (req) {
      req.uploadFile('save dir path');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Placeholder(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            TServer.instance.stop();
          },
        ),
      ),
    );
  }

  @override
  void onServerStatusChanged(bool isServerRunning) {
    print('isServerRunning: $isServerRunning');
  }
}

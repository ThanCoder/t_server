import 'dart:io';

import 'package:mime/mime.dart';

import 'index.dart';

///
/// server lib
///
class TServer {
  ///
  /// singleton pattern
  ///
  static final TServer instance = TServer._();
  TServer._();

  ///
  /// singleton pattern
  ///
  factory TServer() => instance;

  late HttpServer _httpServer;

  ///
  /// all error listener
  ///
  void Function(String msg)? onError;
  final List<TServerHttpListener> _httpListener = [];
  final List<TServerSocketListener> _webSocktetlistenerList = [];

  ///
  /// start server
  ///
  Future<TServer> startServer({int port = 3300, bool shared = true}) async {
    try {
      //all clear
      _httpListener.clear();
      _webSocktetlistenerList.clear();

      _httpServer = await HttpServer.bind(
        InternetAddress.anyIPv4,
        port,
        shared: shared,
      );
      _httpServer.listen(_onListen);
    } catch (e) {
      if (onError != null) {
        onError!(e.toString());
      }
    }
    return this;
  }

  void _onListen(HttpRequest req) {
    final method = req.method;
    final url = req.uri.path;
    //for websocket
    if (WebSocketTransformer.isUpgradeRequest(req)) {
      _handleWebSocket(req);
      return;
    }
    //for http
    for (final listener in _httpListener) {
      if (listener.method == method && listener.url == url) {
        listener.onRequest(req);
        return;
      }
    }

    // No matching route, return 404 response
    req.response
      ..statusCode = HttpStatus.notFound
      ..write('404 Not Found')
      ..close();
  }

  ///
  ///listener for route GET Method
  ///
  void get(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'GET', onRequest: onReq),
    );
  }

  ///
  ///listener for route POST Method
  ///
  void post(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'POST', onRequest: onReq),
    );
  }

  ///
  ///listener for route DELETE Method
  ///
  void delete(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'DELETE', onRequest: onReq),
    );
  }

  ///
  ///listener for route PUT Method
  ///
  void put(String url, void Function(HttpRequest req) onReq) {
    _httpListener.add(
      TServerHttpListener(url: url, method: 'PUT', onRequest: onReq),
    );
  }
  /////////////////

  //websocket set listener
  void onSocket(
    String url,
    void Function(HttpRequest http, WebSocket socket) onListen,
  ) {
    final socketListener = TServerSocketListener(url: url, onListen: onListen);
    _webSocktetlistenerList.add(socketListener);
  }

  //web socket
  void _handleWebSocket(HttpRequest req) async {
    try {
      final url = req.uri.path;
      for (final listener in _webSocktetlistenerList) {
        if (listener.url == url) {
          final socket = await WebSocketTransformer.upgrade(req);
          listener.onListen(req, socket);
          return;
        }
      }

      // No matching route, return 404 response
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('404 Not Found')
        ..close();
    } catch (e) {
      if (onError != null) {
        onError!('websocket: ${e.toString()}');
      }
    }
  }

  ///
  ///stop server
  ///
  Future<void> stopServer({bool force = false}) async {
    try {
      _httpServer.close(force: force);
    } catch (e) {
      if (onError != null) {
        onError!(e.toString());
      }
    }
  }

  ///
  /// response send content
  ///
  static void send(
    HttpRequest req, {
    String body = 'new route',
    ContentType? contentType,
    int httpStatus = 200,
  }) {
    contentType ??= ContentType.text;
    req.response
      ..statusCode = httpStatus
      ..headers.contentType = contentType
      ..write(body)
      ..close();
  }

  ///
  /// response send json content
  ///
  static void sendJson(
    HttpRequest req, {
    required String body,
    int httpStatus = 200,
  }) {
    req.response
      ..statusCode = httpStatus
      ..headers.contentType = ContentType.json
      ..write(body)
      ..close();
  }

  ///
  /// response send html content
  ///
  static void sendHtml(
    HttpRequest req, {
    required String body,
    int httpStatus = 200,
  }) {
    req.response
      ..statusCode = httpStatus
      ..headers.contentType = ContentType.html
      ..write(body)
      ..close();
  }

  ///
  /// response send file
  /// contentTypeHeader == null -> auto mime type
  ///
  static Future<void> sendFile(
    HttpRequest req,
    String filePath, {
    String? contentTypeHeader,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('File Not Found')
        ..close();
      return;
    }
    if (contentTypeHeader == null) {
      final mime = lookupMimeType(filePath) ?? 'application/octet-stream';
      contentTypeHeader = mime;
    }

    //file ရှိရင်
    req.response.headers
      ..set(HttpHeaders.contentTypeHeader, contentTypeHeader)
      ..set(HttpHeaders.contentLengthHeader, file.lengthSync())
    // ..set(
    //   HttpHeaders.contentDisposition,
    //   'attachment;filename=${file.path.split('/').last}',
    // )
    ;
    //send file
    await file.openRead().pipe(req.response);
  }

  ///
  /// response send image
  ///
  static Future<void> sendImage(HttpRequest req, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('File Not Found')
        ..close();
      return;
    }
    //file ရှိရင်
    req.response.headers
      ..set(HttpHeaders.contentTypeHeader, 'image/png')
      ..set(HttpHeaders.contentLengthHeader, file.lengthSync());
    //send file
    await file.openRead().pipe(req.response);
  }

  ///
  /// response send video
  ///
  static Future<void> sendVideo(HttpRequest req, String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('File Not Found')
        ..close();
      return;
    }
    //file ရှိရင်
    req.response.headers
      ..set(HttpHeaders.contentTypeHeader, 'video/mp4')
      ..set(HttpHeaders.contentLengthHeader, file.lengthSync());
    //send file
    await file.openRead().pipe(req.response);
  }

  ///
  /// response send stream video
  ///
  static Future<void> sendStreamVideo(HttpRequest req, String videoPath) async {
    final File videoFile = File(videoPath);
    if (!await videoFile.exists()) {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('Video not found')
        ..close();
      return;
    }

    final int fileSize = await videoFile.length();
    final HttpResponse response = req.response;

    response.headers.set(HttpHeaders.contentTypeHeader, 'video/mp4');
    response.headers.set(HttpHeaders.acceptRangesHeader, 'bytes');
    response.headers.set('Connection', 'keep-alive'); // ✅ ADD THIS LINE

    final String? range = req.headers.value(HttpHeaders.rangeHeader);
    if (range != null && range.startsWith('bytes=')) {
      final parts = range.substring(6).split('-');
      final int start = int.parse(parts[0]);
      final int end =
          parts.length > 1 && parts[1].isNotEmpty
              ? int.parse(parts[1])
              : fileSize - 1;
      final int contentLength = end - start + 1;

      response
        ..statusCode = HttpStatus.partialContent
        ..headers.set(
          HttpHeaders.contentRangeHeader,
          'bytes $start-$end/$fileSize',
        )
        ..headers.set(HttpHeaders.contentLengthHeader, contentLength);

      await videoFile.openRead(start, end + 1).pipe(response);
    } else {
      response.headers.set(HttpHeaders.contentLengthHeader, fileSize);
      await videoFile.openRead().pipe(response);
    }
  }
}

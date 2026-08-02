import 'dart:async';
import 'dart:io';

import 'package:t_server/core/web_socket/message/t_websocket_message.dart';
import 'package:t_server/core/web_socket/message/websocket_message_handler.dart';

class TWebSocket {
  final WebSocket _raw;

  final String id;
  final String path;
  final HttpHeaders headers;

  String? userId;

  TWebSocket(
    this._raw, {
    required this.id,
    required this.path,
    required this.headers,
    this.userId,
  });

  Stream<dynamic> get messages => _raw;

  Future<void> get done => _raw.done;

  void send(dynamic message) {
    _raw.add(message);
  }

  Future<void> close([int? code, String? reason]) async {
    await _raw.close(code, reason);
  }

  // State
  final Map<String, dynamic> data = {};

  // Message handlers
  final Map<String, TWebSocketMessageHandler> _handlers = {};

  final List<TWebSocketCloseHandler> _closeHandlers = [];

  final List<TWebSocketErrorHandler> _errorHandlers = [];

  void on(String type, TWebSocketMessageHandler handler) {
    _handlers[type] = handler;
  }

  void onClose(TWebSocketCloseHandler handler) {
    _closeHandlers.add(handler);
  }

  void onError(TWebSocketErrorHandler handler) {
    _errorHandlers.add(handler);
  }

  // Connection
  bool _connected = false;

  bool get isConnected => _connected;

  // StreamSubscription<dynamic>? _subscription;

  void connect() {
    if (_connected) {
      return;
    }

    _connected = true;

    _raw.listen(
      (raw) async {
        if (raw is! String) {
          return;
        }

        try {
          final message = TWebSocketMessage.fromJson(raw);

          final handler = _handlers[message.type];

          if (handler == null) {
            return;
          }

          await handler(message);
        } catch (error) {
          for (final handler in _errorHandlers) {
            await handler(this, error);
          }
        }
      },
      onError: (Object error) async {
        for (final handler in _errorHandlers) {
          await handler(this, error);
        }
      },
      onDone: () async {
        _connected = false;
        // _subscription = null;

        for (final handler in _closeHandlers) {
          await handler(this);
        }
      },
      cancelOnError: false,
    );
  }
}

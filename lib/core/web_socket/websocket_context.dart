import 'dart:io';

import 'package:t_server/core/web_socket/message/t_websocket_message.dart';
import 'package:t_server/core/web_socket/message/websocket_message_handler.dart';
import 'package:t_server/core/web_socket/t_websocket.dart';
import 'package:t_server/core/web_socket/t_websocket_manager.dart';

class TWebSocketContext {
  final TWebSocket socket;
  final TWebSocketManager webSockets;

  TWebSocketContext({required this.socket, required this.webSockets});

  String get id => socket.id;

  String? get userId => socket.userId;

  String get path => socket.path;

  HttpHeaders get headers => socket.headers;

  Map<String, dynamic> get data => socket.data;

  // user id
  void setUserId(String id) {
    socket.userId = id;
  }

  // ─────────────────────────────────────
  // Message
  // ─────────────────────────────────────

  void on(String type, TWebSocketMessageHandler handler) {
    socket.on(type, handler);
  }

  void onClose(TWebSocketCloseHandler handler) {
    socket.onClose(handler);
  }

  void onError(TWebSocketErrorHandler handler) {
    socket.onError(handler);
  }

  // ─────────────────────────────────────
  // Send
  // ─────────────────────────────────────

  void send(dynamic message) {
    socket.send(message);
  }

  void sendMessage(TWebSocketMessage message) {
    socket.send(message.toJson());
  }

  // ─────────────────────────────────────
  // Broadcast
  // ─────────────────────────────────────

  void broadcast(dynamic message, {bool includeSelf = false}) {
    webSockets.broadcast(message, except: includeSelf ? null : id);
  }

  void broadcastMessage(TWebSocketMessage message, {bool includeSelf = false}) {
    broadcast(message.toJson(), includeSelf: includeSelf);
  }

  // ─────────────────────────────────────
  // User
  // ─────────────────────────────────────

  Future<void> sendTo(String socketId, dynamic message) {
    return webSockets.sendTo(socketId, message);
  }

  Future<void> sendToUser(String userId, dynamic message) {
    return webSockets.sendToUser(userId, message);
  }

  // ─────────────────────────────────────
  // Room
  // ─────────────────────────────────────
  /// Join Room
  void join(String room) {
    webSockets.joinRoom(id, room);
  }

  /// Leave Room
  void leave(String room) {
    webSockets.leaveRoom(id, room);
  }

  void broadcastToRoom(
    String room,
    dynamic message, {
    bool includeSelf = false,
  }) {
    webSockets.broadcastToRoom(room, message, except: includeSelf ? null : id);
  }

  void broadcastMessageToRoom(
    String room,
    TWebSocketMessage message, {
    bool includeSelf = false,
  }) {
    broadcastToRoom(room, message.toJson(), includeSelf: includeSelf);
  }
}

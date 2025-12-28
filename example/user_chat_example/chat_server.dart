import 'dart:io';

import 'user.dart';

class ChatServer {
  final Map<String, User> users = {};

  void addUser(String id, WebSocket socket) {
    users[id] = User(id, socket);
  }

  void removeUser(String id) {
    users.remove(id);
  }

  void sendTo(String from, String to, String message) {
    final target = users[to];
    if (target != null) {
      target.send("from $from: $message");
    }
  }
}

import 'dart:io';

class User {
  final String id;
  final WebSocket socket;

  User(this.id, this.socket);

  void send(String message) {
    socket.add(message);
  }
}

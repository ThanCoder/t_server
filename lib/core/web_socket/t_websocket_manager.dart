import 't_websocket.dart';

class TWebSocketManager {
  final Map<String, TWebSocket> _sockets = {};

  int get length => _sockets.length;
  int get count => length;

  Iterable<TWebSocket> get sockets => List.unmodifiable(_sockets.values);

  void add(TWebSocket socket) {
    _sockets[socket.id] = socket;
  }

  void remove(String socketId) {
    _sockets.remove(socketId);

    for (final entry in _rooms.entries) {
      entry.value.remove(socketId);
    }

    _rooms.removeWhere((_, members) => members.isEmpty);
  }

  TWebSocket? find(String id) {
    return _sockets[id];
  }

  void broadcast(dynamic message, {String? except}) {
    for (final socket in _sockets.values) {
      if (socket.id == except) {
        continue;
      }

      socket.send(message);
    }
  }

  Future<void> sendTo(String id, dynamic message) async {
    final socket = _sockets[id];

    if (socket == null) {
      return;
    }

    socket.send(message);
  }

  Future<void> sendToUser(String userId, dynamic message) async {
    for (final socket in _sockets.values) {
      if (socket.userId == userId) {
        socket.send(message);
      }
    }
  }

  //**************Room****************** */
  final Map<String, Set<String>> _rooms = {};

  Set<String> roomMembers(String room) {
    return Set.unmodifiable(_rooms[room] ?? const <String>{});
  }

  bool hasRoom(String room) {
    return _rooms.containsKey(room);
  }

  int roomCount(String room) {
    return _rooms[room]?.length ?? 0;
  }

  void joinRoom(String socketId, String room) {
    final members = _rooms.putIfAbsent(room, () => <String>{});

    members.add(socketId);
  }

  void leaveRoom(String socketId, String room) {
    final members = _rooms[room];

    if (members == null) {
      return;
    }

    members.remove(socketId);

    if (members.isEmpty) {
      _rooms.remove(room);
    }
  }

  /// except -> `socketId`
  void broadcastToRoom(String room, dynamic message, {String? except}) {
    final members = _rooms[room];

    if (members == null) {
      return;
    }

    for (final socketId in members) {
      if (socketId == except) {
        continue;
      }

      final socket = _sockets[socketId];

      if (socket == null) {
        continue;
      }

      socket.send(message);
    }
  }
}

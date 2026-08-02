import 'dart:convert';

class TWebSocketMessage {
  final String type;
  final Map<String, dynamic> data;

  const TWebSocketMessage({required this.type, required this.data});

  factory TWebSocketMessage.fromJson(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;

    return TWebSocketMessage(
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
    );
  }

  String toJson() {
    return jsonEncode({'type': type, 'data': data});
  }
}

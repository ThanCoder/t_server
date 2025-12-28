class ChatMessage {
  final String from;
  final String to;
  final String text;

  ChatMessage(this.from, this.to, this.text);

  Map<String, dynamic> toJson() => {'from': from, 'to': to, 'text': text};
}

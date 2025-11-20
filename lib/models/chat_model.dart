class ChatMessage {
  final String text;
  final String sender;
  final bool isMe;
  final bool isRead;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.isMe,
    required this.isRead,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json["pesan"],
      sender: json["sender"],
      isMe: json["sender"] == "Perawat",
      isRead: json["is_read"] == 1,
      timestamp: DateTime.parse(json["created_at"]),
    );
  }
}

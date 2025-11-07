class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String sender;
  final bool isRead;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.timestamp,
    required this.sender,
    required this.isRead,
  });
}
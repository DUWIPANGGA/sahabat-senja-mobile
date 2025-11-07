import 'package:sahabatsenja_app/models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final Map<String, List<ChatMessage>> _familyChats = {};

  // === CHAT KELUARGA ===
  List<ChatMessage> getFamilyChat(String familyName) {
    return _familyChats[familyName] ?? [];
  }

  void sendFamilyMessage(String familyName, String message, String sender) {
    final newMessage = ChatMessage(
      text: message,
      isMe: sender == 'Perawat',
      timestamp: DateTime.now(),
      sender: sender,
      isRead: sender == 'Perawat',
    );

    if (_familyChats[familyName] == null) {
      _familyChats[familyName] = [];
    }
    
    _familyChats[familyName]!.add(newMessage);
  }

  void markFamilyMessagesAsRead(String familyName) {
    final messages = _familyChats[familyName];
    if (messages != null) {
      for (var i = 0; i < messages.length; i++) {
        if (!messages[i].isMe && !messages[i].isRead) {
          // Create new message with isRead = true
          final updatedMessage = ChatMessage(
            text: messages[i].text,
            isMe: messages[i].isMe,
            timestamp: messages[i].timestamp,
            sender: messages[i].sender,
            isRead: true,
          );
          messages[i] = updatedMessage;
        }
      }
    }
  }

  // Get last message for preview
  ChatMessage? getLastFamilyMessage(String familyName) {
    final messages = _familyChats[familyName];
    if (messages == null || messages.isEmpty) return null;
    
    // Sort by timestamp descending and get first
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages.first;
  }

  int getUnreadFamilyCount(String familyName) {
    final messages = _familyChats[familyName];
    if (messages == null) return 0;
    
    return messages.where((msg) => !msg.isMe && !msg.isRead).length;
  }

  // Get all family names that have chats
  List<String> getFamilyChatsList() {
    return _familyChats.keys.toList();
  }

  // Add demo data for testing
  void initializeDemoData() {
    // Demo data untuk chat keluarga
    if (_familyChats['Keluarga Rina'] == null) {
      _familyChats['Keluarga Rina'] = [
        ChatMessage(
          text: 'Selamat pagi bu, apakah obat untuk ibu sudah diberikan?',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          sender: 'Keluarga Rina',
          isRead: true,
        ),
        ChatMessage(
          text: 'Sudah bu, semua obat sudah diminum sesuai jadwal',
          isMe: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          sender: 'Perawat',
          isRead: true,
        ),
      ];
    }

    if (_familyChats['Keluarga Andi'] == null) {
      _familyChats['Keluarga Andi'] = [
        ChatMessage(
          text: 'Pak Budi mau kontrol besok jam 10 pagi',
          isMe: false,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          sender: 'Keluarga Andi',
          isRead: false,
        ),
      ];
    }
  }
}
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/halaman/services/chat_service.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    // Load messages from service atau gunakan demo messages
    setState(() {
      _messages.addAll(_getConsultationChat());
    });
  }

  // Method pengganti untuk getConsultationChat
  List<ChatMessage> _getConsultationChat() {
    return [
      ChatMessage(
        text: 'Halo, bagaimana kondisi Ibu hari ini?',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        sender: 'Perawat Anita',
        isRead: true,
      ),
      ChatMessage(
        text: 'Alhamdulillah baik, Bu. Ibu sudah makan pagi dengan lahap',
        isMe: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        sender: 'Anda',
        isRead: true,
      ),
      ChatMessage(
        text:
            'Bagus sekali! Nanti siang ada kegiatan senam ringan untuk lansia',
        isMe: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        sender: 'Perawat Anita',
        isRead: true,
      ),
    ];
  }

  // Method pengganti untuk sendConsultationMessage
  void _sendConsultationMessage(String message, String sender) {
    // Simpan ke local list atau service
    final newMessage = ChatMessage(
      text: message,
      isMe: sender == 'Keluarga',
      timestamp: DateTime.now(),
      sender: 'Anda',
      isRead: true,
    );

    // Tambahkan ke list messages
    setState(() {
      _messages.add(newMessage);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final message = _messageController.text.trim();

      // Send message via custom method
      _sendConsultationMessage(message, 'Keluarga');

      _messageController.clear();

      // Auto scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDay == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  final List<Map<String, dynamic>> _nurses = [
    {'name': 'Perawat Anita', 'online': true, 'role': 'Perawat Utama'},
    {'name': 'Perawat Budi', 'online': false, 'role': 'Perawat Pendamping'},
    {'name': 'Dokter Sari', 'online': true, 'role': 'Dokter Umum'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi'),
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              _showComingSoonDialog(context, 'Video Call');
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              _showComingSoonDialog(context, 'Voice Call');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Nurses List - FIXED HEIGHT
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.grey[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tim Medis Tersedia:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _nurses.length,
                    itemBuilder: (context, index) {
                      final nurse = _nurses[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.brown[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.brown[700],
                                    size: 24,
                                  ),
                                ),
                                if (nurse['online'] == true)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.fromBorderSide(
                                          BorderSide(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: 60,
                              child: Text(
                                nurse['name']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              nurse['role']!,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: _messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada percakapan',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFFFF9F5),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                    onPressed: () {
                      _showComingSoonDialog(context, 'Attachment');
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ketik pesan...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C6223),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fitur Segera Hadir'),
        content: Text('Fitur $feature akan segera tersedia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    bool isMe = message.isMe;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.brown[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.brown[700],
                size: 18,
              ),
            ),
          if (!isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: Text(
                      message.sender,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF9C6223) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (isMe) const SizedBox(width: 4),
                      if (isMe)
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 12,
                          color:
                              message.isRead ? Colors.blue : Colors.grey[400],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.brown[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.brown[700],
                size: 18,
              ),
            ),
        ],
      ),
    );
  }
}

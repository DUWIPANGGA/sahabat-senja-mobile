import 'package:flutter/material.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Halo, bagaimana kondisi Ibu hari ini?',
      'isMe': false,
      'time': '10:00',
      'sender': 'Perawat Anita',
      'isRead': true,
    },
    {
      'text': 'Alhamdulillah baik, Bu. Ibu sudah makan pagi dengan lahap',
      'isMe': true,
      'time': '10:05',
      'sender': 'Anda',
      'isRead': true,
    },
    {
      'text': 'Bagus sekali! Nanti siang ada kegiatan senam ringan untuk lansia',
      'isMe': false,
      'time': '10:10',
      'sender': 'Perawat Anita',
      'isRead': true,
    },
    {
      'text': 'Apakah saya bisa video call untuk melihat kondisi Ibu?',
      'isMe': true,
      'time': '10:15',
      'sender': 'Anda',
      'isRead': false,
    },
  ];

  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _nurses = [
    {'name': 'Perawat Anita', 'online': true, 'role': 'Perawat Utama'},
    {'name': 'Perawat Budi', 'online': false, 'role': 'Perawat Pendamping'},
    {'name': 'Dokter Sari', 'online': true, 'role': 'Dokter Umum'},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _messageController.text,
          'isMe': true,
          'time': 'Sekarang',
          'sender': 'Anda',
          'isRead': false,
        });
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konsultasi'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Color(0xFFFFF9F5),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {
              // Video call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Voice call functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Nurses List
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
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
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.brown[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.brown[700],
                              size: 30,
                            ),
                          ),
                          if (nurse['online']!)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nurse['name']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        nurse['role']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Chat Messages dengan bubble
          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                reverse: false,
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
            padding: const EdgeInsets.all(16),
            color: Color(0xFFFFF9F5),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                  onPressed: () {},
                ),
                
                // Text input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ),
                
                // Send button
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.brown[700],
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isMe = message['isMe']!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
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
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 4),
                    child: Text(
                      message['sender']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.brown[700] : Color(0xFFFFF9F5),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text']!,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['time']!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (isMe) const SizedBox(width: 4),
                      if (isMe)
                        Icon(
                          message['isRead']! ? Icons.done_all : Icons.done,
                          size: 12,
                          color: message['isRead']! ? Colors.blue : Colors.grey,
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
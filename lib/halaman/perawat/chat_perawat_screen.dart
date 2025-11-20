import 'package:flutter/material.dart';
import '../services/chat_service.dart'; // sesuaikan path

class ChatPerawatScreen extends StatefulWidget {
  final int datalansiaId;
  final String namaKeluarga;

  const ChatPerawatScreen({
    super.key,
    required this.datalansiaId,
    required this.namaKeluarga,
  });

  @override
  State<ChatPerawatScreen> createState() => _ChatPerawatScreenState();
}

class _ChatPerawatScreenState extends State<ChatPerawatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService service = ChatService();

  List chats = [];

  @override
  void initState() {
    super.initState();
    loadChat();
  }

  Future<void> loadChat() async {
    try {
      final result = await service.getMessages(widget.datalansiaId);
      chats = result;
    } catch (e) {
      chats = [];
    }
    setState(() {});

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final ok = await service.sendMessage(
      datalansiaId: widget.datalansiaId,
      sender: "perawat",
      pesan: text,
    );

    if (ok) {
      _controller.clear();
      await loadChat();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim pesan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat: ${widget.namaKeluarga}"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: chats.isEmpty
                ? const Center(child: Text('Belum ada pesan'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final msg = chats[index];
                      final bool isMe = (msg["sender"]?.toString().toLowerCase() ?? "") == "perawat";

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.teal[300] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg["pesan"]?.toString() ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ketik pesan...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

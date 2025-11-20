import 'package:flutter/material.dart';
import '../services/chat_service.dart'; // sesuaikan path jika perlu

class ChatKeluargaScreen extends StatefulWidget {
  final int datalansiaId;
  final String namaPerawat;
  final String namaKeluarga;

  const ChatKeluargaScreen({
    super.key,
    required this.datalansiaId,
    required this.namaPerawat,
    required this.namaKeluarga,
  });

  @override
  State<ChatKeluargaScreen> createState() => _ChatKeluargaScreenState();
}

class _ChatKeluargaScreenState extends State<ChatKeluargaScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService service = ChatService();

  List chats = []; // List of messages from API

  @override
  void initState() {
    super.initState();
    loadChat();
  }

  Future<void> loadChat() async {
    try {
      final result = await service.getMessages(widget.datalansiaId);
      chats = result; // asumsi result adalah List dari JSON API
    } catch (e) {
      chats = [];
      // optional: tampilkan error
    }
    setState(() {});

    // Auto scroll ke bawah
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Kirim ke API
    final ok = await service.sendMessage(
      datalansiaId: widget.datalansiaId,
      sender: "keluarga",
      pesan: text,
    );

    if (ok) {
      _controller.clear();
      await loadChat();
    } else {
      // optional: notifikasi gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim pesan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat dengan ${widget.namaPerawat}"),
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
                      final bool isMe = (msg["sender"]?.toString().toLowerCase() ?? "") == "keluarga";

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

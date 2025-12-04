// screens/chat/chat_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/halaman/chat/message_bubble.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late ChatProvider _chatProvider;
  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadMessages();
    
    // Setup polling untuk real-time
    _startPolling();
    
    // Setup scroll listener
    _scrollController.addListener(_scrollListener);
    
    // Auto-scroll ke bawah saat keyboard muncul
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });
  }

  Future<void> _loadMessages({bool loadMore = false}) async {
    try {
      await _chatProvider.loadMessages(widget.userId, loadMore: loadMore);
      
      if (!loadMore) {
        // Scroll ke bawah setelah loading pesan baru
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startPolling() {
    if (_isPolling) return;
    
    _isPolling = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        // Load conversation untuk update unread count
        await _chatProvider.loadConversations();
        
        // Cek pesan baru untuk user ini
        final currentMessageCount = _chatProvider.getMessagesForUser(widget.userId).length;
        await _loadMessages();
        final newMessageCount = _chatProvider.getMessagesForUser(widget.userId).length;
        
        // Jika ada pesan baru, scroll ke bawah
        if (newMessageCount > currentMessageCount) {
          _scrollToBottom();
        }
      } catch (e) {
        print('Polling error: $e');
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  void _scrollListener() {
    // Load more messages saat scroll ke atas
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_chatProvider.hasMoreMessages(widget.userId) && !_isLoadingMore) {
        _loadMoreMessages();
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    setState(() => _isLoadingMore = true);
    await _loadMessages(loadMore: true);
    setState(() => _isLoadingMore = false);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    try {
      _messageController.clear();
      await _chatProvider.sendTextMessage(
        receiverId: widget.userId,
        message: message,
      );
      
      // Scroll ke bawah setelah mengirim
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.green),
                title: const Text('Gambar'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file, color: Colors.blue),
                title: const Text('File'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.purple),
                title: const Text('Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    // Implement image picker
    // final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   await _chatProvider.sendImageMessage(
    //     receiverId: widget.userId,
    //     imageFile: File(image.path),
    //   );
    // }
  }

  Future<void> _pickFile() async {
    // Implement file picker
    // final result = await FilePicker.platform.pickFiles();
    // if (result != null) {
    //   final file = File(result.files.single.path!);
    //   await _chatProvider.sendFileMessage(
    //     receiverId: widget.userId,
    //     file: file,
    //   );
    // }
  }

  Future<void> _takePhoto() async {
    // Implement camera
    // final image = await ImagePicker().pickImage(source: ImageSource.camera);
    // if (image != null) {
    //   await _chatProvider.sendImageMessage(
    //     receiverId: widget.userId,
    //     imageFile: File(image.path),
    //   );
    // }
  }

  void _deleteMessage(int messageId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesan'),
        content: const Text('Apakah Anda yakin ingin menghapus pesan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatProvider.deleteMessage(messageId, widget.userId);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopPolling();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal[100],
              child: Icon(
                Icons.person,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    final unread = provider.getUnreadCountForUser(widget.userId);
                    return Text(
                      unread > 0 ? '$unread pesan belum dibaca' : 'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: unread > 0 ? Colors.teal : Colors.green,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // Implement call functionality
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Hapus Percakapan'),
                ),
              ),
              const PopupMenuItem(
                value: 'mark_read',
                child: ListTile(
                  leading: Icon(Icons.mark_email_read, color: Colors.blue),
                  title: Text('Tandai Semua Dibaca'),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'clear') {
                _confirmClearChat();
              } else if (value == 'mark_read') {
                _chatProvider.markMessagesAsRead(widget.userId);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                final messages = provider.getMessagesForUser(widget.userId);
                
                if (provider.isLoading && messages.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isLoadingMore && index == messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    
                    final messageIndex = messages.length - index - 1;
                    if (messageIndex < 0) return const SizedBox.shrink();
                    
                    final message = messages[messageIndex];
                    return MessageBubble(
                      message: message,
                      onLongPress: () => _deleteMessage(message.id!),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: Colors.teal[700]),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Ketik pesan...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  if (_messageController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.teal[700]),
                      onPressed: _sendMessage,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Percakapan'),
        content: const Text('Apakah Anda yakin ingin menghapus semua pesan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _chatProvider.clearConversation(widget.userId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Percakapan berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
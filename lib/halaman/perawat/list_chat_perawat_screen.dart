// screens/chat/list_chat_perawat_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/halaman/chat/chat_screen.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';

class ListChatPerawatScreen extends StatefulWidget {
  const ListChatPerawatScreen({super.key});

  @override
  State<ListChatPerawatScreen> createState() => _ListChatPerawatScreenState();
}

class _ListChatPerawatScreenState extends State<ListChatPerawatScreen> 
    with WidgetsBindingObserver {
  late ChatProvider _chatProvider;
  Timer? _pollingTimer;
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();
  List<ChatConversation> _filteredConversations = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadInitialData();
    _startPolling();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _restartPolling();
      _loadInitialData();
    } else if (state == AppLifecycleState.paused) {
      _stopPolling();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await _chatProvider.loadConversations();
      _filteredConversations = _chatProvider.conversations
          .where((conv) => conv.user['role'] == 'keluarga')
          .toList();
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.toString());
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadInitialData();
    setState(() => _isRefreshing = false);
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        await _loadInitialData();
        setState(() {});
      } else {
        timer.cancel();
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void _restartPolling() {
    _stopPolling();
    _startPolling();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _filterConversations(String query) {
    if (query.isEmpty) {
      _filteredConversations = _chatProvider.conversations
          .where((conv) => conv.user['role'] == 'keluarga')
          .toList();
    } else {
      _filteredConversations = _chatProvider.conversations
          .where((conv) {
            final user = conv.user;
            final name = user['name']?.toString().toLowerCase() ?? '';
            final role = user['role']?.toString() ?? '';
            return role == 'keluarga' && 
                  (name.contains(query.toLowerCase()) ||
                   conv.lastMessage!['message']!.toString().toLowerCase().contains(query.toLowerCase()) ?? false);
          })
          .toList();
    }
    setState(() {});
  }

  void _openChatWithKeluarga(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          userId: user['id'],
          userName: user['name'] ?? 'Keluarga',
          userRole: user['role'] ?? 'keluarga',
        ),
      ),
    ).then((_) {
      // Refresh setelah kembali dari chat
      _refreshData();
    });
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.teal[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari nama keluarga...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey[600]),
                          ),
                          autofocus: true,
                          onChanged: (value) {
                            setModalState(() {});
                            _filterConversations(value);
                          },
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setModalState(() {
                              _searchController.clear();
                              _filterConversations('');
                            });
                          },
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, provider, child) {
                      if (_filteredConversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'Belum ada percakapan'
                                    : 'Tidak ditemukan',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: _filteredConversations.length,
                        itemBuilder: (context, index) {
                          final conversation = _filteredConversations[index];
                          final user = conversation.user;
                          return _buildConversationTile(conversation, user);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      _searchController.clear();
      _filterConversations('');
    });
  }

  Widget _buildConversationTile(
    ChatConversation conversation,
    Map<String, dynamic> user,
  ) {
    final lastMessage = conversation.lastMessage;
    final isUnread = conversation.unreadCount > 0;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: Text(
            user['name']?.toString().substring(0, 1).toUpperCase() ?? 'K',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.teal[700],
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user['name'] ?? 'Keluarga',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                  color: isUnread ? Colors.teal[800] : Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (conversation.lastMessageTime != null)
              Text(
                _formatMessageTime(conversation.lastMessageTime!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastMessage != null && lastMessage['message'] != null)
              Text(
                lastMessage['message']!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: isUnread ? Colors.teal[700] : Colors.grey[600],
                  fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
          ],
        ),
        trailing: isUnread
            ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    conversation.unreadCount > 9
                        ? '9+'
                        : conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : null,
        onTap: () => _openChatWithKeluarga(user),
        onLongPress: () => _showConversationOptions(context, user),
      ),
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (time.isAfter(today)) {
      return DateFormat('HH:mm').format(time);
    } else if (time.isAfter(yesterday)) {
      return 'Kemarin';
    } else {
      return DateFormat('dd/MM/yyyy').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat Keluarga',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Cari percakapan',
          ),
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              final unreadCount = provider.totalUnreadCount;
              if (unreadCount > 0) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () => _showUnreadNotifications(context, provider),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {},
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && _filteredConversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text(
                    'Memuat percakapan...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null && _filteredConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _refreshData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (_filteredConversations.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.teal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.chat_outlined,
                            size: 60,
                            color: Colors.teal[400],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Belum ada percakapan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Mulai percakapan dengan keluarga untuk membahas perawatan lansia',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _showSearchDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            elevation: 2,
                          ),
                          icon: const Icon(Icons.search, size: 20),
                          label: const Text('Cari Keluarga'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.teal,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredConversations.length,
              itemBuilder: (context, index) {
                final conversation = _filteredConversations[index];
                final user = conversation.user;
                return _buildConversationTile(conversation, user);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSearchDialog,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Chat Baru'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showConversationOptions(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: const Text(
                  'Opsi Percakapan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 0),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mark_email_read, color: Colors.blue),
                ),
                title: const Text('Tandai Semua Dibaca'),
                onTap: () {
                  Navigator.pop(context);
                  _markAllAsRead(user['id'], user['name']);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Hapus Percakapan'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteConversation(user['id'], user['name']);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteConversation(int userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Percakapan'),
        content: Text('Hapus percakapan dengan $userName?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteConversation(userId);
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

  Future<void> _deleteConversation(int userId) async {
    try {
      await _chatProvider.clearConversation(userId);
      await _refreshData();
      _showSuccessSnackbar('Percakapan berhasil dihapus');
    } catch (e) {
      _showErrorSnackbar('Gagal menghapus percakapan: ${e.toString()}');
    }
  }

  Future<void> _markAllAsRead(int userId, String userName) async {
    try {
      await _chatProvider.markMessagesAsRead(userId);
      await _refreshData();
      _showSuccessSnackbar('Percakapan dengan $userName ditandai sebagai dibaca');
    } catch (e) {
      _showErrorSnackbar('Gagal menandai pesan: ${e.toString()}');
    }
  }

  void _showUnreadNotifications(BuildContext context, ChatProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.teal),
            SizedBox(width: 8),
            Text('Pesan Belum Dibaca'),
          ],
        ),
        content: provider.totalUnreadCount > 0
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: _filteredConversations
                    .where((conv) => conv.unreadCount > 0)
                    .map((conv) {
                      final user = conv.user;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal.withOpacity(0.1),
                          child: Text(
                            user['name']?.toString().substring(0, 1).toUpperCase() ?? 'K',
                            style: TextStyle(color: Colors.teal[700]),
                          ),
                        ),
                        title: Text(user['name'] ?? 'Keluarga'),
                        subtitle: Text(
                          '${conv.unreadCount} pesan baru',
                          style: TextStyle(
                            color: Colors.teal[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _openChatWithKeluarga(user);
                        },
                      );
                    })
                    .toList(),
              )
            : const Text('Tidak ada pesan belum dibaca'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
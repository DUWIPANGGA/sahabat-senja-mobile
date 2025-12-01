import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/halaman/chat/chat_screen.dart';
import 'package:sahabatsenja_app/providers/chat_provider.dart';
class ChatListKeluargaScreen extends StatefulWidget {
  final int userId;
  final String namaKeluarga;

  const ChatListKeluargaScreen({
    super.key,
    required this.userId,
    required this.namaKeluarga,
  });

  @override
  State<ChatListKeluargaScreen> createState() => _ChatListKeluargaScreenState();
}

class _ChatListKeluargaScreenState extends State<ChatListKeluargaScreen> {
  late ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadConversations();
    
    // Polling setiap 10 detik
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 10));
        if (mounted) {
          await _loadConversations();
        }
        return mounted;
      });
    });
  }

  Future<void> _loadConversations() async {
    try {
      await _chatProvider.loadConversations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konsultasi dengan Perawat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF9C6223),
        elevation: 0,
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (provider.totalUnreadCount > 0) {
                return Badge(
                  label: Text(provider.totalUnreadCount.toString()),
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {},
                  ),
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
          if (provider.isLoading && provider.conversations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C6223)),
            );
          }

          if (provider.error != null && provider.conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadConversations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C6223),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // Filter conversations untuk keluarga (hanya perawat)
          final perawatConversations = provider.conversations.where((conv) {
            return conv.user['role'] == 'perawat';
          }).toList();

          if (perawatConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada percakapan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mulai konsultasi dengan perawat',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _startNewChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C6223),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Mulai Chat Baru'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadConversations,
            color: const Color(0xFF9C6223),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: perawatConversations.length,
              itemBuilder: (context, index) {
                final conversation = perawatConversations[index];
                final user = conversation.user;
                final lastMessage = conversation.lastMessage;
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF9C6223).withOpacity(0.1),
                      child: Icon(
                        Icons.medical_services,
                        color: const Color(0xFF9C6223),
                      ),
                    ),
                    title: Text(
                      user['name'] ?? 'Perawat',
                      style: TextStyle(
                        fontWeight: conversation.unreadCount > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: conversation.unreadCount > 0
                            ? const Color(0xFF9C6223)
                            : Colors.black87,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lastMessage != null && lastMessage['message'] != null)
                          Text(
                            lastMessage['message'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: conversation.unreadCount > 0
                                  ? const Color(0xFF9C6223)
                                  : Colors.grey[700],
                            ),
                          ),
                        if (lastMessage != null && lastMessage['time'] != null)
                          Text(
                            lastMessage['time'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    trailing: conversation.unreadCount > 0
                        ? Badge(
                            label: Text(conversation.unreadCount.toString()),
                            backgroundColor: const Color(0xFF9C6223),
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            userId: user['id'],
                            userName: user['name'] ?? 'Perawat',
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      _showConversationOptions(user['id'], user['name']);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: const Color(0xFF9C6223),
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  void _startNewChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mulai Chat Baru'),
        content: const Text('Pilih perawat yang ingin diajak chat'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchPerawat();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
            ),
            child: const Text('Cari Perawat'),
          ),
        ],
      ),
    );
  }

  void _searchPerawat() {
    showSearch(
      context: context,
      delegate: _PerawatSearchDelegate(
        onPerawatSelected: (perawat) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                userId: perawat['id'],
                userName: perawat['name'] ?? 'Perawat',
              ),
            ),
          );
        },
      ),
    );
  }

  void _showConversationOptions(int userId, String perawatName) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Percakapan'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteConversation(userId, perawatName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.mark_email_read, color: Colors.blue),
                title: const Text('Tandai Semua Dibaca'),
                onTap: () {
                  Navigator.pop(context);
                  _markAllAsRead(userId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteConversation(int userId, String perawatName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Percakapan'),
        content: Text('Hapus percakapan dengan $perawatName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(userId);
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
  }

  Future<void> _markAllAsRead(int userId) async {
    try {
      await _chatProvider.markMessagesAsRead(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua pesan ditandai sebagai dibaca'),
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
  }
}

class _PerawatSearchDelegate extends SearchDelegate<String> {
  final Function(Map<String, dynamic>) onPerawatSelected;

  _PerawatSearchDelegate({required this.onPerawatSelected});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: chatProvider.searchUsers(query),
      builder: (context, snapshot) {
        if (query.isEmpty) {
          return const Center(
            child: Text('Cari nama perawat...'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF9C6223)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final perawatList = snapshot.data ?? [];

        if (perawatList.isEmpty) {
          return const Center(
            child: Text('Tidak ditemukan perawat'),
          );
        }

        return ListView.builder(
          itemCount: perawatList.length,
          itemBuilder: (context, index) {
            final perawat = perawatList[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF9C6223).withOpacity(0.1),
                child: Icon(
                  Icons.medical_services,
                  color: const Color(0xFF9C6223),
                ),
              ),
              title: Text(perawat['name'] ?? 'Perawat'),
              subtitle: const Text('Perawat'),
              onTap: () {
                onPerawatSelected(perawat);
                close(context, '');
              },
            );
          },
        );
      },
    );
  }
}
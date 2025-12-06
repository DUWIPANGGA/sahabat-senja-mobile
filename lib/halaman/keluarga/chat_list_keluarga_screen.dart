import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/halaman/chat/chat_screen.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
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
  Timer? _pollingTimer;
  List<Map<String, dynamic>> _availablePerawat = [];
  bool _isLoadingPerawat = false;
  String? _errorPerawat;

  @override
  void initState() {
    super.initState();
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _loadConversations();
    _loadAvailablePerawat();
    
    // Polling setiap 10 detik menggunakan Timer
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _loadConversations();
      }
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

  Future<void> _loadAvailablePerawat() async {
    try {
      setState(() {
        _isLoadingPerawat = true;
        _errorPerawat = null;
      });

      // Search with empty query to get all perawat
      final perawatList = await _chatProvider.searchUsers('');
      
      // Filter hanya perawat
      final filteredPerawat = perawatList.where((user) {
        return user['role'] == 'perawat';
      }).toList();

      setState(() {
        _availablePerawat = filteredPerawat;
        _isLoadingPerawat = false;
      });
    } catch (e) {
      setState(() {
        _errorPerawat = e.toString();
        _isLoadingPerawat = false;
      });
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
                  backgroundColor: Colors.red,
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

          return Column(
            children: [
              // Header untuk perawat tersedia
              if (_availablePerawat.isNotEmpty)
                _buildAvailablePerawatSection(),
              
              // List percakapan atau empty state
              Expanded(
                child: perawatConversations.isEmpty
                    ? _buildEmptyState(context)
                    : _buildConversationList(perawatConversations),
              ),
            ],
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

  Widget _buildAvailablePerawatSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.medical_services, color: Color(0xFF9C6223), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Perawat Tersedia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF9C6223),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _loadAvailablePerawat,
                color: const Color(0xFF9C6223),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoadingPerawat)
            const Center(
              child: CircularProgressIndicator(color: Color(0xFF9C6223)),
            )
          else if (_errorPerawat != null)
            Center(
              child: Text(
                'Error: $_errorPerawat',
                style: const TextStyle(color: Colors.red),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _availablePerawat.length,
                itemBuilder: (context, index) {
                  final perawat = _availablePerawat[index];
                  return _buildPerawatCard(perawat);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPerawatCard(Map<String, dynamic> perawat) {
    return GestureDetector(
      onTap: () {
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
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF9C6223).withOpacity(0.1),
              child: const Icon(
                Icons.medical_services,
                color: Color(0xFF9C6223),
                size: 30,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              perawat['name'] ?? 'Perawat',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: const Color(0xFF9C6223),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 100,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Belum ada percakapan dengan perawat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Mulai konsultasi dengan perawat untuk mendapatkan bantuan medis',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _startNewChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9C6223),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.add_comment, size: 20),
                  label: const Text('Mulai Konsultasi Baru'),
                ),
                const SizedBox(height: 20),
                if (_availablePerawat.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        'Atau pilih perawat di atas',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList(List<ChatConversation> conversations) {
    return RefreshIndicator(
      onRefresh: _loadConversations,
      color: const Color(0xFF9C6223),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final user = conversation.user;
          final lastMessage = conversation.lastMessage;
          
          // Format waktu
          String formattedTime = '';
          if (conversation.lastMessageTime != null) {
            final now = DateTime.now();
            final difference = now.difference(conversation.lastMessageTime!);
            
            if (difference.inDays == 0) {
              if (difference.inHours > 0) {
                formattedTime = '${difference.inHours} jam lalu';
              } else if (difference.inMinutes > 0) {
                formattedTime = '${difference.inMinutes} menit lalu';
              } else {
                formattedTime = 'Baru saja';
              }
            } else if (difference.inDays == 1) {
              formattedTime = 'Kemarin';
            } else {
              formattedTime = '${difference.inDays} hari lalu';
            }
          }
          
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
                child: const Icon(
                  Icons.medical_services,
                  color: Color(0xFF9C6223),
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
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
                  ),
                  if (formattedTime.isNotEmpty)
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
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
                  ],
                ),
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
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return _buildPerawatSelectionSheet();
      },
    );
  }

  Widget _buildPerawatSelectionSheet() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Color(0xFF9C6223)),
                const SizedBox(width: 10),
                const Text(
                  'Pilih Perawat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Pilih perawat untuk memulai konsultasi',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari perawat...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(15),
                ),
                onChanged: (value) {
                  _searchPerawatDialog(value);
                },
              ),
            ),
            const SizedBox(height: 20),
            
            // List perawat tersedia
            Expanded(
              child: _isLoadingPerawat
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF9C6223)))
                  : _errorPerawat != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error, color: Colors.red, size: 50),
                              const SizedBox(height: 10),
                              Text('Error: $_errorPerawat'),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _loadAvailablePerawat,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : _availablePerawat.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.medical_services, size: 60, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text('Tidak ada perawat tersedia'),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _availablePerawat.length,
                              itemBuilder: (context, index) {
                                final perawat = _availablePerawat[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF9C6223).withOpacity(0.1),
                                    child: const Icon(
                                      Icons.medical_services,
                                      color: Color(0xFF9C6223),
                                    ),
                                  ),
                                  title: Text(perawat['name'] ?? 'Perawat'),
                                  subtitle: Text(perawat['email'] ?? 'perawat'),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                  onTap: () {
                                    Navigator.pop(context);
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
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchPerawatDialog(String query) async {
    if (query.isEmpty) {
      await _loadAvailablePerawat();
      return;
    }

    try {
      setState(() {
        _isLoadingPerawat = true;
      });

      final searchResults = await _chatProvider.searchUsers(query);
      
      // Filter hanya perawat
      final filteredResults = searchResults.where((user) {
        return user['role'] == 'perawat';
      }).toList();

      setState(() {
        _availablePerawat = filteredResults;
        _isLoadingPerawat = false;
      });
    } catch (e) {
      setState(() {
        _errorPerawat = e.toString();
        _isLoadingPerawat = false;
      });
    }
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
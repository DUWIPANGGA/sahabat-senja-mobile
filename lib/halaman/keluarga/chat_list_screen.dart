// halaman/keluarga/chat_list_screen.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/halaman/keluarga/chat_detail_screen.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';
import 'package:sahabatsenja_app/services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<ChatConversation> _conversations = [];
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _allPerawat = [];
  bool _isLoading = true;
  bool _isSearching = false;
  bool _hasError = false;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _loadAllPerawat();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final conversations = await _chatService.getConversations();
      
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading conversations: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadAllPerawat() async {
    try {
      // Ambil semua perawat dengan search query kosong
      final perawatList = await _chatService.searchUsers('');
      
      // Filter hanya perawat
      final filteredPerawat = perawatList.where((user) {
        return user['role'] == 'perawat';
      }).toList();

      setState(() {
        _allPerawat = filteredPerawat;
      });
    } catch (e) {
      print('❌ Error loading perawat: $e');
    }
  }

  Future<void> _searchPerawat(String query) async {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce?.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
      });

      try {
        final results = await _chatService.searchUsers(query);
        
        // Filter hanya perawat
        final filteredResults = results.where((user) {
          return user['role'] == 'perawat';
        }).toList();

        setState(() {
          _searchResults = filteredResults;
          _isSearching = false;
        });
      } catch (e) {
        print('❌ Error searching perawat: $e');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _refreshData() async {
    await _loadConversations();
    await _loadAllPerawat();
  }

  void _startNewChat(Map<String, dynamic> perawat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          otherUserId: perawat['id'],
          otherUserName: perawat['name'] ?? 'Perawat',
          otherUserRole: 'Perawat',
          otherUserAvatar: perawat['avatar'],
        ),
      ),
    ).then((_) {
      // Refresh setelah kembali
      _refreshData();
    });
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) => _buildSearchBottomSheet(),
    );
  }

  Widget _buildSearchBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Header
              Row(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: Color(0xFF9C6223),
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Cari Perawat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari nama perawat...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        autofocus: true,
                        onChanged: (value) {
                          setModalState(() {});
                          _searchPerawat(value);
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setModalState(() {
                            _searchController.clear();
                            _searchResults = [];
                          });
                        },
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Search Results Title
              if (_searchController.text.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hasil Pencarian',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              
              const SizedBox(height: 10),
              
              // Search Results or All Perawat
              Expanded(
                child: _buildSearchResults(),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isEmpty) {
      return _buildAllPerawatList();
    }
    
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9C6223)),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ditemukan perawat dengan kata kunci:\n"${_searchController.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final perawat = _searchResults[index];
        return _buildPerawatItem(perawat);
      },
    );
  }

  Widget _buildAllPerawatList() {
    if (_allPerawat.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada perawat tersedia',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          'Semua Perawat Tersedia',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: _allPerawat.length,
            itemBuilder: (context, index) {
              final perawat = _allPerawat[index];
              return _buildPerawatItem(perawat);
            },
          ),
        ),
      ],
    );
  }

// Di _buildSearchBottomSheet() - perbaiki onTap untuk perawat
Widget _buildPerawatItem(Map<String, dynamic> perawat) {
  return ListTile(
    leading: CircleAvatar(
      child: perawat['avatar'] != null
          ? CircleAvatar(backgroundImage: NetworkImage(perawat['avatar']))
          : const Icon(Icons.medical_services, color: Color(0xFF9C6223)),
    ),
    title: Text(perawat['name'] ?? 'Perawat'),
    subtitle: Text(perawat['email'] ?? ''),
    trailing: const Icon(Icons.chat),
    onTap: () async {
      Navigator.pop(context); // Tutup bottom sheet
      
      try {
        // Cek dulu apakah sudah ada percakapan
        final existingConv = _conversations.firstWhere(
          (conv) => conv.user['id'] == perawat['id'],
          orElse: () => ChatConversation(
            user: {},
            unreadCount: 0,
            lastMessageTime: null,
          ),
        );

        if (existingConv.user.isNotEmpty) {
          // Jika sudah ada, langsung buka chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                otherUserId: perawat['id'],
                otherUserName: perawat['name'] ?? 'Perawat',
                otherUserRole: 'Perawat',
                otherUserAvatar: perawat['avatar'],
              ),
            ),
          );
        } else {
          // Jika belum ada, kirim pesan pertama
          final chatService = ChatService();
          await chatService.sendTextMessage(
            receiverId: perawat['id'],
            message: 'Halo, saya ingin berkonsultasi',
          );
          
          // Kemudian buka chat
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                otherUserId: perawat['id'],
                otherUserName: perawat['name'] ?? 'Perawat',
                otherUserRole: 'Perawat',
                otherUserAvatar: perawat['avatar'],
              ),
            ),
          ).then((_) => _refreshData());
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulai chat: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? _buildLoading()
          : _hasError
              ? _buildError()
              : _conversations.isEmpty
                  ? _buildEmptyState()
                  : _buildConversationList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        backgroundColor: const Color(0xFF9C6223),
        foregroundColor: Colors.white,
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF9C6223)),
          SizedBox(height: 16),
          Text(
            'Memuat percakapan...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6223),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_outlined,
              size: 70,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum ada percakapan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mulai percakapan dengan perawat',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _showSearchDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cari Perawat'),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFF9C6223),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          final user = conversation.user;
          final lastMessage = conversation.lastMessage;
          
          return _buildConversationItem(conversation, user, lastMessage);
        },
      ),
    );
  }

  Widget _buildConversationItem(
    ChatConversation conversation,
    Map<String, dynamic> user,
    Map<String, dynamic>? lastMessage,
  ) {
    final isUnread = conversation.unreadCount > 0;
    final userName = user['name'] ?? 'User';
    final userRole = user['role'] == 'perawat' ? 'Perawat' : 'Keluarga';
    final lastMessageText = lastMessage?['message'] ?? 'Mulai percakapan';
    final lastMessageTime = lastMessage?['time'] ?? '';
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              otherUserId: user['id'],
              otherUserName: userName,
              otherUserRole: userRole,
              otherUserAvatar: user['avatar'],
            ),
          ),
        ).then((_) {
          // Refresh setelah kembali
          _refreshData();
        });
      },
      onLongPress: () => _showConversationOptions(user['id'], userName),
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFE8F5E8) : Colors.white,
          border: const Border(
            bottom: BorderSide(
              color: Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF9C6223).withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF9C6223).withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: user['avatar'] != null
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user['avatar']),
                    )
                  : userRole == 'Perawat'
                      ? const Icon(
                          Icons.medical_services,
                          size: 28,
                          color: Color(0xFF9C6223),
                        )
                      : const Icon(
                          Icons.person,
                          size: 28,
                          color: Color(0xFF9C6223),
                        ),
            ),
            
            const SizedBox(width: 12),
            
            // Chat Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isUnread ? Colors.black : Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMessageTime.isNotEmpty) ...[
                        Text(
                          lastMessageTime,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    userRole,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF9C6223),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    lastMessageText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUnread ? Colors.black : Colors.grey[600],
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Unread badge
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    conversation.unreadCount > 9
                        ? '9+'
                        : conversation.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConversationOptions(int userId, String userName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
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
                  _confirmDeleteConversation(userId, userName);
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
      await _chatService.clearConversation(userId);
      
      // Hapus dari list lokal
      setState(() {
        _conversations.removeWhere((conv) => conv.user['id'] == userId);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Percakapan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAllAsRead(int userId) async {
    try {
      await _chatService.markAsRead(userId);
      
      // Update local data
      final index = _conversations.indexWhere((conv) => conv.user['id'] == userId);
      if (index != -1) {
        setState(() {
          _conversations[index] = ChatConversation(
            user: _conversations[index].user,
            lastMessage: _conversations[index].lastMessage,
            unreadCount: 0,
            lastMessageTime: _conversations[index].lastMessageTime,
          );
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua pesan ditandai sebagai dibaca'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sahabatsenja_app/models/notification_model.dart';
import 'package:sahabatsenja_app/providers/notification_provider.dart';
import 'package:sahabatsenja_app/services/notification_service.dart';
import 'package:sahabatsenja_app/utils/notification_helper.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _selectedFilter;

  // Filter options
  final List<Map<String, dynamic>> _filterOptions = [
    {'value': null, 'label': 'Semua', 'icon': Icons.all_inclusive},
    {'value': 'unread', 'label': 'Belum Dibaca', 'icon': Icons.markunread},
    {'value': 'read', 'label': 'Sudah Dibaca', 'icon': Icons.mark_email_read},
    {'value': 'urgent', 'label': 'Darurat', 'icon': Icons.warning},
    {'value': 'kesehatan', 'label': 'Kesehatan', 'icon': Icons.health_and_safety},
    {'value': 'iuran', 'label': 'Iuran', 'icon': Icons.payment},
    {'value': 'jadwal', 'label': 'Jadwal', 'icon': Icons.schedule},
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialNotifications();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialNotifications() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }
    
    try {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      await provider.loadNotifications(
        page: 1,
        filter: _selectedFilter,
      );
      
      if (mounted) {
        setState(() {
          _currentPage = 1;
          _hasMore = provider.notifications.length >= 20;
        });
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');
      _showErrorSnackbar('Gagal memuat notifikasi');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoading || !_hasMore) return;
    
    try {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      final nextPage = _currentPage + 1;
      
      final newNotifications = await provider.loadMoreNotifications(
        page: nextPage,
        filter: _selectedFilter,
      );
      
      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _hasMore = newNotifications.isNotEmpty;
        });
      }
    } catch (e) {
      print('❌ Error loading more notifications: $e');
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= 
          _scrollController.position.maxScrollExtent - 100) {
        _loadMoreNotifications();
      }
    });
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _loadInitialNotifications();
  }

  void _onFilterChanged(String? value) {
    setState(() {
      _selectedFilter = value;
    });
    _loadInitialNotifications();
  }

  Future<void> _markAsRead(String id) async {
    try {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      await provider.markAsRead(id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi ditandai sebagai dibaca'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Error marking as read: $e');
      _showErrorSnackbar('Gagal menandai notifikasi');
    }
  }

  Future<void> _markAllAsRead() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tandai Semua Sebagai Dibaca'),
        content: const Text('Apakah Anda yakin ingin menandai semua notifikasi sebagai sudah dibaca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<NotificationProvider>(context, listen: false);
                await provider.markAllAsRead();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${provider.readCount} notifikasi ditandai sebagai dibaca'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('❌ Error marking all as read: $e');
                _showErrorSnackbar('Gagal menandai semua notifikasi');
              }
            },
            child: const Text('Ya, Tandai Semua'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearReadNotifications() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi yang sudah dibaca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final provider = Provider.of<NotificationProvider>(context, listen: false);
                await provider.clearReadNotifications();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifikasi yang sudah dibaca telah dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                print('❌ Error clearing read notifications: $e');
                _showErrorSnackbar('Gagal menghapus notifikasi');
              }
            },
            child: const Text('Ya, Hapus'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    // Navigate to detail or show bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => NotificationDetailBottomSheet(
        notification: notification,
        onMarkAsRead: () => _markAsRead(notification.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Mark all as read
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount == 0) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Tandai semua sebagai dibaca',
                onPressed: _markAllAsRead,
              );
            },
          ),
          // Clear read notifications
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.readCount == 0) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Hapus notifikasi sudah dibaca',
                onPressed: _clearReadNotifications,
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;
          final unreadCount = provider.unreadCount;
          final urgentCount = provider.urgentCount;

          if (_isLoading && notifications.isEmpty) {
            return _buildLoading();
          }

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Filter chips
              _buildFilterChips(),
              
              // Stats summary
              _buildStatsSummary(unreadCount, urgentCount),
              
              // Notifications list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length + 1, // +1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return _buildLoadMoreIndicator();
                      }
                      return _buildNotificationItem(
                        notifications[index],
                        onTap: () => _showNotificationDetail(notifications[index]),
                        onMarkAsRead: () => _markAsRead(notifications[index].id),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF9C6223)),
          const SizedBox(height: 16),
          Text(
            'Memuat notifikasi...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini\nketika ada pembaruan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9C6223),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Refresh',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filterOptions.map((filter) {
            final isSelected = _selectedFilter == filter['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter['label']),
                selected: isSelected,
                onSelected: (selected) => _onFilterChanged(selected ? filter['value'] : null),
                backgroundColor: Colors.grey[100],
                selectedColor: const Color(0xFF9C6223).withOpacity(0.1),
                checkmarkColor: const Color(0xFF9C6223),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF9C6223) : Colors.grey[700],
                ),
                avatar: Icon(
                  filter['icon'],
                  size: 16,
                  color: isSelected ? const Color(0xFF9C6223) : Colors.grey[600],
                ),
                showCheckmark: true,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(int unreadCount, int urgentCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Total',
            value: unreadCount.toString(),
            icon: Icons.notifications,
            color: Colors.blue,
          ),
          _buildStatItem(
            label: 'Belum Dibaca',
            value: unreadCount.toString(),
            icon: Icons.markunread,
            color: Colors.orange,
          ),
          _buildStatItem(
            label: 'Darurat',
            value: urgentCount.toString(),
            icon: Icons.warning,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.2), width: 2),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return _hasMore
        ? Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9C6223),
                strokeWidth: 2,
              ),
            ),
          )
        : Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: Text(
                'Tidak ada notifikasi lagi',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          );
  }

Widget _buildNotificationItem(
  NotificationModel notification, {
  required VoidCallback onTap,
  required VoidCallback onMarkAsRead,
}) {
  final isUnread = !notification.isRead;
  final isUrgent = notification.isUrgent;
  final color = Color(notification.urgencyColor);
  final icon = NotificationHelper.getIcon(notification);

  // Warna untuk title berdasarkan status baca
  final titleColor = isUnread ? Colors.grey[800] : Colors.grey[500]; // Ubah warna untuk yang sudah dibaca
  final titleWeight = isUnread ? FontWeight.w600 : FontWeight.w500; // Tetap ada weight meski sudah dibaca

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border(
        left: BorderSide(
          color: isUrgent ? Colors.red : color,
          width: 4,
        ),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: titleWeight, // Gunakan variabel baru
                              color: titleColor, // Gunakan variabel baru
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          GestureDetector(
                            onTap: onMarkAsRead,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Message - Tetap terlihat untuk yang sudah dibaca
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600], // Warna lebih gelap
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Footer
                    Row(
                      children: [
                        // Time
                        Text(
                          notification.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600], // Warna lebih gelap
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Category
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            NotificationHelper.getCategoryName(notification.category),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[700], // Warna lebih gelap
                            ),
                          ),
                        ),
                        
                        if (isUrgent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning, size: 10, color: Colors.red),
                                const SizedBox(width: 2),
                                Text(
                                  'Darurat',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        if (notification.actionText != null) ...[
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9C6223).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notification.actionText!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9C6223),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600], // Warna lebih gelap
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// Bottom sheet untuk detail notifikasi
class NotificationDetailBottomSheet extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;

  const NotificationDetailBottomSheet({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(notification.urgencyColor);
    final icon = NotificationHelper.getIcon(notification);
    final formattedDate = DateFormat('EEEE, d MMMM yyyy, HH:mm', 'id_ID')
        .format(notification.createdAt);

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      NotificationHelper.getCategoryName(notification.category),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          
          // Metadata
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              if (notification.sender != null)
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      notification.sender!.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          
          if (notification.datalansia != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Lansia: ${notification.datalansia!.namaLansia}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Urgency badge
                  if (notification.isUrgent)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Notifikasi Darurat - Perhatian segera diperlukan',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // Message
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                  
                  // Additional data
                  if (notification.data != null && notification.data!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Informasi Tambahan:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...notification.data!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ${entry.key}: ',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          
          // Actions
          Row(
            children: [
              if (!notification.isRead)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onMarkAsRead();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Tandai Dibaca'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9C6223),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              if (notification.isRead)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF9C6223)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tutup'),
                  ),
                ),
              
              if (notification.actionUrl != null && notification.actionText != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to action URL
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF9C6223),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF9C6223)),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(notification.actionText!),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
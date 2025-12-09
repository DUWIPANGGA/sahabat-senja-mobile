// widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final int? currentUserId;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;
  final bool showSenderName;
  final bool showAvatar;
  final Color senderColor;
  final Color receiverColor;

  const MessageBubble({
    super.key,
    required this.message,
    this.currentUserId,
    this.onLongPress,
    this.onTap,
    this.showSenderName = true,
    this.showAvatar = true,
    this.senderColor = Colors.teal,
    this.receiverColor = Colors.grey,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isExpanded = false;

  bool get _isSender {
    if (widget.message.isSender != null) {
      return widget.message.isSender!;
    }
    return widget.currentUserId == widget.message.senderId;
  }

  bool get _isImage => widget.message.type == 'image';
  bool get _isFile => widget.message.type == 'file';
  bool get _isText => !_isImage && !_isFile;

  String get _formattedTime {
    final date = widget.message.createdAt;
    final now = DateTime.now();
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    } else {
      return DateFormat('dd/MM HH:mm').format(date);
    }
  }

  Widget _buildAvatar() {
    final sender = widget.message.sender;
    final avatarUrl = sender?['avatar'];
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _isSender ? widget.senderColor.withOpacity(0.2) : Colors.grey[200],
        shape: BoxShape.circle,
        border: Border.all(
          color: _isSender ? widget.senderColor.withOpacity(0.4) : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: avatarUrl != null && avatarUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    _isSender ? Icons.person : Icons.medical_services,
                    size: 16,
                    color: _isSender ? widget.senderColor : widget.receiverColor,
                  );
                },
              ),
            )
          : Center(
              child: Icon(
                _isSender ? Icons.person : Icons.medical_services,
                size: 16,
                color: _isSender ? widget.senderColor : widget.receiverColor,
              ),
            ),
    );
  }

  Widget _buildTextMessage() {
    return SelectableText(
      widget.message.message,
      style: TextStyle(
        fontSize: 16,
        color: _isSender ? Colors.white : Colors.grey[900],
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message.message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SelectableText(
              widget.message.message,
              style: TextStyle(
                fontSize: 16,
                color: _isSender ? Colors.white : Colors.grey[900],
                height: 1.4,
              ),
            ),
          ),
        GestureDetector(
          onTap: () => _showImagePreview(widget.message.fileUrl),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 240,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.message.fileUrl != null)
                    Image.network(
                      widget.message.fileUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: Colors.white,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey[500],
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  
                  // Image overlay with caption
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.image,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.message.fileName ?? 'Gambar',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileMessage() {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSender
            ? Colors.white.withOpacity(0.15)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSender
              ? Colors.white.withOpacity(0.3)
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.message.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SelectableText(
                widget.message.message,
                style: TextStyle(
                  fontSize: 16,
                  color: _isSender ? Colors.white : Colors.grey[900],
                  height: 1.4,
                ),
              ),
            ),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isSender ? Colors.white24 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    _getFileIcon(widget.message.fileName ?? ''),
                    size: 20,
                    color: _isSender ? Colors.white : Colors.teal,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.fileName ?? 'File',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isSender ? Colors.white : Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getFileSize(widget.message.fileName ?? ''),
                      style: TextStyle(
                        fontSize: 11,
                        color: _isSender ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: _isSender ? Colors.white12 : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  size: 14,
                  color: _isSender ? Colors.white70 : Colors.teal,
                ),
                const SizedBox(width: 6),
                Text(
                  'Download',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isSender ? Colors.white : Colors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (ext == 'doc' || ext == 'docx') return Icons.description;
    if (ext == 'xls' || ext == 'xlsx') return Icons.table_chart;
    if (ext == 'ppt' || ext == 'pptx') return Icons.slideshow;
    if (ext == 'zip' || ext == 'rar') return Icons.folder_zip;
    if (ext == 'txt') return Icons.text_snippet;
    
    return Icons.insert_drive_file;
  }

  String _getFileSize(String fileName) {
    // You can get actual file size from your model
    final sizeInBytes = widget.message.filePath?.length ?? 0;
    
    if (sizeInBytes > 1000000) {
      return '${(sizeInBytes / 1000000).toStringAsFixed(1)} MB';
    } else if (sizeInBytes > 1000) {
      return '${(sizeInBytes / 1000).toStringAsFixed(1)} KB';
    } else {
      return '$sizeInBytes B';
    }
  }

  Widget _buildMessageStatus() {
    if (!_isSender) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formattedTime,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          widget.message.isRead
              ? Icons.done_all
              : Icons.done,
          size: 14,
          color: widget.message.isRead
              ? Colors.blue.shade200
              : Colors.white.withOpacity(0.7),
        ),
      ],
    );
  }

  Widget _buildReceiverMessageStatus() {
    if (_isSender) return const SizedBox.shrink();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formattedTime,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSenderName() {
    if (_isSender || !widget.showSenderName) return const SizedBox.shrink();
    
    final senderName = widget.message.sender?['name'] ?? 'Unknown';
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 4),
      child: Text(
        senderName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showImagePreview(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InteractiveViewer(
                      child: Center(
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 60,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: Colors.white),
                          onPressed: () {
                            // Implement download functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Downloading image...'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: widget.onLongPress,
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(
          crossAxisAlignment: _isSender
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            _buildSenderName(),
            
            Row(
              mainAxisAlignment: _isSender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar for receiver messages
                if (!_isSender && widget.showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildAvatar(),
                  ),
                
                // Message content
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _isSender
                          ? widget.senderColor
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isImage)
                          _buildImageMessage()
                        else if (_isFile)
                          _buildFileMessage()
                        else
                          _buildTextMessage(),
                        
                        const SizedBox(height: 8),
                        
                        // Message status and time
                        _isSender
                            ? _buildMessageStatus()
                            : _buildReceiverMessageStatus(),
                      ],
                    ),
                  ),
                ),
                
                // Avatar for sender messages (optional)
                if (_isSender && widget.showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _buildAvatar(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
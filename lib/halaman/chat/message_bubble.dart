// widgets/chat/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:sahabatsenja_app/models/chat_model.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isSender = message.isSender ?? false;
    
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: isSender
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isSender)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  backgroundColor: Colors.teal[100],
                  radius: 16,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.teal[800],
                  ),
                ),
              ),
            Flexible(
              child: Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!isSender)
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text(
                        message.sender?['name'] ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSender
                          ? Colors.teal
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: _buildMessageContent(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                    child: Text(
                      message.timeFormatted ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isSender)
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: Icon(
                  message.isRead ? Icons.done_all : Icons.done,
                  size: 16,
                  color: message.isRead ? Colors.blue : Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case 'image':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: message.isSender == true
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: message.fileUrl != null
                    ? Image.network(
                        message.fileUrl!,
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          );
                        },
                      )
                    : const SizedBox(
                        width: 200,
                        height: 150,
                        child: Center(
                          child: Icon(Icons.image, size: 50),
                        ),
                      ),
              ),
            ),
          ],
        );
        
      case 'file':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  message.message,
                  style: TextStyle(
                    color: message.isSender == true
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.insert_drive_file,
                    color: message.isSender == true
                        ? Colors.white
                        : Colors.teal,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.fileName ?? 'File',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: message.isSender == true
                                ? Colors.white
                                : Colors.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap untuk download',
                          style: TextStyle(
                            fontSize: 12,
                            color: message.isSender == true
                                ? Colors.white70
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        
      default: // text
        return Text(
          message.message,
          style: TextStyle(
            color: message.isSender == true
                ? Colors.white
                : Colors.black,
            fontSize: 16,
          ),
        );
    }
  }
}
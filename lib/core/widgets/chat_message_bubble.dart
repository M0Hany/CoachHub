import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final String? imageUrl;
  final bool isRtl;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    this.imageUrl,
    this.isRtl = false,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.white : AppTheme.accent;
    final textColor = isMe ? AppTheme.textDark : Colors.black;
    final align = isMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment: align,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && imageUrl != null) ...[
            CircleAvatar(
              radius: 20,
              backgroundImage: imageUrl!.startsWith('http')
                  ? NetworkImage(imageUrl!)
                  : AssetImage(imageUrl!) as ImageProvider,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontFamily: 'Alexandria',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Alexandria',
                  ),
                ),
              ],
            ),
          ),
          if (isMe && imageUrl != null) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundImage: imageUrl!.startsWith('http')
                  ? NetworkImage(imageUrl!)
                  : AssetImage(imageUrl!) as ImageProvider,
            ),
          ],
        ],
      ),
    );
  }
} 
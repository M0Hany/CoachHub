import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class NotificationPreviewBubble extends StatelessWidget {
  final String message;
  final String time;
  final String? imageUrl;
  final bool is_read;
  final VoidCallback onTap;

  const NotificationPreviewBubble({
    super.key,
    required this.message,
    required this.time,
    this.imageUrl,
    this.is_read = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            if (!is_read)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 12,
              child: time != "Unknown"
                ? Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                )
                : const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile picture
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.accent,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl!)
                          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification preview
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          message,
                          style: AppTheme.labelText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
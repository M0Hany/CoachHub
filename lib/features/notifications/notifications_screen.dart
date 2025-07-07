import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/widgets/chat_preview_bubble.dart';
import '../../core/constants/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../core/network/http_client.dart';
import 'dart:developer' as developer;

class NotificationsScreen extends StatefulWidget {
  final UserRole userRole;
  
  const NotificationsScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _error;
  List<NotificationData> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final httpClient = HttpClient();
      final response = await httpClient.get<Map<String, dynamic>>('/api/notification/');

      if (response.data?['status'] == 'success') {
        final notificationsData = response.data!['data']['notifications'] as List<dynamic>;
        final notifications = notificationsData.map((notification) => NotificationData.fromJson(notification)).toList();
        
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.data?['message'] ?? 'Failed to fetch notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching notifications: $e', name: 'NotificationsScreen');
      setState(() {
        _error = 'Failed to load notifications';
        _isLoading = false;
      });
    }
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months} month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years} year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(50),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 32,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Center(
                    child: Text(
                      l10n.notificationsTitle,
                      style: AppTheme.screenTitle,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _fetchNotifications,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : _notifications.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No notifications yet',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _notifications.length,
                                    itemBuilder: (context, index) {
                                      final notification = _notifications[index];
                                      final isLastItem = index == _notifications.length - 1;
                                      
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: isLastItem ? 16.0 : 0),
                                        child: ChatPreviewBubble(
                                          name: notification.fullName.isNotEmpty ? notification.fullName : 'User',
                                          lastMessage: notification.message,
                                          time: _formatTimeAgo(notification.createdAt),
                                          imageUrl: notification.fullImageUrl ?? 'assets/images/default_profile.png',
                                          unread: !notification.isRead,
                                          unreadCount: notification.isRead ? 0 : 1,
                                          onTap: () {
                                            // Handle notification tap
                                            // TODO: Implement notification action based on type
                                          },
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                role: widget.userRole,
                currentIndex: 2, // Notifications tab
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Notification data model
class NotificationData {
  final int id;
  final String fullName;
  final String? imageUrl;
  final String message;
  final bool isRead;
  final String createdAt;

  NotificationData({
    required this.id,
    required this.fullName,
    this.imageUrl,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    // Fallback for name
    final fallbackName = 'CoachHub';
    String name = json['full_name'] as String? ?? fallbackName;
    if (name.trim().isEmpty) name = fallbackName;
    return NotificationData(
      id: json['id'] as int,
      fullName: name,
      imageUrl: json['image_url'] as String?,
      message: json['message'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? true,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) {
      // Fallback to default asset image
      return null;
    }
    return imageUrl!.startsWith('http') 
        ? imageUrl 
        : 'https://coachhub-production.up.railway.app/$imageUrl';
  }
} 
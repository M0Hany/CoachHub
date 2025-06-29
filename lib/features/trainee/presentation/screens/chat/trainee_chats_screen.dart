import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/widgets/chat_preview_bubble.dart';
import '../../../../../core/constants/enums.dart';
import 'package:go_router/go_router.dart';

class TraineeChatsScreen extends StatelessWidget {
  const TraineeChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock chat data
    final chats = [
      {
        'name': 'Coach Ahmed',
        'lastMessage': 'Great progress on your strength training!',
        'time': 'Just Now',
        'imageUrl': 'assets/images/default_profile.jpg',
        'unread': true,
        'unreadCount': 2,
      },
      {
        'name': 'Coach Sara',
        'lastMessage': 'Let\'s adjust your meal plan for next week',
        'time': '30m ago',
        'imageUrl': 'assets/images/default_profile.jpg',
        'unread': false,
        'unreadCount': 0,
      },
      {
        'name': 'Coach Mohamed',
        'lastMessage': 'Your cardio metrics are improving!',
        'time': '1h ago',
        'imageUrl': 'assets/images/default_profile.jpg',
        'unread': true,
        'unreadCount': 1,
      },
      {
        'name': 'Coach Layla',
        'lastMessage': 'Ready for tomorrow\'s HIIT session?',
        'time': '2h ago',
        'imageUrl': 'assets/images/default_profile.jpg',
        'unread': false,
        'unreadCount': 0,
      },
      {
        'name': 'Coach Omar',
        'lastMessage': 'Let\'s review your progress this month',
        'time': '3h ago',
        'imageUrl': 'assets/images/default_profile.jpg',
        'unread': true,
        'unreadCount': 1,
      },
    ];

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
                  child: const Center(
                    child: Text(
                      "Messages",
                      style: AppTheme.screenTitle,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        final isLastItem = index == chats.length - 1;
                        
                        return Padding(
                          padding: EdgeInsets.only(bottom: isLastItem ? 24.0 : 0),
                          child: ChatPreviewBubble(
                            name: chat['name'] as String,
                            lastMessage: chat['lastMessage'] as String,
                            time: chat['time'] as String,
                            imageUrl: chat['imageUrl'] as String?,
                            unread: chat['unread'] as bool,
                            unreadCount: chat['unreadCount'] as int,
                            onTap: () => context.push('/trainee/chats/${chat['name']}'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                role: UserRole.trainee,
                currentIndex: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/widgets/chat_preview_bubble.dart';
import '../../../../core/constants/enums.dart';
import '../../../../l10n/app_localizations.dart';

class CoachNotificationsScreen extends StatelessWidget {
  const CoachNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Mock notifications data
    final notifications = [
      {
        'section': l10n.notificationsToday,
        'items': [
          {
            'name': 'Hani_Medhat_',
            'message': l10n.interestedInCoaching('Hani'),
            'time': l10n.notificationsJustNow,
            'imageUrl': 'assets/images/default_profile.png',
          },
          {
            'name': 'Mourad08',
            'message': l10n.checkedOffWorkout('Mourad'),
            'time': '11:20',
            'imageUrl': 'assets/images/default_profile.png',
          },
          {
            'name': 'Dina05_',
            'message': l10n.completedPlan('Dina'),
            'time': '10:45',
            'imageUrl': 'assets/images/default_profile.png',
          },
        ],
      },
      {
        'section': l10n.yesterday,
        'items': [
          {
            'name': 'Yousef_Ahmed',
            'message': l10n.requestedChange('Yousef'),
            'time': l10n.dayAgo(1),
            'imageUrl': null,
          },
        ],
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
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, sectionIndex) {
                        final section = notifications[sectionIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
                              child: Text(
                                section['section'] as String,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (section['items'] as List).length,
                              itemBuilder: (context, itemIndex) {
                                final notification = (section['items'] as List)[itemIndex];
                                final isLastItem = itemIndex == (section['items'] as List).length - 1;
                                
                                return Padding(
                                  padding: EdgeInsets.only(bottom: isLastItem ? 16.0 : 0),
                                  child: ChatPreviewBubble(
                                    name: notification['name'] as String,
                                    lastMessage: notification['message'] as String,
                                    time: notification['time'] as String,
                                    imageUrl: notification['imageUrl'] as String?,
                                    unread: false,
                                    unreadCount: 0,
                                    onTap: () {}, // Handle notification tap
                                  ),
                                );
                              },
                            ),
                          ],
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
                role: UserRole.coach,
                currentIndex: 4, // Notifications tab
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
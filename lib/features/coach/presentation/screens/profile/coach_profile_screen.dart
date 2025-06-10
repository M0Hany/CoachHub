import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class CoachProfileScreen extends StatelessWidget {
  const CoachProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: () => context.go('/coach/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Image and Rating
            Container(
              padding: const EdgeInsets.only(top:16, left: 16, right: 16),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                    backgroundImage: AssetImage('assets/images/default_profile.png'),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.black),
                        Icon(Icons.star, size: 16, color: Colors.black),
                        Icon(Icons.star, size: 16, color: Colors.black),
                        Icon(Icons.star, size: 16, color: Colors.black),
                        Icon(Icons.star_half, size: 16, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Personal Info Card
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              margin: const EdgeInsets.symmetric(horizontal: 42),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.personalInfo,
                          style: AppTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement edit functionality
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            elevation: 2,
                            shadowColor: AppColors.shadowDark,
                          ),
                          child: Text(l10n.edit, style: AppTheme.buttonTextDark,),
                        ),
                      ],
                    ),
                  ),
                  _buildInfoRow(Icons.person_outline_rounded, l10n.name, 'Khalid Salah'),
                  _buildInfoRow(Icons.email_outlined, l10n.emailLabel, 'KhalidSalah99@gmail.com'),
                  _buildInfoRow(Icons.male, l10n.gender, 'Male'),
                  _buildInfoRow(
                    Icons.fitness_center,
                    l10n.coachExpertFields,
                    'Powerlifting, Crossfit',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Posts Section
            Container(
              margin: const EdgeInsets.only(left: 42, right: 42, top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.posts,
                        style: AppTheme.bodyLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement show all posts
                        },
                        child: Text(l10n.showAllPosts),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Sample Post
                  Container(
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  AssetImage('assets/images/default_profile.png'),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Khalid Salah',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  l10n.timeAgo('2h'),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Text(
                          'تمرين اليوم مع متدرب جديد\nتم تحديد الأهداف وتحديد خطة التدريب\nبالتوفيق في رحلتك التدريبية',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.5,
                          ),
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
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.coach,
        currentIndex: 3, // Profile tab
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.labelText,
              ),
              Text(
                value,
                style: AppTheme.mainText,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

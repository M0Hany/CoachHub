import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../auth/models/user_model.dart';

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${authProvider.error}'),
              ElevatedButton(
                onPressed: () {
                  authProvider.resetError();
                  authProvider.refreshProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }

    // Convert rating to number of full and half stars
    final rating = user.rating ?? 0.0;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final remainingStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/navigation/Settings.png',
              width: 28,
              height: 28,
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
                  _buildProfileImage(user),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full stars
                        ...List.generate(fullStars, (index) => 
                          const Icon(Icons.star, size: 16, color: Colors.black)
                        ),
                        // Half star if needed
                        if (hasHalfStar)
                          const Icon(Icons.star_half, size: 16, color: Colors.black),
                        // Empty stars
                        ...List.generate(remainingStars, (index) => 
                          const Icon(Icons.star_border, size: 16, color: Colors.black)
                        ),
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
                  _buildInfoRow(Icons.person_outline_rounded, l10n.name, user.fullName),
                  _buildInfoRow(Icons.email_outlined, l10n.emailLabel, user.email),
                  _buildInfoRow(Icons.male, l10n.gender, user.gender.name),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.fitness_center, size: 20, color: Colors.black87),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.coachExpertFields,
                              style: AppTheme.labelText,
                            ),
                            if (user.experiences != null && user.experiences!.isNotEmpty)
                              ...user.experiences!.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    e.name,
                                    style: AppTheme.mainText,
                                  ),
                                ),
                              )
                            else
                              Text(
                                'Not set',
                                style: AppTheme.mainText,
                              ),
                          ],
                        ),
                      ],
                    ),
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
                  if (user.recentPost != null)
                    Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: (() {
                                  String? imageUrl = user.imageUrl;
                                  String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
                                      ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
                                      : null;
                                  return fullUrl != null
                                      ? NetworkImage(fullUrl)
                                      : const AssetImage('assets/images/default_profile.jpg') as ImageProvider;
                                })(),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    l10n.timeAgo('2h'), // TODO: Calculate actual time
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            user.recentPost?['content'] ?? '',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
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

  Widget _buildProfileImage(UserModel user) {
    String? imageUrl = user.imageUrl;
    String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
        : null;
    return CircleAvatar(
      radius: 48,
      backgroundImage: fullUrl != null
          ? NetworkImage(fullUrl)
          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
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

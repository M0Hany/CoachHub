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

  String _calculateTimeAgo(String? createdAt) {
    if (createdAt == null) return '';
    
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);
      
      if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} h';
      } else if (difference.inDays < 30) {
        return '${difference.inDays} d';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months} month${months > 1 ? 's' : ''}';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years} year${years > 1 ? 's' : ''}';
      }
    } catch (e) {
      return '';
    }
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
      extendBody: true,
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
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
            // Profile Image and Rating
            Container(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: [
                  _buildProfileImage(user),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full stars
                        ...List.generate(
                          fullStars,
                          (index) => const Icon(Icons.star, size: 16, color: Colors.black),
                        ),
                        // Half star if needed
                        if (hasHalfStar)
                          const Icon(Icons.star_half, size: 16, color: Colors.black),
                        // Empty stars
                        ...List.generate(
                          remainingStars,
                          (index) => const Icon(Icons.star_border, size: 16, color: Colors.black),
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
                  if (user.bio != null)
                    _buildInfoRow(Icons.info_outline, 'Bio', user.bio!),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.fitness_center, size: 20, color: Colors.black87),
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
                borderRadius: BorderRadius.circular(20),
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
                      if (user.recentPost != null)
                        TextButton(
                          onPressed: () {
                            context.push('/coach/posts');
                          },
                          child: Text(l10n.showAllPosts),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (user.recentPost != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _calculateTimeAgo(user.recentPost?['created_at']),
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.recentPost?['content'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              l10n.noPostsYet,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => context.push('/coach/posts'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textLight,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 2,
                            ),
                            child: Text(l10n.makeFirstPost, style: AppTheme.bodyMedium.copyWith(color: AppTheme.textLight)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Reviews Section
            Container(
              margin: const EdgeInsets.only(left: 42, right: 42, top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                        l10n.reviews,
                        style: AppTheme.bodyLarge,
                      ),
                      if (user.recentReview != null)
                        TextButton(
                          onPressed: () {
                            context.push('/coach/reviews');
                          },
                          child: Text(l10n.showAllReviews),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (user.recentReview != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: (() {
                                  String? imageUrl = user.recentReview?['trainee']?['image_url'];
                                  String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
                                      ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
                                      : null;
                                  return fullUrl != null
                                      ? NetworkImage(fullUrl)
                                      : const AssetImage('assets/images/default_profile.jpg') as ImageProvider;
                                })(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.recentReview?['trainee']?['full_name'] ?? 'Anonymous',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        // Convert rating to number and calculate stars
                                        ...(() {
                                          final rating = (user.recentReview?['rating'] ?? 0).toDouble();
                                          final fullStars = rating.floor().toInt();
                                          final hasHalfStar = (rating - fullStars) >= 0.5;
                                          final remainingStars = (5 - fullStars - (hasHalfStar ? 1 : 0)).toInt();
                                          
                                          return [
                                            // Full stars
                                            ...List.generate(fullStars, (index) => const Icon(Icons.star, size: 16, color: Colors.amber)),
                                            // Half star if needed
                                            if (hasHalfStar) const Icon(Icons.star_half, size: 16, color: Colors.amber),
                                            // Empty stars
                                            ...List.generate(remainingStars, (index) => const Icon(Icons.star_border, size: 16, color: Colors.amber)),
                                          ];
                                        })(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.recentReview?['comment'] ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          l10n.noReviewsYet,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Bottom spacing to push content above navigation bar when scrolling
            const SizedBox(height: 120),
          ],
        ),
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

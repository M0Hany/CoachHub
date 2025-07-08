import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';

class TraineeCoachPostFocusScreen extends StatelessWidget {
  final Map<String, dynamic> post;
  final String? coachImageUrl;
  final String? coachFullName;
  const TraineeCoachPostFocusScreen({
    super.key,
    required this.post,
    this.coachImageUrl,
    this.coachFullName,
  });

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

  Widget _buildMediaColumn(List<dynamic> media) {
    if (media.isEmpty) return const SizedBox.shrink();
    final mediaUrls = media.where((m) => m['media_type'] == 'image').map((m) => m['media_url'] as String).toList();
    if (mediaUrls.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        children: mediaUrls.map((mediaUrl) {
          final fullUrl = mediaUrl.startsWith('http') 
              ? mediaUrl 
              : 'https://coachhub-production.up.railway.app/$mediaUrl';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                fullUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                l10n.posts,
                style: AppTheme.bodyMedium,
              ),
              centerTitle: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: (coachImageUrl != null && coachImageUrl!.isNotEmpty)
                                  ? NetworkImage(coachImageUrl!.startsWith('http') ? coachImageUrl! : 'https://coachhub-production.up.railway.app/$coachImageUrl')
                                  : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coachFullName ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _calculateTimeAgo(post['created_at']),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (post['content'] != null && post['content'].toString().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              post['content'],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        if (post['media'] != null && (post['media'] as List).isNotEmpty)
                          _buildMediaColumn(post['media']),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
      ),
    );
  }
} 
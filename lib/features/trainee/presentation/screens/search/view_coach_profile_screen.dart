import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import '../../../../../features/coach/data/models/coach_model.dart';
import 'package:go_router/go_router.dart';

class ViewCoachProfileScreen extends StatefulWidget {
  final String coachId;

  const ViewCoachProfileScreen({
    super.key,
    required this.coachId,
  });

  @override
  State<ViewCoachProfileScreen> createState() => _ViewCoachProfileScreenState();
}

class _ViewCoachProfileScreenState extends State<ViewCoachProfileScreen> {
  bool _isLoading = true;
  String? _error;
  CoachModel? _coach;
  Map<String, dynamic>? _recentReview;

  @override
  void initState() {
    super.initState();
    _fetchCoachProfile();
  }

  Future<void> _fetchCoachProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final httpClient = HttpClient();
      final response = await httpClient.get(
        '/api/profile/${widget.coachId}',
      );

      if (response.data['status'] == 'success') {
        final profileData = response.data['data']['profile'] as Map<String, dynamic>;
        setState(() {
          _coach = CoachModel.fromJson(profileData);
          _recentReview = profileData['recentReview'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch coach profile');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendSubscriptionRequest() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final httpClient = HttpClient();
      final response = await httpClient.post(
        '/api/subscription/request/${widget.coachId}',
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              response.data['status'] == 'success' 
                ? l10n.subscribeSuccess 
                : l10n.error
            ),
            content: response.data['status'] == 'fail' 
              ? Text(response.data['message']) 
              : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.error),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSubscriptionConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.subscribeConfirmTitle),
        content: Text(
          l10n.subscribeConfirmMessage(_coach!.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sendSubscriptionRequest();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
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

  String _formatExpertise(List<Experience>? experiences, AppLocalizations l10n) {
    if (experiences == null || experiences.isEmpty) return l10n.notSet;
    return experiences.map((e) => e.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: _fetchCoachProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_coach == null) {
      return const Scaffold(
        body: Center(
          child: Text('No coach data available'),
        ),
      );
    }

    // Convert rating to number of full and half stars
    final rating = _coach!.rating;
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    final remainingStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/icons/navigation/Chats Inactive.png',
              width: 28,
              height: 28,
            ),
            onPressed: () {
              context.push(
                '/chat/room/${widget.coachId}',
                extra: {
                  'recipientId': widget.coachId,
                  'recipientName': _coach?.fullName ?? 'Coach',
                },
              );
            },
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
                  _buildProfileImage(_coach!.imageUrl),
                  const SizedBox(height: 12),
                  Text(
                    _coach!.fullName,
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
                          style: AppTheme.bodyMedium,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showSubscriptionConfirmation();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: const Size(0, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            l10n.subscribe,
                            style: AppTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_coach!.bio != null)
                    _buildInfoRow(Icons.info_outline, l10n.bio, _coach!.bio!),
                  _buildInfoRow(Icons.fitness_center, l10n.coachExpertFields, _formatExpertise(_coach!.experiences, l10n)),
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
                        if (_coach!.recentPost != null)
                      TextButton(
                        onPressed: () {
                          context.push(
                            '/trainee/coach/${widget.coachId}/posts',
                            extra: {
                              'coachImageUrl': _coach!.imageUrl,
                              'coachFullName': _coach!.fullName,
                            },
                          );
                        },
                        child: Text(l10n.showAllPosts),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_coach!.recentPost != null)
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
                                    String? imageUrl = _coach!.imageUrl;
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
                                          _coach!.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                        Text(
                                        _calculateTimeAgo(_coach!.recentPost!.createdAt.toIso8601String()),
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
                                      _coach!.recentPost!.content,
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
                            l10n.noPostsYet,
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
                        if (_recentReview != null)
                          TextButton(
                            onPressed: () {
                              context.push(
                                '/trainee/coach/${widget.coachId}/reviews',
                                extra: {
                                  'coachImageUrl': _coach!.imageUrl,
                                  'coachFullName': _coach!.fullName,
                                },
                              );
                            },
                            child: Text(l10n.showAllReviews),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_recentReview != null)
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
                                    String? imageUrl = _recentReview?['trainee']?['image_url'];
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
                                        _recentReview?['trainee']?['full_name'] ?? 'Anonymous',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ...(() {
                                            final rating = (_recentReview?['rating'] ?? 0).toDouble();
                                            final fullStars = rating.floor();
                                            final hasHalfStar = (rating - fullStars) >= 0.5;
                                            final remainingStars = (5 - fullStars - (hasHalfStar ? 1 : 0)).toInt();
                                            return [
                                              ...List.generate(fullStars, (index) => const Icon(Icons.star, size: 16, color: Colors.amber)),
                                              if (hasHalfStar) const Icon(Icons.star_half, size: 16, color: Colors.amber),
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
                              _recentReview?['comment'] ?? '',
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
        role: UserRole.trainee,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Alexandria',
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl, {double radius = 48}) {
    String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
        : null;
    return CircleAvatar(
      radius: radius,
      backgroundImage: fullUrl != null
          ? NetworkImage(fullUrl)
          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
    );
  }
} 
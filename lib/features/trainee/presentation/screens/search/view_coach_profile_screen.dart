import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import '../../../../../features/coach/data/models/coach_model.dart';

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
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primary,
            ),
            onPressed: () {
              // TODO: Implement chat functionality
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
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
                          style: AppTheme.bodyLarge,
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
                    _buildInfoRow(Icons.info_outline, 'Bio', _coach!.bio!),
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
                            if (_coach!.experiences.isNotEmpty)
                              ..._coach!.experiences.map(
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
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
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
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.showAllPosts,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_coach!.recentPost != null)
                    Container(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildProfileImage(_coach!.imageUrl, radius: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _coach!.fullName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.timeAgo('2h'), // TODO: Calculate actual time
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _coach!.recentPost!.content,
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
                        ],
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        'No posts yet',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 0,
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
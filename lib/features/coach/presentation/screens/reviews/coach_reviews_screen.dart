import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'package:provider/provider.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';

class CoachReviewsScreen extends StatefulWidget {
  const CoachReviewsScreen({super.key});

  @override
  State<CoachReviewsScreen> createState() => _CoachReviewsScreenState();
}

class _CoachReviewsScreenState extends State<CoachReviewsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final httpClient = HttpClient();
      final response = await httpClient.get('/api/review/');
      if (response.data['status'] == 'success') {
        setState(() {
          _reviews = List<Map<String, dynamic>>.from(response.data['data']['reviews']);
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch reviews');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
                onPressed: _fetchReviews,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text(
                    l10n.reviews,
                    style: AppTheme.bodyMedium,
                  ),
                  centerTitle: true,
                ),
                Expanded(
                  child: _reviews.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noReviewsYet,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            final trainee = review['trainee'] ?? {};
                            final rating = (review['rating'] ?? 0).toDouble();
                            final fullStars = rating.floor();
                            final hasHalfStar = (rating - fullStars) >= 0.5;
                            final remainingStars = 5 - fullStars - (hasHalfStar ? 1 : 0);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
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
                                          backgroundImage: (() {
                                            String? imageUrl = trainee['image_url'];
                                            String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
                                                ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
                                                : null;
                                            return fullUrl != null
                                                ? NetworkImage(fullUrl)
                                                : const AssetImage('assets/images/default_profile.jpg') as ImageProvider;
                                          })(),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                trainee['full_name'] ?? 'Anonymous',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  ...List.generate(fullStars, (index) => const Icon(Icons.star, size: 16, color: Colors.amber)),
                                                  if (hasHalfStar) const Icon(Icons.star_half, size: 16, color: Colors.amber),
                                                  ...List.generate(remainingStars.toInt(), (index) => const Icon(Icons.star_border, size: 16, color: Colors.amber)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if ((review['comment'] ?? '').toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Text(
                                          review['comment'],
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 100),
              ],
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                role: UserRole.coach,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
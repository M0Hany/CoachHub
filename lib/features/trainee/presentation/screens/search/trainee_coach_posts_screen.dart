import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';

class TraineeCoachPostsScreen extends StatefulWidget {
  final String coachId;
  final String? coachImageUrl;
  final String? coachFullName;
  const TraineeCoachPostsScreen({
    super.key,
    required this.coachId,
    this.coachImageUrl,
    this.coachFullName,
  });

  @override
  State<TraineeCoachPostsScreen> createState() => _TraineeCoachPostsScreenState();
}

class _TraineeCoachPostsScreenState extends State<TraineeCoachPostsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];
  Map<int, bool> _expandedPosts = {};

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final httpClient = HttpClient();
      final response = await httpClient.get('/api/post/${widget.coachId}');
      if (response.data['status'] == 'success') {
        setState(() {
          _posts = List<Map<String, dynamic>>.from(response.data['data']['posts']);
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch posts');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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

  Widget _buildMediaGrid(List<dynamic> media, int postId) {
    if (media.isEmpty) return const SizedBox.shrink();
    final mediaUrls = media.where((m) => m['media_type'] == 'image').map((m) => m['media_url'] as String).toList();
    if (mediaUrls.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.maxWidth;
          final boxHeight = _calculateGridHeight(mediaUrls.length, boxWidth);
          return SizedBox(
            height: boxHeight,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(mediaUrls.length),
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: mediaUrls.length > 4 ? 4 : mediaUrls.length,
              itemBuilder: (context, index) {
                if (index >= mediaUrls.length) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }
                final mediaUrl = mediaUrls[index];
                final fullUrl = mediaUrl.startsWith('http') 
                    ? mediaUrl 
                    : 'https://coachhub-production.up.railway.app/$mediaUrl';
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () {
                        context.push('/trainee/coach/${widget.coachId}/posts/focus', extra: {
                          'post': _posts.firstWhere((p) => p['id'] == postId),
                          'coachImageUrl': widget.coachImageUrl,
                          'coachFullName': widget.coachFullName,
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          fullUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            );
                          },
                        ),
                      ),
                    ),
                    if (index == 3 && mediaUrls.length > 4)
                      GestureDetector(
                        onTap: () {
                          context.push('/trainee/coach/${widget.coachId}/posts/focus', extra: {
                            'post': _posts.firstWhere((p) => p['id'] == postId),
                            'coachImageUrl': widget.coachImageUrl,
                            'coachFullName': widget.coachFullName,
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              '+${mediaUrls.length - 4}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostContent(String content, int postId, AppLocalizations l10n) {
    final isExpanded = _expandedPosts[postId] ?? false;
    final shouldShowSeeMore = content.length > 150;
    if (!shouldShowSeeMore) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: isExpanded ? null : 3,
            overflow: isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (!isExpanded)
            GestureDetector(
              onTap: () => setState(() => _expandedPosts[postId] = true),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.seeMore,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getCrossAxisCount(int mediaCount) {
    switch (mediaCount) {
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
      case 4:
      default:
        return 2;
    }
  }

  double _calculateGridHeight(int mediaCount, double boxWidth) {
    final itemHeight = boxWidth / 2;
    switch (mediaCount) {
      case 1:
        return itemHeight;
      case 2:
        return itemHeight;
      case 3:
      case 4:
      default:
        return itemHeight * 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              Text('Error: [31m$_error[0m'),
              ElevatedButton(
                onPressed: _fetchPosts,
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
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                l10n.posts,
                style: AppTheme.bodyMedium,
              ),
              centerTitle: true,
            ),
            Expanded(
              child: _posts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          l10n.noPostsYet,
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
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
                                      backgroundImage: (widget.coachImageUrl != null && widget.coachImageUrl!.isNotEmpty)
                                          ? NetworkImage(widget.coachImageUrl!.startsWith('http') ? widget.coachImageUrl! : 'https://coachhub-production.up.railway.app/${widget.coachImageUrl}')
                                          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.coachFullName ?? '',
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
                                _buildPostContent(post['content'] ?? '', post['id'], l10n),
                                if (post['media'] != null && (post['media'] as List).isNotEmpty)
                                  _buildMediaGrid(post['media'], post['id']),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 0,
      ),
    );
  }
} 
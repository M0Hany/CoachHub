import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CoachPostsScreen extends StatefulWidget {
  const CoachPostsScreen({super.key});

  @override
  State<CoachPostsScreen> createState() => _CoachPostsScreenState();
}

class _CoachPostsScreenState extends State<CoachPostsScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];
  Map<int, bool> _expandedPosts = {}; // Track which posts are expanded
  
  // Create post state
  bool _isCreatingPost = false;
  final TextEditingController _postContentController = TextEditingController();
  List<File> _selectedImages = [];
  final FocusNode _postFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  // Edit post state
  int? _editingPostId;
  int? _menuOpenPostId;
  TextEditingController? _editContentController;
  List<EditableImage> _editSelectedImages = [];
  FocusNode? _editFocusNode;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void dispose() {
    _postContentController.dispose();
    _postFocusNode.dispose();
    super.dispose();
  }

  void _togglePostExpansion(int postId) {
    setState(() {
      _expandedPosts[postId] = !(_expandedPosts[postId] ?? false);
    });
  }

  Future<void> _fetchPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final httpClient = HttpClient();
      final response = await httpClient.get('/api/post/');

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

    final mediaUrls = media
        .where((m) => m['media_type'] == 'image')
        .map((m) => m['media_url'] as String)
        .toList();

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
              itemCount: mediaUrls.length > 4 ? 4 : 4, // Always show 4 squares for 3+ images
              itemBuilder: (context, index) {
                if (index >= mediaUrls.length) {
                  // Empty square for 3 images layout
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
                        context.push('/coach/posts/focus', extra: {
                          'post': _posts.firstWhere((p) => p['id'] == postId),
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
                          context.push('/coach/posts/focus', extra: {
                            'post': _posts.firstWhere((p) => p['id'] == postId),
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
    final shouldShowSeeMore = content.length > 150; // Show "see more" if content is longer than 150 characters

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
              onTap: () => _togglePostExpansion(postId),
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

  void _toggleCreatePost() {
    setState(() {
      _isCreatingPost = !_isCreatingPost;
      if (_isCreatingPost) {
        _postFocusNode.requestFocus();
      } else {
        _postFocusNode.unfocus();
      }
    });
  }

  void _clearPostContent() {
    setState(() {
      _postContentController.clear();
      _selectedImages.clear();
    });
  }

  Future<void> _addImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (!_isCreatingPost) _isCreatingPost = true;
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      // Handle error
      print('Error picking image: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  bool _canPost() {
    return _postContentController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;
  }

  Future<void> _createPost() async {
    if (!_canPost()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final httpClient = HttpClient();
      
      // Create FormData for multipart request
      final formData = FormData();
      formData.fields.add(MapEntry('content', _postContentController.text.trim()));

      // Add media files if any
      for (int i = 0; i < _selectedImages.length; i++) {
        formData.files.add(MapEntry(
          'media',
          await MultipartFile.fromFile(_selectedImages[i].path),
        ));
      }

      final response = await httpClient.post('/api/post/create', data: formData);

      if (response.data['status'] == 'success') {
        // Reset form and refresh posts
        setState(() {
          _isCreatingPost = false;
          _postContentController.clear();
          _selectedImages.clear();
        });
        _postFocusNode.unfocus();
        await _fetchPosts();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create post');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openMenu(int postId) {
    setState(() {
      _menuOpenPostId = postId;
    });
  }

  void _closeMenu() {
    setState(() {
      _menuOpenPostId = null;
    });
  }

  void _startEditPost(Map<String, dynamic> post) {
    setState(() {
      _editingPostId = post['id'];
      _editContentController = TextEditingController(text: post['content'] ?? '');
      _editSelectedImages = (post['media'] as List?)?.where((m) => m['media_type'] == 'image').map<EditableImage>((m) {
        final url = m['media_url'] as String;
        final fullUrl = url.startsWith('http') ? url : 'https://coachhub-production.up.railway.app/$url';
        return EditableImage.network(fullUrl);
      }).toList() ?? [];
      _editFocusNode = FocusNode();
      _menuOpenPostId = null;
    });
  }

  void _cancelEditPost() {
    setState(() {
      _editingPostId = null;
      _editContentController?.dispose();
      _editFocusNode?.dispose();
      _editSelectedImages = [];
    });
  }

  Future<void> _addEditImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _editSelectedImages.add(EditableImage.file(File(image.path)));
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _removeEditImage(int index) {
    setState(() {
      _editSelectedImages.removeAt(index);
    });
  }

  bool _canUpdatePost() {
    return _editContentController?.text.trim().isNotEmpty == true || _editSelectedImages.isNotEmpty;
  }

  Future<void> _updatePost(int postId) async {
    if (!_canUpdatePost()) return;
    try {
      setState(() { _isLoading = true; });
      final httpClient = HttpClient();
      final formData = FormData();
      formData.fields.add(MapEntry('content', _editContentController!.text.trim()));
      for (int i = 0; i < _editSelectedImages.length; i++) {
        if (_editSelectedImages[i].file != null) {
          formData.files.add(MapEntry('media', await MultipartFile.fromFile(_editSelectedImages[i].file!.path)));
        }
      }
      final response = await httpClient.put('/api/post/$postId', data: formData);
      if (response.data['status'] == 'success') {
        _cancelEditPost();
        await _fetchPosts();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update post');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _deletePost(int postId) async {
    try {
      setState(() { _isLoading = true; });
      final httpClient = HttpClient();
      final response = await httpClient.delete('/api/post/$postId');
      if (response.data['status'] == 'success') {
        await _fetchPosts();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to delete post');
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Widget _buildCreatePostContainer() {
    final user = context.read<AuthProvider>().currentUser;
    final l10n = AppLocalizations.of(context)!;
    
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
                    String? imageUrl = user?.imageUrl;
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
                  child: !_isCreatingPost
                      ? GestureDetector(
                          onTap: _toggleCreatePost,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.whatsOnYourMind,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _addImage,
                  icon: const Icon(
                    Icons.attach_file,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            if (_isCreatingPost) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _postContentController,
                  focusNode: _postFocusNode,
                  maxLines: null,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: l10n.whatsOnYourMind,
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey[100],
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              
              // Selected images grid
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.maxWidth;
                    final boxHeight = _calculateGridHeight(_selectedImages.length, boxWidth);

                    return SizedBox(
                      height: boxHeight,
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(_selectedImages.length),
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                        ),
                        itemCount: _selectedImages.length > 4 ? 4 : _selectedImages.length,
                        itemBuilder: (context, index) {
                          if (index >= _selectedImages.length) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                              if (index == 3 && _selectedImages.length > 4)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+${_selectedImages.length - 4}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
              ],
              
              // Post button
              if (_canPost()) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _createPost,
                    child: Text(
                      l10n.post,
                      style: AppTheme.bodyMedium
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
        child: Stack(
          children: [
            Column(
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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _posts.isEmpty ? 2 : _posts.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildCreatePostContainer();
                      }
                      if (_posts.isEmpty && index == 1) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              l10n.noPostsYet,
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      final post = _posts[index - 1];
                      final user = context.read<AuthProvider>().currentUser;
                      
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
                              // Header with profile picture, name, and time
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: (() {
                                      String? imageUrl = user?.imageUrl;
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
                                          user?.fullName ?? 'Unknown',
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
                                  const SizedBox(width: 8),
                                  // Three dots menu
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    color: Colors.white,
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        _startEditPost(post);
                                      } else if (value == 'delete') {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                            backgroundColor: Colors.white,
                                            title: Text(l10n.deletePost),
                                            content: Text(l10n.deletePostConfirm),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, false),
                                                child: Text(l10n.cancel),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(context, true),
                                                child: Text(l10n.confirm),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirmed == true) {
                                          await _deletePost(post['id']);
                                        }
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(l10n.editPost),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(l10n.deletePost),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              
                              // Edit post container
                              if (_editingPostId == post['id']) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: _editContentController,
                                    focusNode: _editFocusNode,
                                    maxLines: null,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: l10n.whatsOnYourMind,
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      fillColor: Colors.grey[100],
                                    ),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    onChanged: (value) {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                if (_editSelectedImages.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final boxWidth = constraints.maxWidth;
                                      final boxHeight = _calculateGridHeight(_editSelectedImages.length, boxWidth);
                                      return SizedBox(
                                        height: boxHeight,
                                        child: GridView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: _getCrossAxisCount(_editSelectedImages.length),
                                            crossAxisSpacing: 2,
                                            mainAxisSpacing: 2,
                                          ),
                                          itemCount: _editSelectedImages.length > 4 ? 4 : _editSelectedImages.length,
                                          itemBuilder: (context, index) {
                                            if (index >= _editSelectedImages.length) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                              );
                                            }
                                            final img = _editSelectedImages[index];
                                            return Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: img.file != null
                                                      ? Image.file(img.file!, fit: BoxFit.cover)
                                                      : Image.network(img.url!, fit: BoxFit.cover),
                                                ),
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () => _removeEditImage(index),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(2),
                                                      decoration: const BoxDecoration(
                                                        color: Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (index == 3 && _editSelectedImages.length > 4)
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.6),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '+${_editSelectedImages.length - 4}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
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
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: _cancelEditPost,
                                      child: Text(l10n.cancel),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _addEditImage(),
                                      child: Icon(Icons.attach_file, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_canUpdatePost())
                                      TextButton(
                                        onPressed: () => _updatePost(post['id']),
                                        child: Text(l10n.update, style: AppTheme.bodyMedium),
                                      ),
                                  ],
                                ),
                              ],
                              // Do NOT show the normal post content or media grid if editing
                              if (_editingPostId != post['id']) ...[
                                _buildPostContent(post['content'] ?? '', post['id'], l10n),
                                if (post['media'] != null && (post['media'] as List).isNotEmpty)
                                  _buildMediaGrid(post['media'], post['id']),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
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

class EditableImage {
  final String? url;
  final File? file;
  EditableImage.network(this.url) : file = null;
  EditableImage.file(this.file) : url = null;
} 
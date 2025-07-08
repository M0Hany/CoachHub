import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/constants/enums.dart';
import '../../core/widgets/chat_preview_bubble.dart';
import '../../core/network/http_client.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../l10n/app_localizations.dart';

class ChatsScreen extends StatefulWidget {
  final UserRole userRole;
  
  const ChatsScreen({
    super.key,
    required this.userRole,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _isLoading = true;
  String? _error;
  List<ChatData> _chats = [];

  @override
  void initState() {
    super.initState();
    _fetchChats();
    
    // Listen for new messages to refresh chat list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      // Initialize chat provider if not already done
      if (!chatProvider.isConnected) {
        chatProvider.initialize();
      }
      
      // Set up listener for new messages to refresh chat list
      chatProvider.addListener(_onChatProviderChanged);
    });
  }

  @override
  void dispose() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.removeListener(_onChatProviderChanged);
    super.dispose();
  }

  void _onChatProviderChanged() {
    // Refresh chat list when new messages arrive
    if (mounted) {
      _fetchChats();
    }
  }

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final httpClient = HttpClient();
      final response = await httpClient.get<Map<String, dynamic>>('/api/chat');

      if (response.data?['status'] == 'success') {
        final chatsData = response.data!['data']['chats'] as List<dynamic>;
        final chats = chatsData.map((chat) => ChatData.fromJson(chat)).toList();
        
        setState(() {
          _chats = chats;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.data?['message'] ?? 'Failed to fetch chats';
          _isLoading = false;
        });
      }
    } catch (e) {
      developer.log('Error fetching chats: $e', name: 'ChatsScreen');
      setState(() {
        _error = 'Failed to load chats';
        _isLoading = false;
      });
    }
  }

  String _formatTimeAgo(String createdAt) {
    try {
      final createdDate = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDate);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 30) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months} month${months > 1 ? 's' : ''} ago';
      } else {
        final years = (difference.inDays / 365).floor();
        return '${years} year${years > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                      l10n.messages,
                      style: AppTheme.screenTitle,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: RefreshIndicator(
                      onRefresh: _fetchChats,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _error != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _error!,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: _fetchChats,
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                )
                              : _chats.isEmpty
                                  ? SingleChildScrollView(
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.6,
                                        child: Center(
                                          child: Text(
                                            l10n.noChatsYet,
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: ListView.builder(
                                        itemCount: _chats.length,
                                        itemBuilder: (context, index) {
                                          final chat = _chats[index];
                                          final isLastItem = index == _chats.length - 1;
                            
                          return Padding(
                            padding: EdgeInsets.only(bottom: isLastItem ? 24.0 : 0),
                            child: ChatPreviewBubble(
                              name: chat.otherUser.fullName,
                              lastMessage: chat.lastMessage?.content ?? '',
                              time: _formatTimeAgo(chat.lastMessage?.createdAt ?? ''),
                              imageUrl: chat.otherUser.fullImageUrl,
                              unread: chat.unreadCount > 0,
                              unreadCount: chat.unreadCount,
                              onTap: () {
                                final authProvider = context.read<AuthProvider>();
                                context.push(
                                  '/chat/room/${chat.otherUser.id}',
                                  extra: {
                                    'recipientId': chat.otherUser.id.toString(),
                                    'recipientName': chat.otherUser.fullName,
                                    'chatId': chat.chatId.toString(),
                                  },
                                );
                              },
                            ),
                          );
                        },
                                      ),
                                    ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                role: widget.userRole,
                currentIndex: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chat data models
class ChatData {
  final int chatId;
  final UserData otherUser;
  final MessageData? lastMessage;
  final int unreadCount;

  ChatData({
    required this.chatId,
    required this.otherUser,
    required this.lastMessage,
    required this.unreadCount,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      chatId: json['chat_id'] as int,
      otherUser: UserData.fromJson(json['other_user'] as Map<String, dynamic>),
      lastMessage: json['last_message'] != null
          ? MessageData.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int,
    );
  }
}

class UserData {
  final int id;
  final String fullName;
  final String? imageUrl;

  UserData({
    required this.id,
    required this.fullName,
    this.imageUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  String? get fullImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return null;
    }
    return imageUrl!.startsWith('http') 
        ? imageUrl 
        : 'https://coachhub-production.up.railway.app/$imageUrl';
  }
}

class MessageData {
  final int id;
  final String content;
  final int senderId;
  final int receiverId;
  final String createdAt;

  MessageData({
    required this.id,
    required this.content,
    required this.senderId,
    required this.receiverId,
    required this.createdAt,
  });

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData(
      id: json['id'] as int,
      content: json['content'] as String,
      senderId: json['sender_id'] as int,
      receiverId: json['receiver_id'] as int,
      createdAt: json['created_at'] as String,
    );
  }
} 
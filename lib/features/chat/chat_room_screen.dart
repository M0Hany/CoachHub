import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/bottom_nav_bar.dart';
import '../../core/constants/enums.dart';
import '../../core/widgets/chat_message_bubble.dart';
import '../../core/providers/chat_provider.dart';
import '../../core/models/chat_models.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../core/theme/app_colors.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../../core/services/token_service.dart';
import '../../l10n/app_localizations.dart';

class ChatRoomScreen extends StatefulWidget {
  final String recipientId;
  final String recipientName;
  final String? chatId;

  const ChatRoomScreen({
    Key? key,
    required this.recipientId,
    required this.recipientName,
    this.chatId,
  }) : super(key: key);

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  String? _otherUserImageUrl;
  String? _currentUserImageUrl;
  bool _isLoadingHistory = false;
  bool _hasFetchedHistory = false;
  bool _initialScrollDone = false;
  int _lastMessageCount = 0;
  bool _isPaginating = false;
  double? _prevScrollOffset;
  double? _prevMaxScrollExtent;
  bool _showNewMessageIndicator = false;
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchChatHistoryAndInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollController.removeListener(_onScroll);
    _scrollController.addListener(_onScrollController);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  /// Handle new messages with smart auto-scroll behavior
  void _handleNewMessages(int newMessageCount) {
    if (newMessageCount <= 0) return;
    
    // Check if user is near the bottom (within 100 pixels)
    bool isAtBottom = _scrollController.hasClients && 
                     _scrollController.position.pixels >= 
                     _scrollController.position.maxScrollExtent - 100;
    
    if (isAtBottom) {
      // User is at bottom, auto-scroll to show new messages
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      // Hide new message indicator if it was showing
      if (_showNewMessageIndicator) {
        setState(() {
          _showNewMessageIndicator = false;
        });
      }
    } else {
      // User is not at bottom, show new message indicator
      setState(() {
        _showNewMessageIndicator = true;
      });
    }
  }

  /// Scroll to bottom and hide new message indicator
  void _scrollToBottomAndHideIndicator() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    setState(() {
      _showNewMessageIndicator = false;
    });
  }

  /// Build animated typing dot
  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: BoxDecoration(
            color: Colors.white70.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        // Restart animation
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleTyping(String text) {
    final chatProvider = context.read<ChatProvider>();
    
    // Cancel previous timer
    _typingTimer?.cancel();
    
    // Send typing status
    chatProvider.sendTypingStatus(widget.recipientId, true);
    
    // Set timer to stop typing after 1.5 seconds (matching JavaScript)
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      chatProvider.sendTypingStatus(widget.recipientId, false);
    });
    setState(() {}); // Update UI so send icon appears as soon as user types
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final chatProvider = context.read<ChatProvider>();
    
    // Clear input first
    _messageController.clear();
    
    // Stop typing
    _typingTimer?.cancel();
    chatProvider.sendTypingStatus(widget.recipientId, false);
    
    // Send message
    chatProvider.sendMessage(widget.recipientId, message);
    
    // Scroll to bottom after the UI has been rebuilt with the new message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _onScroll() {
    final chatProvider = context.read<ChatProvider>();
    if (_scrollController.position.pixels <= 100 && chatProvider.hasMore && !chatProvider.isLoadingMore) {
      developer.log('[ChatRoom] Triggering fetchOlderMessages (infinite scroll)', name: 'ChatRoomScreen');
      chatProvider.fetchOlderMessages(
        otherUserId: chatProvider.otherUserId!,
      );
    }
  }

  void _onScrollController() async {
    if (_scrollController.position.pixels <= 100) {
      final chatProvider = context.read<ChatProvider>();
      if (chatProvider.hasMore && !chatProvider.isLoadingMore && !_isPaginating) {
        // Record scroll offset and maxScrollExtent before loading more
        final beforeLoadScrollOffset = _scrollController.hasClients ? _scrollController.position.pixels : null;
        final beforeLoadContentHeight = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : null;
        setState(() { _isPaginating = true; });
        await chatProvider.fetchOlderMessages(
          otherUserId: chatProvider.otherUserId!,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (beforeLoadScrollOffset != null && beforeLoadContentHeight != null && _scrollController.hasClients) {
            final afterLoadContentHeight = _scrollController.position.maxScrollExtent;
            final offsetDiff = afterLoadContentHeight - beforeLoadContentHeight;
            _scrollController.jumpTo(_scrollController.position.pixels + offsetDiff);
          }
          if (mounted) setState(() { _isPaginating = false; });
        });
      }
    }
  }

  Future<void> _fetchChatHistoryAndInit() async {
    setState(() { _isLoadingHistory = true; });
    try {
      final tokenService = TokenService();
      final token = await tokenService.getToken();
      if (token == null) {
        developer.log('[ChatRoom] No token, skipping fetch', name: 'ChatRoomScreen');
        setState(() { _isLoadingHistory = false; });
        return;
      }
      final otherUserId = int.tryParse(widget.recipientId) ?? 0;
      developer.log('[ChatRoom] Fetching chat history for $otherUserId', name: 'ChatRoomScreen');
      final dio = Dio();
      final response = await dio.get(
        'https://coachhub-production.up.railway.app/api/chat/$otherUserId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      developer.log('[ChatRoom] Response: \nStatus: \${response.statusCode}\nData: \${response.data}', name: 'ChatRoomScreen');
      if (response.data['status'] == 'success') {
        final data = response.data['data']['messages'];
        final List messages = (data['messages'] ?? []) as List;
        final int currentPage = data['pagination']?['currentPage'] ?? 1;
        final int totalPages = data['pagination']?['totalPages'] ?? 1;
        // Reverse so oldest is at the top, newest at the bottom
        final reversedMessages = List.from(messages.reversed);
        final chatProvider = context.read<ChatProvider>();
        chatProvider.setCurrentChat(widget.recipientId);
        chatProvider.loadChatHistoryFromApi(
          reversedMessages,
          otherUserId,
          currentPage: currentPage,
          totalPages: totalPages,
          replace: true,
        );
        _hasFetchedHistory = true;
      }
    } catch (e, st) {
      developer.log('[ChatRoom] Error fetching chat history: $e', name: 'ChatRoomScreen', error: e, stackTrace: st);
    } finally {
      setState(() { _isLoadingHistory = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final radius = const Radius.circular(30);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        body: Directionality(
          textDirection: TextDirection.ltr, // Force LTR for chat interface
          child: Stack(
          children: [
            Column(
        children: [
                // Extended AppBar
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 32,
                    left: 24,
                    right: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppTheme.accent),
                            onPressed: () => context.pop(),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                widget.recipientName,
                                style: AppTheme.screenTitle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                      // Typing indicator - always reserve space
                      SizedBox(
                        height: 32, // Fixed height to prevent app bar expansion
                        child: Consumer<ChatProvider>(
                          builder: (context, chatProvider, child) {
                            final isTyping = chatProvider.typingUsers[widget.recipientId] == true;
                            
                            if (isTyping) {
                              return AnimatedOpacity(
                                opacity: isTyping ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Typing',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                          fontFamily: 'Alexandria',
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildTypingDot(0),
                                            _buildTypingDot(1),
                                            _buildTypingDot(2),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Chat container
          Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.mainBackgroundColor,
                      borderRadius: BorderRadius.vertical(top: radius),
                    ),
                    child: _isLoadingHistory
                        ? const Center(child: CircularProgressIndicator())
                        : Consumer<ChatProvider>(
                            builder: (context, chatProvider, child) {
                              if (chatProvider.isLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (chatProvider.messages.isEmpty) {
                                return Center(
                                  child: Text(
                                    l10n.noMessagesYet,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              // Check for new messages and handle auto-scroll
                              if (chatProvider.messages.length != _previousMessageCount) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _handleNewMessages(chatProvider.messages.length - _previousMessageCount);
                                  _previousMessageCount = chatProvider.messages.length;
                                });
                              }
                              
                              // Scroll to bottom after initial load
                              if (!_initialScrollDone) {
                                _initialScrollDone = true;
                                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                              }
                              
                              // Show loading indicator at the top and hide list while paginating
                              return Stack(
                                children: [
                                  AnimatedOpacity(
                                    opacity: _isPaginating ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 120),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.only(top: 24, left: 14, right: 14, bottom: 100),
                                      reverse: false,
                                      itemCount: chatProvider.messages.length,
                                      itemBuilder: (context, index) {
                                        final message = chatProvider.messages[index];
                                        final isLeft = message.senderId == chatProvider.otherUserId;
                                        developer.log('[ChatRoom] Message ${message.id} sender_id=${message.senderId} otherUserId=${chatProvider.otherUserId} isLeft=$isLeft', name: 'ChatRoomScreen');
                                        final isRtl = RegExp(r'^[\u0600-\u06FF]').hasMatch(message.content);
                                        return ChatMessageBubble(
                                          message: message.content,
                                          isMe: !isLeft,
                                          time: _formatTime(message.createdAt),
                                          imageUrl: isLeft ? _otherUserImageUrl : _currentUserImageUrl,
                                          isRtl: isRtl,
                                        );
                                      },
                                    ),
                                  ),
                                  if (_isPaginating)
                                    Positioned(
                                      top: 16,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black12,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  // New message indicator
                                  if (_showNewMessageIndicator)
                                    Positioned(
                                      bottom: 16,
                                      right: 16,
                                      child: FloatingActionButton(
                                        mini: true,
                                        backgroundColor: AppColors.primary,
                                        child: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.white,
                                        ),
                                        onPressed: _scrollToBottomAndHideIndicator,
                                      ),
                                    ),
                                ],
                              );
              },
            ),
          ),
                ),
              ],
            ),
            // Message input
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                    ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                                onChanged: _handleTyping,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Alexandria',
                                ),
                                decoration: InputDecoration(
                                  hintText: l10n.messageHint,
                              border: InputBorder.none,
                                  hintStyle: const TextStyle(
                                    color: Colors.black54,
                                    fontFamily: 'Alexandria',
                                  ),
                                  fillColor: Colors.grey[100],
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                                maxLines: 1,
                                textAlignVertical: TextAlignVertical.center,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: _messageController.text.trim().isNotEmpty
                                  ? IconButton(
                                      key: ValueKey('send'),
                                      icon: Icon(Icons.send, color: Colors.black),
                                      onPressed: _sendMessage,
                                    )
                                  : SizedBox(width: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
} 
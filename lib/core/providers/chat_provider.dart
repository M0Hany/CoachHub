import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import '../services/socket_service.dart';
import '../services/chat_service.dart';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../services/token_service.dart';

class ChatProvider extends ChangeNotifier {
  final SocketService _socketService = SocketService();
  final ChatService _chatService = ChatService();
  
  // Chat state - matching JavaScript structure
  List<MessageModel> _messages = [];
  Map<String, bool> _typingUsers = {}; // Track typing status by user ID
  bool _isLoading = false;
  String? _error;
  
  // Current chat context - matching JavaScript
  String? _currentRecipientId; // recipientId like JavaScript
  int? _otherUserId;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  
  // Getters
  List<MessageModel> get messages => _messages;
  Map<String, bool> get typingUsers => _typingUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isConnected => _socketService.isConnected;
  bool get isConnecting => _socketService.isConnecting;
  String? get currentRecipientId => _currentRecipientId;
  int? get otherUserId => _otherUserId;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  
  /// Initialize chat provider and connect to Socket.IO
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Setup socket event handlers
      _socketService.onPrivateMessageReceived = _handlePrivateMessage;
      _socketService.onTypingEventReceived = _handleTypingEvent;
      _socketService.onConnectionEstablished = _handleConnectionEstablished;
      _socketService.onConnectionError = _handleConnectionError;
      _socketService.onDisconnected = _handleDisconnected;
      
      // Connect to Socket.IO
      await _socketService.connect();
      
      developer.log('Chat provider initialized successfully', name: 'ChatProvider');
      
    } catch (e) {
      developer.log('Error initializing chat provider: $e', name: 'ChatProvider', error: e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if Socket.IO is connected, if not, try to connect
  Future<void> ensureConnected() async {
    if (!_socketService.isConnected && !_socketService.isConnecting) {
      developer.log('Socket not connected, attempting to connect...', name: 'ChatProvider');
      await _socketService.connect();
    }
  }

  /// Handle incoming private messages (matching JavaScript structure)
  void _handlePrivateMessage(PrivateMessageEvent event) {
    developer.log('Handling private message: ${event.toJson()}', name: 'ChatProvider');
    
    // Always notify that new messages have arrived (for chat list refresh)
    // This ensures the chat list updates even for messages from other users
    notifyNewMessages();
    
    // Only add message to current chat if it's from the current recipient
    if (event.from == _currentRecipientId) {
      // Add message to the current chat
      final message = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
        content: event.content,
        senderId: int.tryParse(event.from ?? '') ?? 0,
        chatId: 0, // We don't use chatId in this structure
        createdAt: DateTime.now(),
      );
      
      _messages.add(message);
      notifyListeners();
      
      developer.log('Added message to chat: ${message.content}', name: 'ChatProvider');
    } else {
      developer.log('Message from ${event.from} - updating chat list only, current recipient: $_currentRecipientId', name: 'ChatProvider');
    }
  }

  /// Handle message delivery confirmation (optional)
  void _handleMessageDelivered(String messageId) {
    developer.log('Message delivered: $messageId', name: 'ChatProvider');
    // You can update message status here if needed
  }

  /// Handle typing events (matching JavaScript structure)
  void _handleTypingEvent(TypingEvent event) {
    developer.log('Handling typing event: ${event.toJson()}', name: 'ChatProvider');
    
    // Only handle typing events for current recipient
    if (event.from == _currentRecipientId) {
      // Update typing status for the user
      _typingUsers[event.from ?? ''] = event.isTyping;
      notifyListeners();
      
      // Clear typing status after a delay if typing stopped
      if (!event.isTyping) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_typingUsers[event.from ?? ''] == false) {
            _typingUsers.remove(event.from ?? '');
            notifyListeners();
          }
        });
      }
    }
  }

  /// Handle successful connection
  void _handleConnectionEstablished() {
    developer.log('Socket.IO connection established', name: 'ChatProvider');
    notifyListeners();
  }

  /// Handle connection errors
  void _handleConnectionError(String error) {
    developer.log('Socket.IO connection error: $error', name: 'ChatProvider');
    _error = error;
    notifyListeners();
  }

  /// Handle disconnection
  void _handleDisconnected() {
    developer.log('Socket.IO disconnected', name: 'ChatProvider');
    notifyListeners();
  }

  /// Send a message (matching JavaScript structure)
  Future<void> sendMessage(String to, String content) async {
    developer.log('🚀 ChatProvider.sendMessage called with to: $to, content: $content', name: 'ChatProvider');
    
    try {
      // Ensure Socket.IO is connected
      developer.log('🔌 Ensuring Socket.IO connection...', name: 'ChatProvider');
      await ensureConnected();
      
      developer.log('🔌 Socket connected: ${_socketService.isConnected}', name: 'ChatProvider');
      
      if (!_socketService.isConnected) {
        throw Exception('Socket not connected after connection attempt');
      }
      
      // Create a temporary message for immediate UI update
      final tempMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch,
        content: content,
        senderId: 0, // Will be updated when we receive confirmation
        chatId: 0,
        createdAt: DateTime.now(),
      );
      
      // Add message to UI immediately for instant feedback
      _messages.add(tempMessage);
      notifyListeners();
      
      developer.log('📤 ChatProvider calling _socketService.sendPrivateMessage($to, $content)', name: 'ChatProvider');
      
      // Send via Socket.IO (matching JavaScript structure)
      _socketService.sendPrivateMessage(to, content);
      
      developer.log('✅ Message sent successfully via Socket.IO', name: 'ChatProvider');
      
    } catch (e) {
      developer.log('❌ Error sending message: $e', name: 'ChatProvider', error: e);
      rethrow;
    }
  }

  /// Send typing status (matching JavaScript structure)
  void sendTypingStatus(String to, bool isTyping) {
    if (!_socketService.isConnected) return;
    
    _socketService.sendTypingStatus(to, isTyping);
  }

  /// Set current chat context (matching JavaScript structure)
  void setCurrentChat(String recipientId) {
    developer.log('Setting current chat to recipient: $recipientId', name: 'ChatProvider');
    _currentRecipientId = recipientId;
    _messages.clear(); // Clear messages when switching chats
    _typingUsers.clear(); // Clear typing status
    notifyListeners();
  }

  /// Load chat history from API
  Future<void> loadChatHistory(String chatId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Fetch chat history from API
      final messages = await _chatService.fetchChatHistory(chatId);
      
      // Store messages in local state
      _messages = messages;
      
      developer.log('Loaded ${messages.length} messages for chat $chatId', name: 'ChatProvider');
      
    } catch (e) {
      developer.log('Error loading chat history: $e', name: 'ChatProvider', error: e);
      // Initialize empty message list if API fails
      _messages = [];
      // Don't rethrow the error, just log it and continue with empty messages
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear current chat
  void clearCurrentChat() {
    _messages.clear();
    _typingUsers.clear();
    _currentRecipientId = null;
    notifyListeners();
  }

  /// Clear all chat data
  void clearAllChats() {
    _messages.clear();
    _typingUsers.clear();
    _currentRecipientId = null;
    notifyListeners();
  }

  /// Notify that new messages have arrived (for chat list refresh)
  void notifyNewMessages() {
    developer.log('Notifying new messages arrived', name: 'ChatProvider');
    notifyListeners();
  }

  /// Reconnect to Socket.IO
  Future<void> reconnect() async {
    await _socketService.reconnect();
  }

  /// Disconnect from Socket.IO
  void disconnect() {
    _socketService.disconnect();
  }

  /// Test socket connection
  void testConnection() {
    developer.log('🧪 Testing socket connection...', name: 'ChatProvider');
    _socketService.sendPing();
  }

  /// Test private message
  void testPrivateMessage() {
    developer.log('🧪 Testing private message...', name: 'ChatProvider');
    _socketService.testPrivateMessage();
  }

  /// Load chat history from a raw API message list (as returned by /api/chat/{id})
  void loadChatHistoryFromApi(List<dynamic> messages, int otherUserId, {int? currentPage, int? totalPages, bool replace = true}) {
    final parsedMessages = messages.map((msg) {
      return MessageModel(
        id: msg['id'] as int,
        content: msg['content'] as String,
        senderId: msg['sender_id'] as int,
        chatId: 0, // Not used
        createdAt: DateTime.tryParse(msg['created_at'] ?? '') ?? DateTime.now(),
      );
    }).toList();
    if (replace) {
      _messages = parsedMessages;
    } else {
      _messages = [...parsedMessages, ..._messages]; // Prepend older messages
    }
    _otherUserId = otherUserId;
    if (currentPage != null) _currentPage = currentPage;
    if (totalPages != null) _totalPages = totalPages;
    _hasMore = _currentPage < _totalPages;
    notifyListeners();
  }

  /// Fetch and prepend older messages (pagination)
  Future<void> fetchOlderMessages({required int otherUserId}) async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final tokenService = TokenService();
      final token = await tokenService.getToken();
      if (token == null) return;
      final nextPage = _currentPage + 1;
      developer.log('[ChatProvider] Fetching older messages: page $nextPage', name: 'ChatProvider');
      final dio = Dio();
      final response = await dio.get(
        'https://coachhub-production.up.railway.app/api/chat/$otherUserId?page=$nextPage',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['status'] == 'success') {
        final data = response.data['data']['messages'];
        final List messages = (data['messages'] ?? []) as List;
        final int totalPages = data['pagination']?['totalPages'] ?? 1;
        final int currentPage = data['pagination']?['currentPage'] ?? nextPage;
        final reversedMessages = List.from(messages.reversed);
        loadChatHistoryFromApi(reversedMessages, otherUserId, currentPage: currentPage, totalPages: totalPages, replace: false);
        developer.log('[ChatProvider] Older messages loaded: page $currentPage / $totalPages', name: 'ChatProvider');
      }
    } catch (e, st) {
      developer.log('[ChatProvider] Error fetching older messages: $e', name: 'ChatProvider', error: e, stackTrace: st);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }


  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
} 
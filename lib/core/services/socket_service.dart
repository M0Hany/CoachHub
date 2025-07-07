import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../models/chat_models.dart';
import 'token_service.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class SocketService extends ChangeNotifier {
  static const String _socketUrl = 'https://coachhub-production.up.railway.app';
  
  IO.Socket? _socket;
  final TokenService _tokenService = TokenService();
  
  bool _isConnected = false;
  bool _isConnecting = false;
  int? _currentUserId; // Track current user ID like JavaScript
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  IO.Socket? get socket => _socket;
  int? get currentUserId => _currentUserId;
  
  // Callbacks for chat events
  Function(PrivateMessageEvent)? onPrivateMessageReceived;
  Function(TypingEvent)? onTypingEventReceived;
  Function()? onConnectionEstablished;
  Function(String)? onConnectionError;
  Function()? onDisconnected;

  /// Initialize and connect to Socket.IO server with JWT authentication
  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    
    try {
      _isConnecting = true;
      notifyListeners();
      
      // Get JWT token
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      // Extract user ID from JWT token (matching JavaScript structure)
      _currentUserId = _extractUserIdFromToken(token);
      
      developer.log('Connecting to Socket.IO server as User $_currentUserId...', name: 'SocketService');
      
      // Create socket connection with JWT authentication (matching JavaScript)
      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token}) // Remove 'Bearer ' prefix to match JavaScript
            .build(),
      );
      
      _setupSocketListeners();
      _socket!.connect();
      
    } catch (e) {
      _isConnecting = false;
      notifyListeners();
      developer.log('Error connecting to Socket.IO: $e', name: 'SocketService', error: e);
      onConnectionError?.call(e.toString());
      rethrow;
    }
  }

  /// Extract user ID from JWT token (simple implementation)
  int? _extractUserIdFromToken(String token) {
    try {
      // Simple JWT parsing - in production, use a proper JWT library
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        // Add padding if needed
        final paddedPayload = payload + '=' * (4 - payload.length % 4);
        final decoded = base64Url.decode(paddedPayload);
        final payloadString = String.fromCharCodes(decoded);
        final payloadMap = json.decode(payloadString);
        return payloadMap['id'] as int?;
      }
    } catch (e) {
      developer.log('Error parsing JWT token: $e', name: 'SocketService');
    }
    return null;
  }

  /// Setup all socket event listeners
  void _setupSocketListeners() {
    if (_socket == null) return;
    
    // Connection events
    _socket!.onConnect((_) {
      developer.log('✅ Socket.IO connected successfully', name: 'SocketService');
      _isConnected = true;
      _isConnecting = false;
      notifyListeners();
      onConnectionEstablished?.call();
    });
    
    _socket!.onConnectError((error) {
      developer.log('❌ Socket.IO connection error: $error', name: 'SocketService');
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();
      onConnectionError?.call(error.toString());
    });
    
    _socket!.onDisconnect((_) {
      developer.log('⚠️ Socket.IO disconnected', name: 'SocketService');
      _isConnected = false;
      _isConnecting = false;
      notifyListeners();
      onDisconnected?.call();
    });
    
    // Chat events
    _socket!.on('private_message', (data) {
      developer.log('📩 Received private message: $data', name: 'SocketService');
      try {
        final messageEvent = PrivateMessageEvent.fromJson(data);
        onPrivateMessageReceived?.call(messageEvent);
      } catch (e) {
        developer.log('Error parsing private message: $e', name: 'SocketService', error: e);
      }
    });
    
    _socket!.on('typing', (data) {
      developer.log('⌨️ Received typing event: $data', name: 'SocketService');
      try {
        final typingEvent = TypingEvent.fromJson(data);
        onTypingEventReceived?.call(typingEvent);
      } catch (e) {
        developer.log('Error parsing typing event: $e', name: 'SocketService', error: e);
      }
    });
    
    // Error handling
    _socket!.onError((error) {
      developer.log('Socket.IO error: $error', name: 'SocketService', error: error);
    });
  }

  /// Send a private message (matching JavaScript structure)
  void sendPrivateMessage(String to, String content) {
    if (!_isConnected || _socket == null) {
      developer.log('Cannot send message: Socket not connected', name: 'SocketService');
      return;
    }
    
    final messageEvent = PrivateMessageEvent(
      to: to,
      content: content,
    );
    
    developer.log('📤 Sending private message: ${messageEvent.toJson()}', name: 'SocketService');
    _socket!.emit('private_message', messageEvent.toJson());
  }

  /// Send typing status
  void sendTypingStatus(String to, bool isTyping) {
    if (!_isConnected || _socket == null) {
      developer.log('Cannot send typing status: Socket not connected', name: 'SocketService');
      return;
    }
    
    final typingEvent = TypingEvent(
      to: to,
      isTyping: isTyping,
    );
    
    developer.log('⌨️ Sending typing status: ${typingEvent.toJson()}', name: 'SocketService');
    _socket!.emit('typing', typingEvent.toJson());
  }

  /// Disconnect from Socket.IO server
  void disconnect() {
    if (_socket != null) {
      developer.log('Disconnecting from Socket.IO server...', name: 'SocketService');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    
    _isConnected = false;
    _isConnecting = false;
    notifyListeners();
  }

  /// Reconnect to Socket.IO server
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
} 
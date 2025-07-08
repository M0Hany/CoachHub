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
  
  // Getters
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  IO.Socket? get socket => _socket;
  
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

      developer.log('🔑 Using JWT token: ${token.substring(0, 20)}...', name: 'SocketService');

      // Create socket connection with JWT authentication (matching JavaScript exactly)
      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token}) // Match JavaScript: auth: { token }
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

  // Removed JWT token extraction as it's not needed

  /// Setup all socket event listeners
  void _setupSocketListeners() {
    if (_socket == null) return;
    
    // Connection events
    _socket!.onConnect((_) {
      developer.log('✅ Socket.IO connected successfully', name: 'SocketService');
      developer.log('✅ Socket ID: ${_socket!.id}', name: 'SocketService');
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
    
    // Chat events - match JavaScript exactly
    _socket!.on('private_message', (data) {
      developer.log('📩 Received private_message event: $data', name: 'SocketService');
      _handleIncomingMessage(data, 'private_message');
    });
    
    // Listen for any event to debug what's being received
    _socket!.onAny((event, data) {
      developer.log('🔍 Received any event: $event with data: $data', name: 'SocketService');
    });
    
    // Listen for pong response
    _socket!.on('pong', (data) {
      developer.log('🏓 Received pong: $data', name: 'SocketService');
    });
    
    _socket!.on('typing', (data) {
      developer.log('⌨️ Received typing event: $data', name: 'SocketService');
      try {
        // Match JavaScript: socket.on("typing", ({ from, isTyping }) => { ... });
        if (data is Map<String, dynamic>) {
          final from = data['from']?.toString();
          final isTyping = data['isTyping'] as bool?;
          
          if (from != null && isTyping != null) {
            final typingEvent = TypingEvent(
              from: from,
              isTyping: isTyping,
              to: null,
            );
            onTypingEventReceived?.call(typingEvent);
          }
        }
      } catch (e) {
        developer.log('Error parsing typing event: $e', name: 'SocketService', error: e);
      }
    });
    
    // Error handling
    _socket!.onError((error) {
      developer.log('Socket.IO error: $error', name: 'SocketService', error: error);
    });
  }

  /// Handle incoming messages from different event types
  void _handleIncomingMessage(dynamic data, String eventName) {
    developer.log('📩 Processing $eventName event with data: $data', name: 'SocketService');
    
    try {
      // Match JavaScript: socket.on("private_message", ({ from, content }) => { ... });
      if (data is Map<String, dynamic>) {
        final from = data['from']?.toString();
        final content = data['content']?.toString();
        
        if (from != null && content != null) {
          final messageEvent = PrivateMessageEvent(
            from: from,
            content: content,
            to: null, // Not needed for incoming messages
          );
          
          developer.log('📩 Successfully parsed message from $from: $content', name: 'SocketService');
          onPrivateMessageReceived?.call(messageEvent);
          return;
        }
      }
      
      // If it's not a Map, try to convert it
      if (data is String) {
        try {
          final jsonData = jsonDecode(data);
          final from = jsonData['from']?.toString();
          final content = jsonData['content']?.toString();
          
          if (from != null && content != null) {
            final messageEvent = PrivateMessageEvent(
              from: from,
              content: content,
              to: null,
            );
            
            developer.log('📩 Successfully parsed string message from $from: $content', name: 'SocketService');
            onPrivateMessageReceived?.call(messageEvent);
            return;
          }
        } catch (e) {
          developer.log('📩 Failed to parse string data as JSON: $e', name: 'SocketService');
        }
      }
      
      // If all else fails, log the raw data
      developer.log('📩 Could not parse message data: $data (type: ${data.runtimeType})', name: 'SocketService');
      
    } catch (e) {
      developer.log('📩 Error parsing message from $eventName: $e', name: 'SocketService', error: e);
    }
  }

  /// Send a private message (matching JavaScript structure)
  void sendPrivateMessage(String to, String content) {
    developer.log('📤 Attempting to send private message to $to: $content', name: 'SocketService');
    developer.log('📤 Socket connected: $_isConnected, Socket null: ${_socket == null}', name: 'SocketService');
    
    if (!_isConnected || _socket == null) {
      developer.log('❌ Cannot send message: Socket not connected', name: 'SocketService');
      // Try to reconnect and send
      connect().then((_) {
        if (_isConnected && _socket != null) {
          _sendMessageAfterConnection(to, content);
        }
      });
      return;
    }
    
    _sendMessageAfterConnection(to, content);
  }

  void _sendMessageAfterConnection(String to, String content) {
    // Match JavaScript exactly: socket.emit("private_message", { to: recipientId, content: message });
    final messageData = {
      'to': to,
      'content': content,
    };
    
    developer.log('📤 Sending private message: $messageData', name: 'SocketService');
    _socket!.emit('private_message', messageData);
  }

  /// Send typing status
  void sendTypingStatus(String to, bool isTyping) {
    if (!_isConnected || _socket == null) {
      developer.log('Cannot send typing status: Socket not connected', name: 'SocketService');
      return;
    }
    
    // Match JavaScript: socket.emit("typing", { to: recipientId, isTyping: true/false });
    final typingData = {
      'to': to,
      'isTyping': isTyping,
    };
    
    developer.log('⌨️ Sending typing status: $typingData', name: 'SocketService');
    _socket!.emit('typing', typingData);
  }

  /// Test socket connection by sending a ping
  void sendPing() {
    if (!_isConnected || _socket == null) {
      developer.log('Cannot send ping: Socket not connected', name: 'SocketService');
      return;
    }
    
    developer.log('🏓 Sending ping to test connection', name: 'SocketService');
    _socket!.emit('ping', {'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  /// Test private message by sending to self
  void testPrivateMessage() {
    if (!_isConnected || _socket == null) {
      developer.log('Cannot test message: Socket not connected', name: 'SocketService');
      return;
    }
    
    developer.log('🧪 Testing private message to self', name: 'SocketService');
    final testData = {
      'to': '30', // Test with your own ID
      'content': 'Test message from Flutter',
    };
    _socket!.emit('private_message', testData);
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
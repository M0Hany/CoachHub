import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/chat_provider.dart';
import 'token_service.dart';
import 'dart:developer' as developer;

class ChatInitializationService {
  static final ChatInitializationService _instance = ChatInitializationService._internal();
  factory ChatInitializationService() => _instance;
  ChatInitializationService._internal();

  final TokenService _tokenService = TokenService();

  /// Initialize chat functionality when app starts
  Future<void> initializeChat(BuildContext context) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await _tokenService.isAuthenticated();
      
      if (isAuthenticated) {
        developer.log('User is authenticated, initializing chat...', name: 'ChatInitializationService');
        
        // Initialize chat provider
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        await chatProvider.initialize();
        
        developer.log('Chat initialization completed', name: 'ChatInitializationService');
      } else {
        developer.log('User not authenticated, skipping chat initialization', name: 'ChatInitializationService');
      }
    } catch (e) {
      developer.log('Error initializing chat: $e', name: 'ChatInitializationService', error: e);
    }
  }

  /// Disconnect chat when user logs out
  void disconnectChat(BuildContext context) {
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      chatProvider.disconnect();
      developer.log('Chat disconnected', name: 'ChatInitializationService');
    } catch (e) {
      developer.log('Error disconnecting chat: $e', name: 'ChatInitializationService', error: e);
    }
  }
} 
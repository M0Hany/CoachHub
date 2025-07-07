import 'package:dio/dio.dart';
import '../network/http_client.dart';
import '../models/chat_models.dart';
import 'dart:developer' as developer;

class ChatService {
  final HttpClient _httpClient = HttpClient();

  /// Fetch chat history from the API
  Future<List<MessageModel>> fetchChatHistory(String chatId) async {
    try {
      developer.log('Fetching chat history for chat ID: $chatId', name: 'ChatService');
      
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/chat/$chatId',
      );

      if (response.data?['status'] == 'success') {
        final data = response.data!['data'];
        final messagesData = data['messages']['messages'] as List<dynamic>;
        final chatIdFromResponse = data['messages']['chat_id'] as int;
        
        final messages = messagesData.map((msg) {
          return MessageModel(
            id: msg['id'] as int,
            content: msg['content'] as String,
            senderId: msg['sender_id'] as int,
            chatId: chatIdFromResponse,
            createdAt: DateTime.parse(msg['created_at'] as String),
          );
        }).toList();

        developer.log('Successfully fetched ${messages.length} messages', name: 'ChatService');
        return messages;
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch chat history');
      }
    } catch (e) {
      developer.log('Error fetching chat history: $e', name: 'ChatService', error: e);
      rethrow;
    }
  }

  /// Send a message via API (for persistence)
  Future<MessageModel> sendMessage(String chatId, String content) async {
    try {
      developer.log('Sending message to chat ID: $chatId', name: 'ChatService');
      
      final response = await _httpClient.post<Map<String, dynamic>>(
        '/api/chat/$chatId/messages',
        data: {
          'content': content,
        },
      );

      if (response.data?['status'] == 'success') {
        final messageData = response.data!['data']['message'];
        final message = MessageModel(
          id: messageData['id'] as int,
          content: messageData['content'] as String,
          senderId: messageData['sender_id'] as int,
          chatId: int.parse(chatId),
          createdAt: DateTime.parse(messageData['created_at'] as String),
        );

        developer.log('Message sent successfully', name: 'ChatService');
        return message;
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to send message');
      }
    } catch (e) {
      developer.log('Error sending message: $e', name: 'ChatService', error: e);
      rethrow;
    }
  }
} 
# Socket.IO Integration for CoachHub

This document explains how to use the Socket.IO integration for real-time chat functionality in the CoachHub Flutter application.

## Overview

The Socket.IO integration provides real-time messaging capabilities between coaches and trainees. It includes:

- Real-time message sending and receiving
- Typing indicators
- JWT authentication
- Automatic reconnection handling

## Architecture

### Components

1. **SocketService** (`lib/core/services/socket_service.dart`)
   - Handles Socket.IO connection and events
   - Manages JWT authentication
   - Provides methods for sending messages and typing status

2. **ChatProvider** (`lib/core/providers/chat_provider.dart`)
   - Manages chat state using Provider pattern
   - Integrates with SocketService
   - Handles message storage and UI updates

3. **Chat Models** (`lib/core/models/chat_models.dart`)
   - `ChatModel`: Represents a chat room
   - `MessageModel`: Represents individual messages
   - `PrivateMessageEvent`: Socket.IO event for private messages
   - `TypingEvent`: Socket.IO event for typing indicators

4. **ChatInitializationService** (`lib/core/services/chat_initialization_service.dart`)
   - Handles chat initialization when app starts
   - Manages chat disconnection on logout

## Setup

### 1. Dependencies

The Socket.IO client is already included in `pubspec.yaml`:
```yaml
dependencies:
  socket_io_client: ^2.0.2
```

### 2. Provider Setup

The ChatProvider is already registered in `main.dart`:
```dart
ChangeNotifierProvider<ChatProvider>(
  create: (_) => ChatProvider(),
),
```

### 3. Authentication Integration

The AuthProvider includes methods to initialize and disconnect chat:
```dart
// Initialize chat after successful login
await authProvider.initializeChat(context);

// Disconnect chat on logout
authProvider.disconnectChat(context);
```

## Usage

### 1. Initialize Chat

Chat is automatically initialized when a user logs in. You can also manually initialize it:

```dart
final chatProvider = Provider.of<ChatProvider>(context, listen: false);
await chatProvider.initialize();
```

### 2. Send Messages

```dart
final chatProvider = Provider.of<ChatProvider>(context, listen: false);
await chatProvider.sendMessage(
  receiverId,  // The ID of the person you're sending to
  messageContent,  // The message text
  chatId,  // The chat room ID
);
```

### 3. Send Typing Status

```dart
final chatProvider = Provider.of<ChatProvider>(context, listen: false);
chatProvider.sendTypingStatus(receiverId, true);  // Start typing
chatProvider.sendTypingStatus(receiverId, false); // Stop typing
```

### 4. Listen for Messages

The ChatProvider automatically handles incoming messages and updates the UI. You can access messages in your UI:

```dart
Consumer<ChatProvider>(
  builder: (context, chatProvider, child) {
    final messages = chatProvider.getMessages(chatId);
    final isTyping = chatProvider.isTyping(chatId);
    
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageWidget(message: message);
      },
    );
  },
)
```

### 5. Check Connection Status

```dart
final chatProvider = Provider.of<ChatProvider>(context, listen: false);
if (chatProvider.isConnected) {
  // Socket is connected
} else {
  // Socket is disconnected
}
```

## Socket.IO Events

### Incoming Events

1. **private_message**
   ```json
   {
     "to": "receiver_id",
     "content": "Hello!",
     "chatID": "chat_123"
   }
   ```

2. **typing**
   ```json
   {
     "to": "receiver_id",
     "isTyping": true
   }
   ```

### Outgoing Events

1. **private_message**
   ```json
   {
     "to": "receiver_id",
     "content": "Hello!",
     "chatID": "chat_123"
   }
   ```

2. **typing**
   ```json
   {
     "to": "receiver_id",
     "isTyping": true
   }
   ```

## Configuration

### Socket.IO Server URL

The Socket.IO server URL is configured in `SocketService`:
```dart
static const String _socketUrl = 'https://coachhub-production.up.railway.app:3000';
```

### JWT Authentication

The Socket.IO connection is authenticated using JWT tokens. The token is automatically retrieved from secure storage and sent with the connection:

```dart
_socket = IO.io(
  _socketUrl,
  IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .setAuth({'token': 'Bearer $token'})
      .build(),
);
```

## Error Handling

The Socket.IO integration includes comprehensive error handling:

1. **Connection Errors**: Automatically logged and reported
2. **Message Parsing Errors**: Gracefully handled with logging
3. **Authentication Errors**: Handled by the TokenService
4. **Network Errors**: Automatic reconnection attempts

## Best Practices

1. **Always check connection status** before sending messages
2. **Handle typing indicators properly** with timeouts
3. **Use proper error handling** for failed message sends
4. **Initialize chat only when user is authenticated**
5. **Disconnect chat when user logs out**

## Example Implementation

Here's a complete example of a chat screen:

```dart
class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String chatId;
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.setCurrentChat(widget.chatId);
    chatProvider.loadChatHistory(widget.chatId);
  }
  
  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      await chatProvider.sendMessage(widget.receiverId, message, widget.chatId);
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                final messages = chatProvider.getMessages(widget.chatId);
                
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Troubleshooting

### Common Issues

1. **Socket not connecting**
   - Check if user is authenticated
   - Verify JWT token is valid
   - Check network connectivity

2. **Messages not sending**
   - Verify Socket.IO connection status
   - Check receiver ID format
   - Ensure chat ID is valid

3. **Typing indicators not working**
   - Verify typing event format
   - Check receiver ID
   - Ensure proper timeout handling

### Debug Logging

The integration includes comprehensive logging. Check the console for:
- Connection status messages
- Message sending/receiving logs
- Error messages
- Authentication status

## Security Considerations

1. **JWT Authentication**: All Socket.IO connections are authenticated
2. **Secure Storage**: Tokens are stored securely using Flutter Secure Storage
3. **Input Validation**: Message content should be validated before sending
4. **Rate Limiting**: Consider implementing rate limiting for message sending

## Future Enhancements

1. **Message Encryption**: End-to-end encryption for messages
2. **File Sharing**: Support for sending images and files
3. **Message Status**: Read receipts and delivery status
4. **Push Notifications**: Integration with FCM for offline notifications
5. **Message Search**: Search functionality for chat history 
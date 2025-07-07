class ChatModel {
  final int id;
  final int userAId;
  final int userBId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.userAId,
    required this.userBId,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as int,
      userAId: json['user_a_id'] as int,
      userBId: json['user_b_id'] as int,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_a_id': userAId,
      'user_b_id': userBId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class MessageModel {
  final int id;
  final String content;
  final int senderId;
  final int chatId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.chatId,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      content: json['content'] as String,
      senderId: json['sender_id'] as int,
      chatId: json['chat_id'] as int,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'chat_id': chatId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Socket.IO event models - matching JavaScript structure
class PrivateMessageEvent {
  final String? from; // sender_id (for incoming messages)
  final String? to; // receiver_id (for outgoing messages)
  final String content;

  PrivateMessageEvent({
    this.from,
    this.to,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      if (to != null) 'to': to,
      'content': content,
    };
  }

  factory PrivateMessageEvent.fromJson(Map<String, dynamic> json) {
    return PrivateMessageEvent(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      content: json['content'] as String,
    );
  }
}

class TypingEvent {
  final String? from; // sender_id (for incoming events)
  final String? to; // receiver_id (for outgoing events)
  final bool isTyping;

  TypingEvent({
    this.from,
    this.to,
    required this.isTyping,
  });

  Map<String, dynamic> toJson() {
    return {
      if (to != null) 'to': to,
      'isTyping': isTyping,
    };
  }

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    return TypingEvent(
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      isTyping: json['isTyping'] as bool,
    );
  }
} 
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../core/widgets/chat_message_bubble.dart';

class CoachChatRoomScreen extends StatefulWidget {
  final String traineeId;

  const CoachChatRoomScreen({
    super.key,
    required this.traineeId,
  });

  @override
  State<CoachChatRoomScreen> createState() => _CoachChatRoomScreenState();
}

class _CoachChatRoomScreenState extends State<CoachChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _mockMessages = [
    {
      'message': 'اهلا يا كابتن عايز اعرف خطة التدريب',
      'isMe': false,
      'time': '5:05 PM',
      'imageUrl': 'assets/images/default_profile.jpg',
    },
    {
      'message': 'عايز اعرف وزنك وطولك',
      'isMe': true,
      'time': '5:05 PM',
      'imageUrl': 'assets/images/default_profile.jpg',
    },
    {
      'message': 'الوزن ٨٥ والطول ١٧٥',
      'isMe': false,
      'time': '5:05 PM',
      'imageUrl': 'assets/images/default_profile.jpg',
    },
    {
      'message': 'تمام هبعتلك خطة تدريب وتغذية تناسبك',
      'isMe': true,
      'time': '5:05 PM',
      'imageUrl': 'assets/images/default_profile.jpg',
    },
    {
      'message': '...',
      'isMe': false,
      'time': '5:22 PM',
      'imageUrl': 'assets/images/default_profile.jpg',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D122A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0FF789)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.traineeId,
          style: const TextStyle(
            color: Color(0xFF0FF789),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Today pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Today',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          // Chat messages
          Expanded(
            child: ListView.builder(
              itemCount: _mockMessages.length,
              itemBuilder: (context, index) {
                final message = _mockMessages[index];
                return ChatMessageBubble(
                  message: message['message'] as String,
                  isMe: message['isMe'] as bool,
                  time: message['time'] as String,
                  imageUrl: message['imageUrl'] as String?,
                );
              },
            ),
          ),
          // Message input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0FF789),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'message...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.sentiment_satisfied_alt_outlined),
                          onPressed: () {
                            // TODO: Implement emoji picker
                          },
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // TODO: Implement additional options (send files, images, etc.)
                    },
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
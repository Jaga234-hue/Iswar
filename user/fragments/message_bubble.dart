import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const MessageBubble({
    Key? key,
    required this.text,
    required this.isUser,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                  colors: [Color(0xFF4a4a8a), Color(0xFF3a3a7a)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Color(0xFF2a2a4a), Color(0xFF1a1a3a)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: isUser ? Radius.circular(20) : Radius.circular(4),
                  bottomRight: isUser ? Radius.circular(4) : Radius.circular(20),
                ),
                border: isUser ? null : Border.all(color: Color(0xFF3a3a5a)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarkdownBody(
                    data: text,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        color: isUser ? Colors.white : Color(0xFFe0e0e0),
                        fontSize: 16,
                        height: 1.4,
                      ),
                      code: TextStyle(
                        color: isUser ? Colors.white : Color(0xFFe0e0e0),
                        backgroundColor: isUser
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: isUser
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    _formatTime(timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Color(0xFFa0a0c0),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
          colors: [Color(0xFF4a4a8a), Color(0xFF3a3a7a)],
        )
            : LinearGradient(
          colors: [Color(0xFF2a2a4a), Color(0xFF1a1a3a)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
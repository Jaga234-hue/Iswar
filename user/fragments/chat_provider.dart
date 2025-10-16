import 'package:flutter/foundation.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatHistoryItem {
  final String id;
  final String title;
  final String preview;
  final DateTime date;
  final List<ChatMessage> messages;

  ChatHistoryItem({
    required this.id,
    required this.title,
    required this.preview,
    required this.date,
    required this.messages,
  });
}

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void addUserMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void addBotMessage(String text) {
    _messages.add(ChatMessage(
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  void loadChatHistory(List<ChatMessage> history) {
    _messages = List.from(history);
    notifyListeners();
  }
}
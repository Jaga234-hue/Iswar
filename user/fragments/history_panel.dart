import 'package:flutter/material.dart';
import 'chat_provider.dart';

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

class HistoryPanel extends StatefulWidget {
  final Function(ChatHistoryItem) onSelectHistory;
  final Function onClose;

  const HistoryPanel({
    Key? key,
    required this.onSelectHistory,
    required this.onClose,
  }) : super(key: key);

  @override
  _HistoryPanelState createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel> {
  List<ChatHistoryItem> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    // Mock history data - replace with actual storage
    setState(() {
      _historyItems = [
        ChatHistoryItem(
          id: '1',
          title: 'AI Capabilities',
          preview: 'What can you help me with?',
          date: DateTime.now().subtract(Duration(hours: 2)),
          messages: [],
        ),
        ChatHistoryItem(
          id: '2',
          title: 'Logo Explanation',
          preview: 'Tell me about the Sudarshana Chakra',
          date: DateTime.now().subtract(Duration(days: 1)),
          messages: [],
        ),
        ChatHistoryItem(
          id: '3',
          title: 'Project Ideas',
          preview: 'Need creative project suggestions',
          date: DateTime.now().subtract(Duration(days: 2)),
          messages: [],
        ),
        ChatHistoryItem(
          id: '4',
          title: 'Research Assistance',
          preview: 'Help with my research on AI ethics',
          date: DateTime.now().subtract(Duration(days: 3)),
          messages: [],
        ),
        ChatHistoryItem(
          id: '5',
          title: 'Technical Support',
          preview: 'Having issues with the app',
          date: DateTime.now().subtract(Duration(days: 4)),
          messages: [],
        ),
      ];
    });
  }

  void _startNewChat() {
    widget.onClose();
    // New chat will be started automatically when history panel closes
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0f0f23),
            Color(0xFF1a1a2e),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header - CORRECTED VERSION
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0f0f23),
              border: Border(
                bottom: BorderSide(color: Color(0xFF2a2a3a), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Corrected IconButton
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => widget.onClose(),
                  iconSize: 24,
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 10),
                Text(
                  'Chat History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                // New Chat Button in Header
                ElevatedButton.icon(
                  onPressed: _startNewChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4a4a8a),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    shadowColor: Color(0xFF6464FF).withOpacity(0.3),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  icon: Icon(Icons.add, size: 18),
                  label: Text('New Chat'),
                ),
              ],
            ),
          ),
          // History List
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, 0.2),
                  radius: 1.5,
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF0f0f23),
                  ],
                ),
              ),
              child: _historyItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No chat history',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _historyItems.length,
                itemBuilder: (context, index) {
                  final item = _historyItems[index];
                  return _buildHistoryItem(item);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ChatHistoryItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1e1e2f).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF2a2a3a)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSelectHistory(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  item.preview,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  _formatDate(item.date),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
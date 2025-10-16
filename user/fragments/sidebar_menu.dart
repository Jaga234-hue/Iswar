import 'package:flutter/material.dart';
import 'chat_provider.dart';

class SidebarMenu extends StatefulWidget {
  final Function onClose;
  final Function onNewChat;
  final Function(ChatHistoryItem) onSelectHistory;
  final Function onPrivacy;
  final Function onIncognito;
  final Function onSettings;

  const SidebarMenu({
    Key? key,
    required this.onClose,
    required this.onNewChat,
    required this.onSelectHistory,
    required this.onPrivacy,
    required this.onIncognito,
    required this.onSettings,
  }) : super(key: key);

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  List<ChatHistoryItem> _recentChats = [];
  List<ChatHistoryItem> _olderChats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    // Mock data - split into recent and older chats
    setState(() {
      _recentChats = [
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
          date: DateTime.now().subtract(Duration(hours: 5)),
          messages: [],
        ),
        ChatHistoryItem(
          id: '3',
          title: 'Project Ideas',
          preview: 'Need creative project suggestions',
          date: DateTime.now().subtract(Duration(hours: 8)),
          messages: [],
        ),
      ];

      _olderChats = [
        ChatHistoryItem(
          id: '4',
          title: 'Research Paper',
          preview: 'Help with academic writing',
          date: DateTime.now().subtract(Duration(days: 1)),
          messages: [],
        ),
        ChatHistoryItem(
          id: '5',
          title: 'Code Review',
          preview: 'Can you check this code?',
          date: DateTime.now().subtract(Duration(days: 2)),
          messages: [],
        ),
      ];
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Color(0xFF1a1a2e),
        border: Border(
          right: BorderSide(color: Color(0xFF2a2a3a), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Header with close button
          _buildHeader(),
          // New Chat Button
          _buildNewChatButton(),
          // Divider
          _buildDivider(),
          // Recent Chats Section
          _buildRecentChatsSection(),
          // Settings Section
          _buildSettingsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            'Iswar AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
            onPressed: () => widget.onClose(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChatButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () => widget.onNewChat(), // This calls _startNewChat in chat_screen.dart
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4a4a8a),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          minimumSize: Size(double.infinity, 48),
        ),
        icon: Icon(Icons.add, size: 18),
        label: Text(
          'New Chat',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      height: 1,
      color: Color(0xFF2a2a3a),
    );
  }

  Widget _buildRecentChatsSection() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Recent Chats',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Recent Chats (Today)
            ..._recentChats.map((chat) => _buildChatItem(chat)).toList(),
            // Older Chats with date headers
            if (_olderChats.isNotEmpty) ...[
              // Yesterday Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  'Yesterday',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ..._olderChats
                  .where((chat) =>
              DateTime.now().difference(chat.date).inDays == 1)
                  .map((chat) => _buildChatItem(chat))
                  .toList(),
              // 2d ago Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Text(
                  '2d ago',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ..._olderChats
                  .where((chat) =>
              DateTime.now().difference(chat.date).inDays >= 2)
                  .map((chat) => _buildChatItem(chat))
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem(ChatHistoryItem chat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelectHistory(chat),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chat.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                chat.preview,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.private_connectivity,
            title: 'Privacy & Security',
            onTap: () => widget.onPrivacy(),
          ),
          SizedBox(height: 12),
          _buildSettingsItem(
            icon: Icons.visibility_off,
            title: 'New Incognito Tab',
            onTap: () => widget.onIncognito(),
          ),
          SizedBox(height: 12),
          _buildSettingsItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => widget.onSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required Function onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[400],
                size: 18,
              ),
              SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
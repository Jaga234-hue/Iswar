import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_provider.dart';
import 'message_bubble.dart';
import 'sidebar_menu.dart';
import 'app_bar_logo.dart';
import 'user_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Add this import for json.decode
import '../../API/api_connection.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _showSidebar = false;
  bool _isLoading = true;
  bool _showEnrollmentDialog = false;
  String? _userName;
  String _threadId = '0';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() async {
    // Check if user is enrolled
    final isEnrolled = await UserPreferences.isUserEnrolled();

    if (!isEnrolled) {
      // Show enrollment dialog
      setState(() {
        _showEnrollmentDialog = true;
        _isLoading = false;
      });
    } else {
      // Load user data
      _userName = await UserPreferences.getUserName();
      _threadId = await UserPreferences.getThreadId() ?? '0';

      setState(() {
        _isLoading = false;
      });

      // Add welcome message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = Provider.of<ChatProvider>(context, listen: false);
        if (provider.messages.isEmpty) {
          provider.addBotMessage(
            "Welcome back, $_userName! How can I help you today?",
          );
        }
      });
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final provider = Provider.of<ChatProvider>(context, listen: false);

    // Add user message
    provider.addUserMessage(text);
    _textController.clear();
    _focusNode.unfocus();

    _scrollToBottom();
    provider.setLoading(true);

    try {
      // Send message with all required parameters
      final response = await http.post(
        Uri.parse(API.sendMessage),
        body: {
          'user_name': _userName ?? 'unknown',
          'thread_id': _threadId ?? 'default',
          'userInput': text,
        },
      );

      if (response.statusCode == 200) {
        // Try to parse as JSON first
        try {
          final jsonResponse = json.decode(response.body);
          final aiResponse = jsonResponse['response']?.toString().trim() ?? response.body.trim();
          provider.addBotMessage(aiResponse);
        } catch (e) {
          // Fallback: use raw response
          provider.addBotMessage(response.body.trim());
        }
      } else {
        provider.addBotMessage("⚠️ Server error: ${response.statusCode}");
      }
    } catch (e) {
      provider.addBotMessage("❌ Failed to connect: $e");
    } finally {
      provider.setLoading(false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startNewChat() {
    // Reset thread_id to '0' for new chat
    _resetThreadId();

    Provider.of<ChatProvider>(context, listen: false).clearChat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.addBotMessage(
        "Started a new chat! How can I help you, $_userName?",
      );
    });
  }

  void _resetThreadId() async {
    _threadId = '0';
    await UserPreferences.setThreadId(_threadId);
  }

  // Helper method for successful enrollment
  Future<void> _handleSuccessfulEnrollment(String userName, Map<String, dynamic> responseData) async {
    // Save user data
    final threadId = (responseData['user_id'] ?? '0').toString();

    await UserPreferences.setUserName(userName);
    await UserPreferences.setThreadId(threadId);

    _userName = userName;
    _threadId = threadId;

    _showEnrollmentResult('Successfully enrolled! Welcome to Iswar AI.');
    setState(() {
      _showEnrollmentDialog = false;
    });

    // Add welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      provider.addBotMessage(
        "Welcome to Iswar AI, $userName! How can I help you today?",
      );
    });
  }

  // Helper method for string response handling
  Future<void> _handleStringResponse(String responseBody, String userName, BuildContext context) async {
    if (responseBody.contains('already exist') || responseBody.contains('exists')) {
      _showEnrollmentResult('Username already exists. Please choose a different name.');
    } else if (responseBody.contains('success')) {
      await _handleSuccessfulEnrollment(userName, {});
    } else {
      _showEnrollmentResult('Enrollment failed. Please try again.');
    }
  }

  void _enrollUser(String userName) async {
    if (userName.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Send user_name to enrollment endpoint with proper JSON
      final response = await http.post(
        Uri.parse(API.sendUserName),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_name': userName,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}'); // Debug
      print('Response body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final responseBody = response.body.trim();
        print('Response body trimmed: $responseBody'); // Debug

        try {
          // Try to parse as JSON first
          final jsonResponse = json.decode(responseBody);
          print('JSON parsed: $jsonResponse'); // Debug

          if (jsonResponse is Map<String, dynamic>) {
            final status = jsonResponse['status'];
            final message = jsonResponse['message'] ?? '';

            if (status == 'error') {
              _showEnrollmentResult(message);
            } else if (status == 'success') {
              await _handleSuccessfulEnrollment(userName, jsonResponse);
            } else {
              _showEnrollmentResult('Unexpected response format');
            }
          } else {
            // Fallback to string-based detection for backward compatibility
            await _handleStringResponse(responseBody, userName, context);
          }
        } catch (e) {
          print('JSON parse error: $e'); // Debug
          // If JSON parsing fails, use the original string-based logic
          await _handleStringResponse(responseBody, userName, context);
        }
      } else if (response.statusCode == 400) {
        _showEnrollmentResult('Bad request. Please check your input and try again.');
      } else if (response.statusCode == 409) {
        _showEnrollmentResult('Username already exists. Please choose a different name.');
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        _showEnrollmentResult('Client error: ${response.statusCode}');
      } else if (response.statusCode >= 500) {
        _showEnrollmentResult('Server error: ${response.statusCode}');
      } else {
        _showEnrollmentResult('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      print('Enrollment error: $e'); // Debug
      _showEnrollmentResult('Failed to connect: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEnrollmentResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('Successfully') ? Colors.green : Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _showSidebar = !_showSidebar;
    });
  }

  void _loadChatHistory(ChatHistoryItem historyItem) {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    provider.clearChat();
    provider.addBotMessage("Continuing our conversation about '${historyItem.title}'. How can I help you further?");
    _toggleSidebar();
  }

  void _showPrivacy() {
    _toggleSidebar();
    _showFeatureDialog('Privacy & Security');
  }

  void _showIncognito() {
    _toggleSidebar();
    _showFeatureDialog('Incognito Mode');
  }

  void _showSettings() {
    _toggleSidebar();
    _showFeatureDialog('Settings');
  }

  void _showFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF2a2a4a),
        title: Text(
          feature,
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '$feature feature will be implemented soon!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF6464FF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF1e1e2f),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6464FF),
          ),
        ),
      );
    }

    if (_showEnrollmentDialog) {
      return _buildEnrollmentScreen();
    }

    return Scaffold(
      backgroundColor: Color(0xFF1e1e2f),
      appBar: AppBar(
        title: AppBarLogo(),
        backgroundColor: Color(0xFF0f0f23),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: _toggleSidebar,
          tooltip: 'Menu',
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _startNewChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4a4a8a),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                shadowColor: Color(0xFF6464FF).withOpacity(0.3),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildChatInterface(),
          if (_showSidebar)
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            left: _showSidebar ? 0 : -280,
            top: 0,
            bottom: 0,
            child: SidebarMenu(
              onClose: _toggleSidebar,
              onNewChat: _startNewChat,
              onSelectHistory: _loadChatHistory,
              onPrivacy: _showPrivacy,
              onIncognito: _showIncognito,
              onSettings: _showSettings,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentScreen() {
    final TextEditingController userNameController = TextEditingController();

    return Scaffold(
      backgroundColor: Color(0xFF1e1e2f),
      body: Center(
        child: Container(
          width: 300,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF2a2a4a),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_add,
                size: 64,
                color: Color(0xFF6464FF),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Iswar AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Choose a username to get started',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TextField(
                controller: userNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF3a3a5a)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF3a3a5a)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Color(0xFF6464FF)),
                  ),
                  filled: true,
                  fillColor: Color(0xFF1a1a2e),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _enrollUser(userNameController.text.trim()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4a4a8a),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isLoading
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatInterface() {
    return IgnorePointer(
      ignoring: _showSidebar,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.2, 0.8),
            radius: 1.5,
            colors: [
              Color(0xFF1e1e2f),
              Color(0xFF0f0f23),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  return Stack(
                    children: [
                      _buildCosmicBackground(),
                      ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < provider.messages.length) {
                            final message = provider.messages[index];
                            return MessageBubble(
                              text: message.text,
                              isUser: message.isUser,
                              timestamp: message.timestamp,
                            );
                          } else {
                            return _buildTypingIndicator();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmicBackground() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -0.8),
            radius: 1.0,
            colors: [
              Color(0xFF6464FF).withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF2a2a4a),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(color: Color(0xFF3a3a5a)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimatedTypingDot(0),
                _buildAnimatedTypingDot(1),
                _buildAnimatedTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTypingDot(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Color(0xFF6464FF).withOpacity(0.7),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF1e1e2f).withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 20,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
        border: Border(
          top: BorderSide(color: Color(0xFF2a2a3a), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Color(0xFF3a3a5a)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send_rounded, color: Color(0xFF6464FF)),
                    onPressed: _sendMessage,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
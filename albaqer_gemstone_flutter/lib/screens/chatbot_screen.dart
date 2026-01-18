import 'package:flutter/material.dart';
import '../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  final int? userId;

  const ChatbotScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  String? _sessionId;
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _addWelcomeMessage();
  }

  Future<void> _checkConnection() async {
    final isHealthy = await ChatbotService.checkHealth();
    setState(() {
      _isConnected = isHealthy;
    });
    if (!isHealthy) {
      _showSnackBar('⚠️ Cannot connect to chatbot server', isError: true);
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          role: 'assistant',
          content:
              '👋 Assalamu Alaikum! Welcome to AlBaqer Islamic Gemstone Store.\n\nI can help you with:\n• Product recommendations\n• Stone information and benefits\n• Islamic significance of gemstones\n• Pricing and delivery\n• Order tracking\n\nHow can I assist you today?',
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(
        ChatMessage(role: 'user', content: message, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await ChatbotService.sendMessage(
        message: message,
        userId: widget.userId,
        sessionId: _sessionId,
      );

      setState(() {
        _sessionId = response['session_id'];
        _messages.add(
          ChatMessage(
            role: 'assistant',
            content: response['message'],
            routedTo: response['routed_to'],
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'error',
            content: '❌ Failed to send message. Please check your connection.',
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _showSnackBar('Error: ${e.toString()}', isError: true);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💎 AlBaqer Assistant'),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _checkConnection,
            tooltip: _isConnected ? 'Connected' : 'Disconnected',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                setState(() {
                  _messages.clear();
                  _sessionId = null;
                  _addWelcomeMessage();
                });
                _showSnackBar('Conversation cleared');
              } else if (value == 'reconnect') {
                _checkConnection();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reconnect',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Reconnect'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status banner
          if (!_isConnected)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange,
              child: const Text(
                '⚠️ Not connected to chatbot server. Make sure the API is running.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),

          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Thinking...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask me anything about gemstones...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    final isError = message.role == 'error';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: isError ? Colors.red : Colors.purple,
              child: Icon(
                isError ? Icons.error_outline : Icons.diamond,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : isError
                        ? Colors.red.shade50
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.routedTo != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '🤖 ${_formatAgentName(message.routedTo!)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  String _formatAgentName(String agentName) {
    return agentName
        .replaceAll('_AGENT', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}

class ChatMessage {
  final String role;
  final String content;
  final String? routedTo;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    this.routedTo,
    required this.timestamp,
  });
}

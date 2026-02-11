import 'package:flutter/material.dart';
import '../config/app_theme.dart';
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
        backgroundColor: isError ? AppColors.error : AppColors.success,
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
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? AppColors.success : AppColors.error,
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
              color: AppColors.warning,
              child: const Text(
                '⚠️ Not connected to chatbot server. Make sure the API is running.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textOnPrimary),
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
                  Text(
                    'Thinking...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.2),
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
                      fillColor: AppColors.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 4,
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
              backgroundColor: isError ? AppColors.error : AppColors.info,
              child: Icon(
                isError ? Icons.error_outline : Icons.diamond,
                color: AppColors.textOnPrimary,
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
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : isError
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isUser
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.textSecondary.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      _buildFormattedMessage(message.content, isUser, isError),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(
                Icons.person,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedMessage(String content, bool isUser, bool isError) {
    // Split content into lines and format each section
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip empty lines (but add spacing)
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Handle product cards
      if (line.contains('Product ID:') || line.contains('📦')) {
        widgets.add(_buildProductHighlight(line, isUser));
        continue;
      }

      // Handle prices
      if (line.contains('\$') ||
          line.contains('USD') ||
          line.contains('Price:') ||
          line.contains('💰')) {
        widgets.add(_buildPriceHighlight(line, isUser));
        continue;
      }

      // Handle bullet points
      if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        final text = line.trim().substring(1).trim();
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: isUser ? AppColors.textOnPrimary : AppColors.primary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: _buildTextWithFormatting(text, isUser, isError),
                ),
              ],
            ),
          ),
        );
      }
      // Handle numbered lists
      else if (RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: _buildTextWithFormatting(line.trim(), isUser, isError),
          ),
        );
      }
      // Handle section headers (lines ending with :)
      else if (line.trim().endsWith(':') && line.trim().length < 60) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line.trim(),
              style: TextStyle(
                color: isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      // Handle bold text (surrounded by **)
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: _buildTextWithFormatting(line.trim(), isUser, isError),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildProductHighlight(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withOpacity(0.1)
            : AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUser
              ? Colors.white.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 18,
            color: isUser ? AppColors.textOnPrimary : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHighlight(String text, bool isUser) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUser
            ? Colors.white.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isUser ? AppColors.textOnPrimary : AppColors.success,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextWithFormatting(String text, bool isUser, bool isError) {
    // Handle bold text (**text**)
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final matches = boldPattern.allMatches(text);

    if (matches.isEmpty) {
      // No special formatting, return simple text
      return Text(
        text,
        style: TextStyle(
          color: isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
      );
    }

    // Build rich text with bold formatting
    final List<TextSpan> spans = [];
    int lastEnd = 0;

    for (var match in matches) {
      // Add text before the bold part
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      // Add the bold text
      spans.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      lastEnd = match.end;
    }

    // Add remaining text
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: isUser ? AppColors.textOnPrimary : AppColors.textPrimary,
          fontSize: 15,
          height: 1.4,
        ),
        children: spans,
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

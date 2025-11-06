import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/bot_model.dart';
import '../../chat/widgets/MessageBubble.dart';
import '../../chat/widgets/AiModelSelector.dart';
import '../../chat/widgets/ChatInput.dart';
import '../../chat/widgets/Upload.dart';

class ChatWithBotPage extends StatefulWidget {
  final BotModel bot;

  const ChatWithBotPage({
    super.key,
    required this.bot,
  });

  @override
  State<ChatWithBotPage> createState() => _ChatWithBotPageState();
}

class _ChatWithBotPageState extends State<ChatWithBotPage> {
  bool _isEmpty = true;
  String _selectedModel = 'GPT-4o mini';
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add initial greeting message
    _messages.add({
      'isUser': false,
      'message': 'Hi! I\'m ${widget.bot.name}. How can I help you today?',
    });
  }

  void _handleSendMessage() {
    setState(() {
      _isEmpty = false;
      
      // Mock bot response
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'isUser': false,
              'message': 'This is a mock response from ${widget.bot.name}. In production, this will be connected to the AI model.',
            });
          });
        }
      });
    });
  }

  void _handleNewChat() {
    setState(() {
      _isEmpty = true;
      _messages.clear();
      _messages.add({
        'isUser': false,
        'message': 'Hi! I\'m ${widget.bot.name}. How can I help you today?',
      });
    });
  }

  void _showUploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const UploadOptionsSheet(),
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          children: [
            // Messages List (or empty state)
            _isEmpty
                ? _buildEmptyState()
                : Expanded(child: _buildConversation()),
            
            // Chat Box (same as ChatPage)
            _buildChatBox(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.bot.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        // Upgrade button
        TextButton(
          onPressed: () {},
          child: Row(
            children: [
              Text(
                'Upgrade',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.rocket_launch, color: Colors.blue.shade700, size: 20),
            ],
          ),
        ),
        // Profile Avatar
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hi! I\'m ${widget.bot.name}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.bot.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'How can I help you today?',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversation() {
    return ListView.builder(
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return MessageBubble(
          message: message['message'],
          isUser: message['isUser'],
        );
      },
    );
  }

  Widget _buildChatBox() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // AI Model selector + History + New Chat
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AiModelSelector(
              selectedModel: _selectedModel,
              onModelChanged: (model) {
                setState(() {
                  _selectedModel = model;
                });
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Show bot info or history
                  },
                  icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                ),
                IconButton(
                  onPressed: _handleNewChat,
                  icon: Icon(
                    Icons.add_comment_outlined,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ChatInputBox(
          onSend: _handleSendMessage,
          onUpload: _showUploadBottomSheet,
        ),
      ],
    );
  }
}

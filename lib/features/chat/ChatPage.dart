import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../shared/widgets/AppDrawer.dart';
import 'widgets/AiModelSelector.dart';
import 'widgets/ChatInput.dart';
import 'widgets/MessageBubble.dart';
import 'widgets/Conversation.dart';
import 'widgets/ChatHistory.dart';
import 'widgets/Upload.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isEmpty = true;
  String selectedModel = 'GPT-4o mini';

  void _handleNewChat() {
    setState(() {
      isEmpty = true;
    });
  }

  void _handleOpenConversation() {
    setState(() {
      isEmpty = false;
    });
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          ChatHistory(onHistoryTap: (id) => _handleOpenConversation()),
      barrierColor: Colors.black.withOpacity(0.2),
    );
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
      drawer: const SafeArea(child: AppDrawer()),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          children: [
            isEmpty
                ? Conversation(onPromptTap: _handleOpenConversation)
                : Expanded(child: _buildConversation()),
            _buildChatBox(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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

  Widget _buildConversation() {
    return ListView(
      children: const [
        MessageBubble(
          message: "Hello! How can I help you today?",
          isUser: false,
        ),
        MessageBubble(
          message: "Can you explain what Flutter is?",
          isUser: true,
        ),
        MessageBubble(
          message:
              "Flutter is Google's UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.",
          isUser: false,
        ),
      ],
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
              selectedModel: selectedModel,
              onModelChanged: (model) {
                setState(() {
                  selectedModel = model;
                });
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _showHistoryBottomSheet,
                  icon: const Icon(Icons.history, color: Colors.blueGrey),
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
          onSend: _handleOpenConversation,
          onUpload: _showUploadBottomSheet,
        ),
      ],
    );
  }
}

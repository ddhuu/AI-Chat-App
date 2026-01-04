import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../models/assistant_model.dart';
import '../providers/bot_chat_provider.dart';
import '../../chat/widgets/message_bubble.dart';
import '../../chat/widgets/chat_input.dart';

class ChatWithAssistantPage extends StatefulWidget {
  final Assistant assistant;

  const ChatWithAssistantPage({super.key, required this.assistant});

  @override
  State<ChatWithAssistantPage> createState() => _ChatWithAssistantPageState();
}

class _ChatWithAssistantPageState extends State<ChatWithAssistantPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _attachedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BotChatProvider>().initializeChat();
    });

    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
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
  }

  void _handleNewChat() {
    context.read<BotChatProvider>().clearChat();
  }

  Future<void> _handleSendMessage(String content) async {
    FocusScope.of(context).unfocus();

    final provider = context.read<BotChatProvider>();

    List<String>? files;
    if (_attachedImagePath != null) {
      files = [_attachedImagePath!];
    }

    await provider.sendMessage(content, files: files);

    setState(() {
      _attachedImagePath = null;
    });

    _scrollToBottom();
  }

  Future<void> _showUrlInputDialog() async {
    final urlController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attach Image Link'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() => _attachedImagePath = urlController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Attach'),
          ),
        ],
      ),
    );
  }

  void _handleImageRemove() {
    setState(() {
      _attachedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assistant.assistantName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'AI Assistant',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _handleNewChat,
            icon: const Icon(Icons.refresh),
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: Consumer<BotChatProvider>(
        builder: (context, provider, child) {
          if (provider.messages.isNotEmpty) {
            _scrollToBottom();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return MessageBubble(
                      message: message['message'],
                      isUser: message['isUser'],
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (provider.remainingUsage >= 0)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bolt, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${provider.remainingUsage}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    ChatInputBox(
                      controller: _messageController,
                      onSend: () {
                        final text = _messageController.text.trim();
                        if (text.isNotEmpty || _attachedImagePath != null) {
                          _handleSendMessage(text);
                          _messageController.clear();
                        }
                      },
                      onUpload: _showUrlInputDialog,
                      attachedImagePath: _attachedImagePath,
                      onRemoveImage: _handleImageRemove,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
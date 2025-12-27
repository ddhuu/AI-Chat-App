import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/api_service.dart';
import '../../pricing/pricing_page.dart';
import '../models/assistant_model.dart';
import '../providers/bot_chat_provider.dart';
import '../services/bot_chat_service.dart';
import '../../chat/widgets/message_bubble.dart';
import '../../chat/widgets/ai_model_selector.dart';
import '../../chat/widgets/chat_input.dart';
import '../../chat/widgets/upload.dart';

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

  void _handleImageRemove() {
    setState(() {
      _attachedImagePath = null;
    });
  }

  void _handleImageAttached(String sourcePath) {
    setState(() {
      _attachedImagePath = sourcePath;
    });
  }

  Future<void> _handleSendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final provider = context.read<BotChatProvider>();

    // Send message
    await provider.sendMessage(
      message,
      files: _attachedImagePath != null ? [_attachedImagePath!] : null,
    );

    // Clear input and attached image
    _messageController.clear();
    setState(() {
      _attachedImagePath = null;
    });

    // Scroll to bottom
    _scrollToBottom();
  }

  void _handleNewChat() {
    final provider = context.read<BotChatProvider>();
    provider.clearChat();
  }

  Future<void> _handleGalleryUpload() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _handleImageAttached('Gallery');
  }

  Future<void> _handleCameraCapture() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _handleImageAttached('Camera');
  }

  Future<void> _handlePasteScreenshot() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _handleImageAttached('Screenshot');
  }

  void _showUploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => UploadOptionsSheet(
        onGalleryUpload: () async {
          Navigator.pop(context);
          await _handleGalleryUpload();
        },
        onCameraCapture: () async {
          Navigator.pop(context);
          await _handleCameraCapture();
        },
        onPasteScreenshot: () async {
          Navigator.pop(context);
          await _handlePasteScreenshot();
        },
      ),
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BotChatProvider(
        chatService: BotChatService(context.read<ApiService>()),
        assistant: widget.assistant,
      )..initializeChat(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            children: [
              // Messages List
              Expanded(child: _buildConversation()),

              // Chat Box
              _buildChatBox(),
            ],
          ),
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
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.assistant.assistantName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        // Upgrade button
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PricingPage()),
            );
          },
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
    return Consumer<BotChatProvider>(
      builder: (context, provider, child) {
        if (provider.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= provider.messages.length) {
              // Loading indicator
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
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
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Thinking...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              );
            }

            final message = provider.messages[index];
            return MessageBubble(
              message: message['message'],
              isUser: message['isUser'],
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            widget.assistant.assistantName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.assistant.description ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'How can I help you today?',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBox() {
    return Consumer<BotChatProvider>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI Model selector + New Chat
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AiModelSelector(
                  selectedModel: provider.selectedModel,
                  onModelChanged: (model) {
                    provider.setModel(model);
                  },
                ),
                Row(
                  children: [
                    if (provider.remainingUsage > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bolt,
                              size: 14,
                              color: AppColors.primary,
                            ),
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
                    const SizedBox(width: 8),
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
              onSend: () {
                final message = _messageController.text;
                if (message.trim().isNotEmpty) {
                  _handleSendMessage(message);
                }
              },
              onUpload: _showUploadBottomSheet,
              attachedImagePath: _attachedImagePath,
              onRemoveImage: _handleImageRemove,
            ),
          ],
        );
      },
    );
  }
}

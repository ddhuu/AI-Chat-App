import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:ai_chat_assistant/features/chat/services/chat_service.dart';
import 'package:ai_chat_assistant/shared/providers/token_usage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../shared/widgets/AppDrawer.dart';
import '../../shared/widgets/profile_drawer.dart';
import '../../shared/widgets/ad_manager.dart';
import '../pricing/pricing_page.dart';
import '../../main.dart';
import '../bot/providers/assistant_provider.dart';
import '../bot/models/assistant_model.dart';
import 'widgets/enhanced_ai_model_selector.dart';
import 'widgets/message_bubble.dart';
import 'widgets/conversation.dart';
import 'widgets/chat_history.dart';
import 'widgets/upload.dart';
import '../prompt/pages/prompt_library_bottom_sheet.dart';
import '../prompt/widgets/prompt_suggestion_overlay.dart';

class ChatPage extends StatefulWidget {
  final Assistant? initialBot;

  const ChatPage({super.key, this.initialBot});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isEmpty = true;
  String selectedModelId = 'gpt-4o-mini';
  bool isBot = false;
  final List<Widget> _mockMessages = [];

  // Chat state
  late ChatService _chatService;
  String? _conversationId;
  final List<Map<String, dynamic>> _conversationHistory = [];
  bool _isSending = false;

  // Slash command overlay
  OverlayEntry? _promptOverlayEntry;
  final TextEditingController _chatInputController = TextEditingController();
  final GlobalKey _textFieldKey = GlobalKey();

  String? _attachedImagePath;

  @override
  void initState() {
    super.initState();
    // Initialize ChatService
    final apiService = context.read<ApiService>();
    _chatService = ChatService(apiService);

    // If initialBot is provided, set it as selected
    if (widget.initialBot != null) {
      selectedModelId = widget.initialBot!.id;
      isBot = true;
      _mockMessages.add(
        MessageBubble(
          message:
              "Hi! I'm ${widget.initialBot!.assistantName}. ${widget.initialBot!.description ?? 'How can I help you today?'}",
          isUser: false,
        ),
      );
    } else {
      _mockMessages.add(
        const MessageBubble(
          message: "Hello! How can I help you today?",
          isUser: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    _closePromptOverlay();
    super.dispose();
  }

  void _closePromptOverlay() {
    _promptOverlayEntry?.remove();
    _promptOverlayEntry = null;
  }

  String _getModelDisplayName() {
    if (isBot) {
      // For bots, use bot name from AssistantProvider
      final provider = context.read<AssistantProvider>();
      final bot = provider.assistants.firstWhere(
        (a) => a.id == selectedModelId,
        orElse: () => Assistant(
          id: selectedModelId,
          assistantName: 'Bot',
          userId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return bot.assistantName;
    }

    // For base models, map ID to display name
    final modelMap = {
      'gpt-4o-mini': 'GPT-4o mini',
      'gpt-4o': 'GPT-4o',
      'gemini-1.5-flash': 'Gemini 1.5 Flash',
      'gemini-1.5-pro': 'Gemini 1.5 Pro',
      'gemini-2.0-flash': 'Gemini 2.0 Flash',
      'claude-3-haiku': 'Claude 3 Haiku',
      'claude-3.5-sonnet': 'Claude 3.5 Sonnet',
      'deepseek-chat': 'Deepseek Chat',
      'qwen2.5-coder-32b': 'Qwen2.5-Coder-32B-Instruct',
      'qwen3-32b': 'Qwen3-32B',
      'saola3.1-medium': 'SaoLa3.1-medium',
      'saola-llama3.1-planner': 'SaoLa-Llama3.1-planner',
    };

    return modelMap[selectedModelId] ?? selectedModelId;
  }

  void _handleTextChanged(String text) {
    // Detect slash command
    if (text.endsWith('/')) {
      _showPromptOverlay();
    } else if (_promptOverlayEntry != null && !text.endsWith('/')) {
      _closePromptOverlay();
    }
  }

  void _showPromptOverlay() {
    try {
      // Close existing overlay if any
      _closePromptOverlay();

      // Get TextField context from GlobalKey
      final textFieldContext = _textFieldKey.currentContext;
      if (textFieldContext == null) {
        return;
      }

      // Create and show new overlay
      final overlayHelper = PromptSuggestionOverlayHelper(
        context: textFieldContext,
        onClose: _closePromptOverlay,
        onUsePrompt: (String? promptText) {
          if (promptText != null && promptText.isNotEmpty) {
            // Remove the trailing '/' and send the prompt
            final currentText = _chatInputController.text;
            if (currentText.endsWith('/')) {
              _chatInputController.clear();
            }
            _handleSendMessage(promptText);
          }
        },
      );

      _promptOverlayEntry = overlayHelper.createOverlayEntry();
      Overlay.of(context).insert(_promptOverlayEntry!);
    } catch (e) {}
  }

  void _handleNewChat() {
    setState(() {
      isEmpty = true;
      _mockMessages.clear();
      _mockMessages.add(
        const MessageBubble(
          message: "Hello! How can I help you today?",
          isUser: false,
        ),
      );

      // Reset conversation state for new thread
      _conversationId = null;
      _conversationHistory.clear();

      print('🆕 Starting new chat thread');
    });
  }

  Future<void> _handleSendMessage(String userMessage) async {
    if (_isSending || userMessage.trim().isEmpty) return;

    print(
      'Sending message: ${userMessage.substring(0, userMessage.length > 50 ? 50 : userMessage.length)}...',
    );

    setState(() {
      _isSending = true;
      isEmpty = false;

      // Clear initial welcome message on first user message
      if (_conversationHistory.isEmpty) {
        _mockMessages.clear();
      }

      // Add user message to UI
      _mockMessages.add(MessageBubble(message: userMessage, isUser: true));
    });

    try {
      Map<String, dynamic> response;

      // First message - create new thread
      if (_conversationHistory.isEmpty) {
        response = await _chatService.createNewThread(
          message: userMessage,
          modelDisplayName: _getModelDisplayName(),
        );

        // Save conversation ID
        if (response['conversationId'] != null) {
          _conversationId = response['conversationId'];
          print('New conversation created with ID: $_conversationId');
        } else {
          print('No conversationId in response: ${response.keys}');
          print('Response data: ${response.toString()}');
          print('Conversation will be created after next message');
        }
      } else {
        // Subsequent messages - send with conversationId only (messages array stays empty)
        print('Sending message to conversation: $_conversationId');
        response = await _chatService.sendMessage(
          message: userMessage,
          modelDisplayName: _getModelDisplayName(),
          conversationHistory:
              [], // Always empty - server tracks history by conversationId
          conversationId:
              _conversationId, // IMPORTANT: Pass conversationId to persist messages
        );

        // Check if conversationId is returned in subsequent messages
        if (_conversationId == null && response['conversationId'] != null) {
          _conversationId = response['conversationId'];
          print('Conversation ID received on message 2: $_conversationId');
        } else {
          print('Message sent to conversation: $_conversationId');
        }
      }

      // Get AI response
      final aiResponse = response['message'] ?? 'No response';

      // Add user message to history AFTER getting response
      _conversationHistory.add({
        "role": "user",
        "content": userMessage,
        "files": [],
      });

      // Add AI response to history
      _conversationHistory.add({"role": "model", "content": aiResponse});

      // Add AI response to UI
      setState(() {
        _mockMessages.add(MessageBubble(message: aiResponse, isUser: false));
      });

      // Update token usage
      if (response['remainingUsage'] != null && mounted) {
        try {
          final tokenProvider = context.read<TokenUsageProvider>();
          await tokenProvider.getUsage();
        } catch (e) {
          print('Failed to update token usage: $e');
        }
      }

      // Show ad (wrapped in try-catch to prevent crashes)
      if (mounted) {
        try {
          AdManager.of(context)?.showInterstitialAd();
        } catch (e) {
          print('Failed to show ad: $e');
        }
      }
    } catch (e, stackTrace) {
      print('Error sending message: $e');
      print('Stack trace: $stackTrace');

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Remove user message on error
      if (mounted) {
        setState(() {
          if (_mockMessages.isNotEmpty) {
            _mockMessages.removeLast();
          }
        });
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _handleOpenConversation() {
    // This will be called by ChatInputBox
    // Actual sending is handled by _handleSendMessage
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ChatHistory(
        onHistoryTap: (conversationId, title) =>
            _loadConversationHistory(conversationId, title),
      ),
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  Future<void> _loadConversationHistory(
    String conversationId,
    String title,
  ) async {
    setState(() {
      _isSending = true;
      isEmpty = false;
      _mockMessages.clear();
      _conversationHistory.clear();
      _conversationId = conversationId;
    });

    try {
      final messages = await _chatService.getConversationHistory(
        conversationId,
        assistantModel: 'dify',
      );

      print('Loaded ${messages.length} messages from conversation');

      setState(() {
        for (var msg in messages) {
          // API returns: { query: "user message", answer: "AI response" }
          final userQuery = msg['query'] as String?;
          final aiAnswer = msg['answer'] as String?;

          print('Query: $userQuery');
          print('Answer: $aiAnswer');

          // Add user message
          if (userQuery != null && userQuery.isNotEmpty) {
            _mockMessages.add(MessageBubble(message: userQuery, isUser: true));

            _conversationHistory.add({
              "role": "user",
              "content": userQuery,
              "files": [],
            });
          }

          // Add AI response
          if (aiAnswer != null && aiAnswer.isNotEmpty) {
            _mockMessages.add(MessageBubble(message: aiAnswer, isUser: false));

            _conversationHistory.add({"role": "model", "content": aiAnswer});
          }
        }
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load conversation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleImageAttached(String sourcePath) {
    if (!mounted) {
      return;
    }
    setState(() {
      _attachedImagePath = sourcePath;
    });
  }

  void _handleImageRemove() {
    setState(() {
      _attachedImagePath = null;
    });
  }

  Future<void> _handleGalleryUpload() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _handleImageAttached('Gallery Image');
  }

  Future<void> _handleCameraCapture() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _handleImageAttached('Camera Capture');
  }

  Future<void> _handlePasteScreenshot() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    if (clipboardData?.text != null) {
      _handleImageAttached('Screenshot');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image data found on clipboard.')),
      );
    }
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

  void _showPromptLibrary() async {
    final String? promptText = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PromptLibraryBottomSheet(),
    );

    print('Prompt library returned: ${promptText ?? "null"}');

    // If user selected and filled a prompt, send it
    if (promptText != null && promptText.isNotEmpty) {
      print(
        'Prompt received from library: ${promptText.substring(0, promptText.length > 50 ? 50 : promptText.length)}...',
      );
      await _handleSendMessage(promptText);
    } else {
      print('Prompt text is null or empty, not sending');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const SafeArea(child: AppDrawer()),
      endDrawer: const SafeArea(child: ProfileDrawer()),
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
    final bool isPro = MyApp.of(context).isProUser;

    return AppBar(
      actions: [
        if (!isPro)
          TextButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const PricingPage()),
              );
              setState(() {});
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
                Icon(
                  Icons.rocket_launch,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.primary, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Pro',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8),
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConversation() {
    print('Building conversation with ${_mockMessages.length} messages');
    return ListView.builder(
      itemCount: _mockMessages.length,
      itemBuilder: (context, index) {
        return _mockMessages[index];
      },
    );
  }

  Widget _buildChatBox() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            EnhancedAiModelSelector(
              selectedModelId: selectedModelId,
              isBot: isBot,
              onModelChanged: (modelId, isBotSelected) {
                setState(() {
                  selectedModelId = modelId;
                  isBot = isBotSelected;
                  // Reset conversation when model changes
                  _handleNewChat();
                });
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _showPromptLibrary,
                  icon: const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.amber,
                  ),
                  tooltip: 'Prompt Library',
                ),
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
        _buildChatInput(),
      ],
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Upload button
          IconButton(
            onPressed: _showUploadBottomSheet,
            icon: const Icon(Icons.add_circle_outline),
            color: Colors.grey.shade600,
          ),

          // Text input
          Expanded(
            child: TextField(
              key: _textFieldKey,
              controller: _chatInputController,
              decoration: const InputDecoration(
                hintText: 'Type a message... (use / for prompts)',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              enabled: !_isSending,
              onChanged: _handleTextChanged,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _handleSendMessage(text.trim());
                  _chatInputController.clear();
                }
              },
            ),
          ),

          // Send button
          IconButton(
            onPressed: _isSending
                ? null
                : () {
                    final text = _chatInputController.text.trim();
                    if (text.isNotEmpty) {
                      _handleSendMessage(text);
                      _chatInputController.clear();
                    }
                  },
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: _isSending ? Colors.grey : Colors.blue.shade700,
          ),
        ],
      ),
    );
  }
}

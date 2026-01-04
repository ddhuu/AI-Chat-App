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
import 'widgets/chat_input.dart';
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

  late ChatService _chatService;
  String? _conversationId;
  final List<Map<String, dynamic>> _conversationHistory = [];
  bool _isSending = false;

  String? _attachedImageUrl;

  OverlayEntry? _promptOverlayEntry;
  final TextEditingController _chatInputController = TextEditingController();
  final GlobalKey _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final apiService = context.read<ApiService>();
    _chatService = ChatService(apiService);

    if (widget.initialBot != null) {
      selectedModelId = widget.initialBot!.id;
      isBot = true;
      _mockMessages.add(MessageBubble(
          message: "Hi! I'm ${widget.initialBot!.assistantName}. ${widget.initialBot!.description ?? 'How can I help you today?'}",
          isUser: false));
    } else {
      _mockMessages.add(const MessageBubble(
          message: "Hello! How can I help you today?", isUser: false));
    }

    _chatInputController.addListener(() {
    });
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

    return selectedModelId;
  }

  Future<void> _showUrlInputDialog() async {
    final urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attach Image Link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Paste the direct link to the image:', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'https://example.com/image.jpg',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                setState(() {
                  _attachedImageUrl = urlController.text.trim();
                });
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
      _attachedImageUrl = null;
    });
  }

  void _showPromptOverlay() {
    try {
      _closePromptOverlay();
      final textFieldContext = _textFieldKey.currentContext;
      if (textFieldContext == null) return;

      final overlayHelper = PromptSuggestionOverlayHelper(
        context: textFieldContext,
        onClose: _closePromptOverlay,
        onUsePrompt: (String? promptText) {
          if (promptText != null && promptText.isNotEmpty) {
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
      _conversationId = null;
      _conversationHistory.clear();
      _attachedImageUrl = null;
    });
  }

  Future<void> _handleSendMessage(String userMessage) async {
    if (_isSending || (userMessage.trim().isEmpty && _attachedImageUrl == null)) return;

    setState(() {
      _isSending = true;
      isEmpty = false;
      if (_conversationHistory.isEmpty) _mockMessages.clear();

      String displayMsg = userMessage;
      if (_attachedImageUrl != null) {
        if(displayMsg.isEmpty) displayMsg = "[Sent an image]";
        else displayMsg += "\n[Image Attached]";
      }

      _mockMessages.add(MessageBubble(message: displayMsg, isUser: true));
    });

    try {
      List<String>? files;
      if (_attachedImageUrl != null) {
        files = [_attachedImageUrl!];
      }

      Map<String, dynamic> response;
      if (_conversationHistory.isEmpty) {
        response = await _chatService.createNewThread(
          message: userMessage,
          modelDisplayName: _getModelDisplayName(),
          files: files,
        );
        _conversationId = response['conversationId'];
      } else {
        response = await _chatService.sendMessage(
          message: userMessage,
          modelDisplayName: _getModelDisplayName(),
          conversationHistory: [],
          conversationId: _conversationId,
          files: files,
        );
      }

      final aiResponse = response['message'] ?? 'No response';

      _conversationHistory.add({"role": "user", "content": userMessage});
      _conversationHistory.add({"role": "model", "content": aiResponse});

      setState(() {
        _mockMessages.add(MessageBubble(message: aiResponse, isUser: false));
        _attachedImageUrl = null;
      });

      if (mounted) context.read<TokenUsageProvider>().getUsage();
      if (mounted) AdManager.of(context)?.showInterstitialAd();

    } catch (e) {
      print('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() {
          if (_mockMessages.isNotEmpty) _mockMessages.removeLast();
        });
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
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

  Future<void> _loadConversationHistory(String conversationId, String title) async {
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

      setState(() {
        for (var msg in messages) {
          final userQuery = msg['query'] as String?;
          final aiAnswer = msg['answer'] as String?;

          if (userQuery != null && userQuery.isNotEmpty) {
            _mockMessages.add(MessageBubble(message: userQuery, isUser: true));
            _conversationHistory.add({"role": "user", "content": userQuery, "files": []});
          }

          if (aiAnswer != null && aiAnswer.isNotEmpty) {
            _mockMessages.add(MessageBubble(message: aiAnswer, isUser: false));
            _conversationHistory.add({"role": "model", "content": aiAnswer});
          }
        }
        _isSending = false;
      });
    } catch (e) {
      setState(() => _isSending = false);
    }
  }

  void _showPromptLibrary() async {
    final String? promptText = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PromptLibraryBottomSheet(),
    );

    if (promptText != null && promptText.isNotEmpty) {
      await _handleSendMessage(promptText);
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
                ? Conversation(onPromptTap: () {})
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
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(width: 4),
                Icon(Icons.rocket_launch, color: Colors.blue.shade700, size: 20),
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
                Text('Pro', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 17)),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(right: 16, left: 8),
          child: Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openEndDrawer(),
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
    return ListView.builder(
      itemCount: _mockMessages.length,
      itemBuilder: (context, index) => _mockMessages[index],
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
                  _handleNewChat();
                });
              },
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _showPromptLibrary,
                  icon: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                  tooltip: 'Prompt Library',
                ),
                IconButton(
                  onPressed: _showHistoryBottomSheet,
                  icon: const Icon(Icons.history, color: Colors.blueGrey),
                ),
                IconButton(
                  onPressed: _handleNewChat,
                  icon: Icon(Icons.add_comment_outlined, color: Colors.blue.shade700),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        ChatInputBox(
          controller: _chatInputController,
          onSend: () {
            final text = _chatInputController.text.trim();
            if (text.isNotEmpty || _attachedImageUrl != null) {
              _handleSendMessage(text);
              _chatInputController.clear();
            }
          },
          onUpload: _showUrlInputDialog,
          attachedImagePath: _attachedImageUrl,
          onRemoveImage: _handleImageRemove,
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/colors.dart';
import '../../shared/widgets/AppDrawer.dart';
import '../../shared/widgets/ad_manager.dart';
import '../pricing/pricing_page.dart';
import '../../main.dart';
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
  final List<Widget> _mockMessages = [];

  String? _attachedImagePath;

  int get _currentTokens => MyApp.of(context).isProUser ? 999999 : 50;

  @override
  void initState() {
    super.initState();
    _mockMessages.add(const MessageBubble(
      message: "Hello! How can I help you today?",
      isUser: false,
    ));
  }

  void _handleNewChat() {
    setState(() {
      isEmpty = true;
      _mockMessages.clear();
      _mockMessages.add(const MessageBubble(
        message: "Hello! How can I help you today?",
        isUser: false,
      ));
      _attachedImagePath = null;
    });
  }

  void _handleOpenConversation() {
    setState(() {
      isEmpty = false;
      if (_attachedImagePath != null) {
        _mockMessages.add(MessageBubble(
          message: 'Image uploaded successfully from $_attachedImagePath. Please analyze this.',
          isUser: true,
        ));
        _mockMessages.add(const MessageBubble(
          message: 'I see the image. I am processing your request now...',
          isUser: false,
        ));
      } else {
        _mockMessages.add(const MessageBubble(
          message: 'Sending text message...',
          isUser: true,
        ));
      }

      _attachedImagePath = null;
    });
    AdManager.of(context)?.showInterstitialAd();
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          ChatHistory(onHistoryTap: (id) => _handleOpenConversation()),
      barrierColor: Colors.black.withOpacity(0.2),
    );
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

  Widget _buildTokenStatus() {
    final isPro = MyApp.of(context).isProUser;
    final tokenText = isPro ? 'Tokens: VÔ HẠN' : 'Tokens: ${_currentTokens}';
    final textColor = isPro ? AppColors.primary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.local_fire_department,
            size: 16,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            tokenText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
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
      children: _mockMessages,
    );
  }

  Widget _buildChatBox() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
        ChatInputBox(
          onSend: _handleOpenConversation,
          onUpload: _showUploadBottomSheet,
          attachedImagePath: _attachedImagePath,
          onRemoveImage: _handleImageRemove,
        ),
        _buildTokenStatus()
      ],
    );
  }
}
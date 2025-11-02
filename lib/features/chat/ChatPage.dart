import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for Clipboard (used in screenshot mock)
import '../../core/constants/colors.dart';
import '../../shared/widgets/AppDrawer.dart';
import '../pricing/pricing_page.dart';
import '../../shared/widgets/ad_manager.dart';
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

  // NEW STATE: Holds the path of the image attached to the input field
  String? _inputImagePath;

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
      _inputImagePath = null; // Clear input image on new chat
    });
  }

  // NEW: Function to clear the image from the input preview
  void _clearInputImage() {
    setState(() {
      _inputImagePath = null;
    });
  }

  // RENAME & REPURPOSE: This function now handles the final SEND action
  void _handleSendContent() {
    final bool hasAttachment = _inputImagePath != null;
    // MOCK: Assume text input is also present or handled separately
    final String textContent = hasAttachment ? "Please analyze the attached image." : "Sent text message.";

    // 1. Add message to history
    setState(() {
      isEmpty = false;
      _mockMessages.add(MessageBubble(
        message: hasAttachment
            ? "Attachment (${_inputImagePath!.split('/').last}) + $textContent"
            : textContent,
        isUser: true,
      ));
      // Add mock AI response
      _mockMessages.add(const MessageBubble(
        message: 'Processing your request and attachment...',
        isUser: false,
      ));

      // 2. Clear the input path after sending
      _inputImagePath = null;
    });

    // 3. Trigger global ad logic
    AdManager.of(context)?.showInterstitialAd();
  }

  void _showHistoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          ChatHistory(onHistoryTap: (id) => _handleSendContent()),
      barrierColor: Colors.black.withOpacity(0.2),
    );
  }

  // =================================================================
  // === Feature 9: Image/File Upload Handlers (SET STATE ONLY) ===
  // =================================================================

  // 1. Handler for "Upload image to chat" (Gallery/File Picker)
  Future<void> _handleGalleryUpload() async {
    // MOCK: In a real app, FilePicker would return a path/file object.
    setState(() {
      _inputImagePath = 'gallery_photo_file.jpg';
    });
  }

  // 2. Handler for "Capture image and chat with it" (Camera)
  Future<void> _handleCameraCapture() async {
    // MOCK: Camera logic would return a path.
    setState(() {
      _inputImagePath = 'camera_capture_001.jpg';
    });
  }

  // 3. Handler for "Screenshot and chat with screenshot" (Clipboard)
  Future<void> _handlePasteScreenshot() async {
    // MOCK: Simulate success if text clipboard is not empty.
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      setState(() {
        _inputImagePath = 'pasted_screenshot_001.png';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image data found on clipboard.')),
      );
    }
  }

  // Update _showUploadBottomSheet to pass the new handlers
  void _showUploadBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => UploadOptionsSheet(
        onGalleryUpload: _handleGalleryUpload,
        onCameraCapture: _handleCameraCapture,
        onPasteScreenshot: _handlePasteScreenshot,
      ),
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
            // Conversation onTap now points to the final SEND handler
            isEmpty
                ? Conversation(onPromptTap: _handleSendContent)
                : Expanded(child: _buildConversation()),
            _buildChatBox(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // ... (Code remains the same)
    final bool isPro = MyApp.of(context).isProUser;

    return AppBar(
      actions: [
        if (!isPro)
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
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
          onSend: _handleSendContent, // NEW: Use the final send handler
          onUpload: _showUploadBottomSheet,
          // NEW: Pass the input image state and clear function
          inputImagePath: _inputImagePath,
          onClearImage: _clearInputImage,
        ),
      ],
    );
  }
}
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
import 'widgets/Upload.dart'; // Ensure Upload.dart is updated to accept handlers

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isEmpty = true;
  String selectedModel = 'GPT-4o mini';
  // State to hold mock chat messages, including image messages
  final List<Widget> _mockMessages = [];

  @override
  void initState() {
    super.initState();
    // Initialize mock messages with the default greeting
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
    });
  }

  // General action handler (used for sending messages or starting chat)
  void _handleOpenConversation() {
    setState(() {
      isEmpty = false;
    });

    // Trigger the interstitial ad logic defined in AdManager
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

  // =================================================================
  // === Feature 9: Image/File Upload Handlers ===
  // =================================================================

  // Function to simulate adding an image message to the chat
  void _addImageMessage(String source) {
    setState(() {
      isEmpty = false;
      // Add a user message simulating the image upload/capture
      _mockMessages.add(MessageBubble(
        message: 'Image uploaded successfully from $source. Please analyze this.',
        isUser: true,
        // In a real app, you would add a custom ImageMessageBubble here
      ));
      // Add a mock AI response
      _mockMessages.add(const MessageBubble(
        message: 'I see the image. I am processing your request now...',
        isUser: false,
      ));
    });
    // Scroll to the bottom if needed (not fully implemented here)
  }

  // 1. Handler for "Upload image to chat" (Gallery/File Picker)
  Future<void> _handleGalleryUpload() async {
    // MOCK: Replace with real ImagePicker/FilePicker logic
    await Future.delayed(const Duration(milliseconds: 300));
    _addImageMessage('Gallery/File Picker');
  }

  // 2. Handler for "Capture image and chat with it" (Camera)
  Future<void> _handleCameraCapture() async {
    // MOCK: Replace with real Camera access logic
    await Future.delayed(const Duration(milliseconds: 300));
    _addImageMessage('Camera Capture');
  }

  // 3. Handler for "Screenshot and chat with screenshot" (Clipboard)
  Future<void> _handlePasteScreenshot() async {
    // MOCK: Use Clipboard API to check for image or text data
    // In Flutter, checking for image data directly in the clipboard is complex (platform-specific).
    // We mock success for demonstration purposes.

    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);

    if (clipboardData?.text != null) {
      // Simulate a successful image paste (e.g., if image data was present)
      _addImageMessage('Clipboard/Screenshot');
    } else {
      // Handle case where clipboard is empty or contains non-image data
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
    // The Banner Ad is now handled by the AdManager widget wrapping this page in main.dart
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
    // Check global Pro status to conditionally display the Upgrade button
    final bool isPro = MyApp.of(context).isProUser;

    return AppBar(
      actions: [
        // Upgrade button (hidden if user is Pro)
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
    // Display mock messages including image upload simulation
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
          onSend: _handleOpenConversation, // Triggers ad logic
          onUpload: _showUploadBottomSheet,
        ),
      ],
    );
  }
}
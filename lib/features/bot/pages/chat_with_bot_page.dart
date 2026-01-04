import 'package:flutter/material.dart';
import '../models/bot_model.dart';
import '../models/assistant_model.dart';
import '../../chat/widgets/message_bubble.dart';
import '../../chat/widgets/ai_model_selector.dart';
import '../../chat/widgets/chat_input.dart';

class ChatWithBotPage extends StatefulWidget {
  final BotModel? bot;
  final Assistant? assistant;

  const ChatWithBotPage({super.key, this.bot, this.assistant})
      : assert(
  bot != null || assistant != null,
  'Either bot or assistant must be provided',
  );

  @override
  State<ChatWithBotPage> createState() => _ChatWithBotPageState();
}

class _ChatWithBotPageState extends State<ChatWithBotPage> {
  final TextEditingController _chatInputController = TextEditingController();

  bool _isEmpty = true;
  String _selectedModel = 'GPT-4o mini';
  final List<Map<String, dynamic>> _messages = [];

  String? _attachedImagePath;

  String get _botName =>
      widget.bot?.name ?? widget.assistant?.assistantName ?? 'Assistant';

  @override
  void initState() {
    super.initState();
    _messages.add({
      'isUser': false,
      'message': 'Hi! I\'m $_botName. How can I help you today?',
    });

    _chatInputController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _chatInputController.dispose();
    super.dispose();
  }

  void _handleNewChat() {
    setState(() {
      _messages.clear();
      _messages.add({
        'isUser': false,
        'message': 'Hi! I\'m $_botName. How can I help you today?',
      });
      _attachedImagePath = null;
    });
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
          decoration: const InputDecoration(hintText: 'https://...'),
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
    setState(() => _attachedImagePath = null);
  }

  void _handleSendMessage(String text) {
    if (text.isEmpty && _attachedImagePath == null) return;

    setState(() {
      String displayMsg = text;
      if (_attachedImagePath != null) displayMsg += "\n[Image Attached]";

      _messages.add({'isUser': true, 'message': displayMsg});
      _isEmpty = false;

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _messages.add({
              'isUser': false,
              'message': 'This is a simulated response for: "$text". (Bot integration needed)',
            });
          });
        }
      });

      _attachedImagePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_botName),
        actions: [
          IconButton(
            onPressed: _handleNewChat,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(child: _buildChatList()),
            _buildChatBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList() {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AiModelSelector(
              selectedModel: _selectedModel,
              onModelChanged: (model) => setState(() => _selectedModel = model),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
                ),
                IconButton(
                  onPressed: _handleNewChat,
                  icon: Icon(Icons.add_comment_outlined, color: Colors.blue.shade700),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),

        ChatInputBox(
          controller: _chatInputController,
          onSend: () {
            final text = _chatInputController.text.trim();
            if (text.isNotEmpty || _attachedImagePath != null) {
              _handleSendMessage(text);
              _chatInputController.clear();
            }
          },
          onUpload: _showUrlInputDialog,
          attachedImagePath: _attachedImagePath,
          onRemoveImage: _handleImageRemove,
        ),
      ],
    );
  }
}
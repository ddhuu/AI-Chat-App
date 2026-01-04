import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:ai_chat_assistant/features/chat/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatHistory extends StatefulWidget {
  final Function(String, String) onHistoryTap; // conversationId, title

  const ChatHistory({super.key, required this.onHistoryTap});

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  late ChatService _chatService;
  List<dynamic> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final apiService = context.read<ApiService>();
    _chatService = ChatService(apiService);
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoading = true);
    try {
      final conversations = await _chatService.getConversations(
        assistantId: 'gpt-4o-mini',
        assistantModel: 'dify',
      );
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chat History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Conversations list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      final conv = _conversations[index];
                      return _buildHistoryItem(
                        context,
                        conversationId: conv['_id'] ?? conv['id'] ?? '',
                        title: conv['title'] ?? 'Untitled Conversation',
                        subtitle: _formatDate(
                          conv['updatedAt'] ?? conv['createdAt'],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      // Less than 1 hour - show minutes
      if (diff.inMinutes < 60) {
        if (diff.inMinutes < 1) return 'Just now';
        return '${diff.inMinutes}m ago';
      }

      // Less than 24 hours - show hours and minutes
      if (diff.inHours < 24) {
        final hours = diff.inHours;
        final minutes = diff.inMinutes % 60;
        if (minutes > 0) {
          return '${hours}h ${minutes}m ago';
        }
        return '${hours}h ago';
      }

      // Less than 7 days - show days
      if (diff.inDays < 7) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      }

      // More than 7 days - show date
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String conversationId,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: const Icon(Icons.chat_bubble_outline),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        widget.onHistoryTap(conversationId, title);
      },
    );
  }
}

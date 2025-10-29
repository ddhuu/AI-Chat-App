import 'package:flutter/material.dart';

class ChatHistory extends StatelessWidget {
  final Function(String) onHistoryTap;

  const ChatHistory({super.key, required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chat History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildHistoryItem(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Conversation about Flutter',
              subtitle: '2 hours ago',
              id: 'flutter_conv',
            ),
            _buildHistoryItem(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Email writing help',
              subtitle: '5 hours ago',
              id: 'email_help',
            ),
            _buildHistoryItem(
              context,
              icon: Icons.chat_bubble_outline,
              title: 'Translation task',
              subtitle: 'Yesterday',
              id: 'translation',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String id,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () {
        Navigator.pop(context);
        onHistoryTap(id);
      },
    );
  }
}

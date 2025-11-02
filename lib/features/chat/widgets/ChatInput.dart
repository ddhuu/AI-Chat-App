import 'package:flutter/material.dart';

class ChatInputBox extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onUpload;

  const ChatInputBox({super.key, required this.onSend, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade800, width: 0.6),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TextField(
            decoration: InputDecoration(
              hintText: "Ask me anything, press '/' for prompts...",
              hintStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(4, 2, 2, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: onUpload,
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: Colors.blueGrey,
                  ),
                ),
                IconButton(
                  onPressed: onSend,
                  icon: const Icon(Icons.send, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

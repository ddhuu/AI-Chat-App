import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class BotChatInput extends StatefulWidget {
  final Function(String) onSend;
  final VoidCallback? onUpload;

  const BotChatInput({
    super.key,
    required this.onSend,
    this.onUpload,
  });

  @override
  State<BotChatInput> createState() => _BotChatInputState();
}

class _BotChatInputState extends State<BotChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: null,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              hintText: "Ask me anything, press '/' for prompts...",
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 12, 16, 0),
            ),
            onSubmitted: (_) => _handleSend(),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  onPressed: widget.onUpload,
                  icon: const Icon(Icons.attach_file, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Attach file',
                ),
                // Slash command button
                IconButton(
                  onPressed: () {
                    // Show prompts
                  },
                  icon: const Icon(Icons.flash_on_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Prompts',
                ),
                // Language button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.language, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Language',
                ),
                // Voice button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_none, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Voice input',
                ),
                // Image button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.image_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Add image',
                ),
                // Table button
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.table_chart_outlined, size: 20),
                  color: AppColors.textSecondary,
                  tooltip: 'Add table',
                ),
                const Spacer(),
                // Send button
                IconButton(
                  onPressed: _handleSend,
                  icon: const Icon(Icons.send, size: 20),
                  color: AppColors.primary,
                  tooltip: 'Send',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

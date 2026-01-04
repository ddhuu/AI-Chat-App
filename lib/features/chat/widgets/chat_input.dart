import 'package:flutter/material.dart';

class ChatInputBox extends StatefulWidget {
  final VoidCallback onSend;
  final VoidCallback onUpload;

  final String? attachedImagePath;
  final VoidCallback onRemoveImage;
  final TextEditingController controller;

  const ChatInputBox({
    super.key,
    required this.onSend,
    required this.onUpload,
    this.attachedImagePath,
    required this.onRemoveImage,
    required this.controller,
  });

  @override
  State<ChatInputBox> createState() => _ChatInputBoxState();
}

class _ChatInputBoxState extends State<ChatInputBox> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  Widget _buildAttachedImage() {
    if (widget.attachedImagePath == null) {
      return const SizedBox.shrink();
    }

    bool isUrl = widget.attachedImagePath!.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 40,
              height: 40,
              child: isUrl
                  ? Image.network(
                      widget.attachedImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) =>
                          const Icon(Icons.broken_image, size: 20),
                    )
                  : const Icon(Icons.image, size: 24, color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Text(
              isUrl ? 'Image from URL' : 'Attached Image',
              style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: widget.onRemoveImage,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.close, size: 18, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isReadyToSend = widget.attachedImagePath != null || _hasText;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttachedImage(),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: widget.onUpload,
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.blueGrey,
                ),
                padding: const EdgeInsets.only(bottom: 10, left: 4),
              ),

              // TextField
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  decoration: const InputDecoration(
                    hintText: "Type a message... (use / for prompts)",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => isReadyToSend ? widget.onSend() : null,
                ),
              ),

              IconButton(
                onPressed: isReadyToSend ? widget.onSend : null,
                icon: Icon(
                  Icons.send,
                  color: isReadyToSend ? Colors.blue.shade700 : Colors.grey,
                ),
                padding: const EdgeInsets.only(bottom: 10, right: 4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

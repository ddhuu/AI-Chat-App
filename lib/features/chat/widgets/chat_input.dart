import 'package:flutter/material.dart';
import 'dart:io';

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
    if (widget.attachedImagePath == null) return const SizedBox.shrink();

    final bool isUrl = widget.attachedImagePath!.startsWith('http');

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 60,
              child: isUrl
                  ? Image.network(
                      widget.attachedImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Colors.grey,
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(widget.attachedImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            size: 24,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Image info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.image, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isUrl ? 'Image from URL' : 'Uploaded image',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isUrl
                      ? Uri.parse(widget.attachedImagePath!).host
                      : widget.attachedImagePath!.split('/').last,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Remove button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onRemoveImage,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 18, color: Colors.grey.shade700),
              ),
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

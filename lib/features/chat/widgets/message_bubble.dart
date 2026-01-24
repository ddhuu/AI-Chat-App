import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/colors.dart';

class MessageBubble extends StatefulWidget {
  final String message;
  final bool isUser;
  final String? imageUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.imageUrl,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isLiked = false;
  bool _isDisliked = false;

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) _isDisliked = false;
    });
  }

  void _handleDislike() {
    setState(() {
      _isDisliked = !_isDisliked;
      if (_isDisliked) _isLiked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: widget.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!widget.isUser) _buildAvatar(false),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.isUser
                        ? AppColors.primary
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.imageUrl != null) ...[
                        _buildMessageImage(),
                        if (widget.message.isNotEmpty)
                          const SizedBox(height: 8),
                      ],
                      if (widget.message.isNotEmpty)
                        Text(
                          widget.message,
                          style: TextStyle(
                            color: widget.isUser
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (widget.isUser) _buildAvatar(true),
            ],
          ),

          // Action buttons for AI messages
          if (!widget.isUser) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(
                    icon: Icons.content_copy,
                    onTap: _handleCopy,
                    tooltip: 'Copy',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.thumb_up,
                    onTap: _handleLike,
                    tooltip: 'Like',
                    isActive: _isLiked,
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.thumb_down,
                    onTap: _handleDislike,
                    tooltip: 'Dislike',
                    isActive: _isDisliked,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isActive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: isUser ? AppColors.primary : Colors.grey.shade300,
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: isUser ? Colors.white : AppColors.primary,
        size: 20,
      ),
    );
  }

  Widget _buildMessageImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
        child: widget.imageUrl!.startsWith('http')
            ? Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              )
            : Image.file(
                File(widget.imageUrl!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image, size: 40),
                  );
                },
              ),
      ),
    );
  }
}

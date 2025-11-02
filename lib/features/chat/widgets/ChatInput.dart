import 'package:flutter/material.dart';

class ChatInputBox extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onUpload;
  // NEW: Properties for image preview state
  final String? inputImagePath;
  final VoidCallback? onClearImage;

  const ChatInputBox({
    super.key,
    required this.onSend,
    required this.onUpload,
    this.inputImagePath, // Optional path to display
    this.onClearImage, // Function to clear the path
  });

  // Widget to show image preview and clear button
  Widget _buildImagePreview() {
    if (inputImagePath == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mock image preview area
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              // In a real app, use Image.file(File(inputImagePath!))
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image, size: 30, color: Colors.blueGrey),
          ),
          const SizedBox(width: 8),
          // Filename or source display
          Flexible(
            child: Text(
              'Attached: ${inputImagePath!.split('/').last}',
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // Clear button
          IconButton(
            onPressed: onClearImage,
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the send button should be active (if text is present OR image is attached)
    // MOCK: For simplicity, we enable send if the image path is not null.
    final bool canSend = inputImagePath != null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade800, width: 0.6),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Align preview to start
        children: [
          // Image Preview
          _buildImagePreview(),

          // Text Field
          const TextField(
            maxLines: 4, // Allow multi-line input
            minLines: 1,
            decoration: InputDecoration(
              hintText: "Ask me anything, press '/' for prompts...",
              hintStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            // MOCK: In a real app, you'd use a TextEditingController here
          ),

          // Action Buttons
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
                  // Send button is enabled only if an image is attached (or text is typed)
                  onPressed: canSend ? onSend : null,
                  icon: Icon(
                    Icons.send,
                    color: canSend ? Colors.blue.shade700 : Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
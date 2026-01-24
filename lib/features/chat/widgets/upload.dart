import 'package:flutter/material.dart';

// Define the signature for the functions passed from ChatPage
typedef UploadAction = Future<void> Function();

class UploadOptionsSheet extends StatelessWidget {
  final UploadAction onGalleryUpload;
  final UploadAction onCameraCapture;
  final UploadAction onPasteScreenshot;

  const UploadOptionsSheet({
    super.key,
    required this.onGalleryUpload,
    required this.onCameraCapture,
    required this.onPasteScreenshot,
  });

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
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Upload image/file from gallery (Upload image to chat)
            _buildOption(
              context,
              icon: Icons.image,
              title: 'Upload Image from Gallery',
              onTap: () async {
                Navigator.pop(context);
                await onGalleryUpload();
              },
            ),
            // 2. Take a new photo (Capture image and chat with it)
            _buildOption(
              context,
              icon: Icons.camera_alt,
              title: 'Take New Photo (Camera)',
              onTap: () async {
                Navigator.pop(context);
                await onCameraCapture();
              },
            ),
            // 3. Paste image from Clipboard (Screenshot and chat)
            _buildOption(
              context,
              icon: Icons.content_paste,
              title: 'Paste Image / Screenshot',
              onTap: () async {
                Navigator.pop(context);
                await onPasteScreenshot();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget builder for each upload option item
  Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700),
      title: Text(title),
      onTap: onTap,
    );
  }
}
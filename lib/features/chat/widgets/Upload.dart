import 'package:flutter/material.dart';

class UploadOptionsSheet extends StatelessWidget {
  const UploadOptionsSheet({super.key});

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
            _buildOption(
              context,
              icon: Icons.image,
              title: 'Upload image',
              onTap: () {
                Navigator.pop(context);
                // Handle upload image
              },
            ),
            _buildOption(
              context,
              icon: Icons.camera_alt,
              title: 'Take photo',
              onTap: () {
                Navigator.pop(context);
                // Handle take photo
              },
            ),
            _buildOption(
              context,
              icon: Icons.terminal,
              title: 'Prompt',
              onTap: () {
                Navigator.pop(context);
                // Handle prompt
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}

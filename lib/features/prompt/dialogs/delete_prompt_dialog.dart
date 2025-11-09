import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class DeletePromptDialog extends StatelessWidget {
  final String promptName;
  final VoidCallback onConfirm;

  const DeletePromptDialog({
    super.key,
    required this.promptName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Delete Prompt',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Are you sure you want to delete "$promptName"? This action cannot be undone.',
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

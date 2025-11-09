// lib/screens/knowledge/widgets/delete_confirmation_dialog.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String knowledgeName;
  const DeleteConfirmationDialog({super.key, required this.knowledgeName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Delete Knowledge Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false), // Trả về false
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dùng RichText để làm đậm tên
            RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.4),
                children: [
                  const TextSpan(text: 'Are you sure you want to delete "'),
                  TextSpan(
                    text: knowledgeName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const TextSpan(text: '"? This action cannot be undone.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false), // Trả về false
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true), // Trả về true
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Màu đỏ
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
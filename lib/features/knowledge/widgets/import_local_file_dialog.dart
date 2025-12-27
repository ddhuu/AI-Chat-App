// lib/screens/knowledge/widgets/import_local_file_dialog.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import 'import_dialog_helpers.dart'; // Import file helper

class ImportLocalFileDialog extends StatelessWidget {
  const ImportLocalFileDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      // SỬA LỖI: Chuyển Tiêu đề vào 'content'
      title: null,
      titlePadding: EdgeInsets.zero,
      
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Files',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Vùng Drag & Drop
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.sidebarBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border), // Dùng nét liền
              ),
              child: const Column(
                children: [
                  Icon(Icons.upload_file_outlined, color: AppColors.primary, size: 32),
                  SizedBox(height: 16),
                  Text(
                    'Select or drag files',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 4),
                  Text('Up to 5 files, 15MB each', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text('PDF, Word, Excel, images, code files & more', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Schema Generation Prompt
            Row(
              children: [
                Text('Schema Generation Prompt', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(width: 4),
                Text('(Optional)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: "Describe what data to extract (e.g., 'names, emails, phone numbers')",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 8),
            Text(
              'Help the AI understand what information to extract from your files',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // View Documentation
            OutlinedButton(
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View documentation', style: TextStyle(color: AppColors.textPrimary)),
                  SizedBox(width: 8),
                  Icon(Icons.help_outline, size: 16, color: AppColors.textSecondary),
                ],
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 44),
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      
      // Nút bấm riêng cho file này
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () { /* TODO: Xử lý Add Files */ },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Add Files'),
        ),
      ],
    );
  }
}
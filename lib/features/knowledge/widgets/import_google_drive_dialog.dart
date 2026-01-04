// lib/screens/knowledge/widgets/import_google_drive_dialog.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import 'import_dialog_helpers.dart';

class ImportGoogleDriveDialog extends StatelessWidget {
  const ImportGoogleDriveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: null,
      titlePadding: EdgeInsets.zero,
      
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: const Text('Import Google Drive Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name *', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextFormField(decoration: InputDecoration(hintText: 'Enter knowledge unit name', border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  Text('Google Drive Files/Folders *', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: Icon(Icons.cloud_upload_outlined),
                    label: Text('Choose Files or Folders'),
                    onPressed: () { /* TODO: Mở trình chọn file GDrive */ },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  KeepUpdatedSwitch(),
                  SizedBox(height: 16),
                  Text('Schema Generation Prompt (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Describe what data to extract...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),
                  LimitationBox(
                    limitations: [
                      'You can access up to 64 files at a time, with each file being no larger than 10 MB'
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      actionsPadding: const EdgeInsets.all(24.0),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: () { /* TODO: Xử lý Import */ },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Import'),
        ),
      ],
    );
  }
}
// lib/screens/knowledge/widgets/import_confluence_dialog.dart
import 'package:flutter/material.dart';
import 'import_dialog_helpers.dart';
import '/core/constants/colors.dart';

class ImportConfluenceDialog extends StatelessWidget {
  const ImportConfluenceDialog({super.key});

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
                  Expanded(child: const Text('Import Confluence Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
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
                  Text('Wiki Page URL *', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextFormField(decoration: InputDecoration(hintText: 'https://your-domain.atlassian...', border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  Text('Username *', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextFormField(decoration: InputDecoration(hintText: 'Enter your Confluence usern...', border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  Text('API Token *', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextFormField(decoration: InputDecoration(hintText: 'Enter your Confluence API to...', border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  KeepUpdatedSwitch(),
                  SizedBox(height: 16),
                  LimitationBox(
                    limitations: [
                      'You can retrieve up to 128 pages at a time'
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
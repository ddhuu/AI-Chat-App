// lib/screens/knowledge/widgets/import_web_dialog.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import 'import_dialog_helpers.dart'; // Import file helper

enum ImportType { single, whole }

class ImportWebDialog extends StatefulWidget {
  const ImportWebDialog({super.key});
  @override
  State<ImportWebDialog> createState() => _ImportWebDialogState();
}

class _ImportWebDialogState extends State<ImportWebDialog> {
  ImportType _importType = ImportType.single;

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
                  Expanded(child: const Text('Import Web Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
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
                  Text('Web URL *', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  TextFormField(decoration: InputDecoration(hintText: 'https://example.com', border: OutlineInputBorder())),
                  SizedBox(height: 16),
                  KeepUpdatedSwitch(),
                  SizedBox(height: 16),
                  Text('Import Type', style: TextStyle(fontWeight: FontWeight.w500)),
                  RadioListTile<ImportType>(
                    title: Text('Single page'),
                    value: ImportType.single,
                    groupValue: _importType,
                    onChanged: (val) => setState(() => _importType = val!),
                  ),
                  RadioListTile<ImportType>(
                    title: Text('Whole sites'),
                    value: ImportType.whole,
                    groupValue: _importType,
                    onChanged: (val) => setState(() => _importType = val!),
                  ),
                  SizedBox(height: 16),
                  LimitationBox(
                    limitations: [
                      'Importing the entire website may take some time to complete.',
                      'You can load up to 64 pages at a time'
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
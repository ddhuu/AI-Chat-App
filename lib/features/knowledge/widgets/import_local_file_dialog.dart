import 'dart:typed_data'; // Import để dùng Uint8List

import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/import_provider.dart';
import '/core/constants/colors.dart';

class ImportLocalFileDialog extends StatefulWidget {
  const ImportLocalFileDialog({super.key});

  @override
  State<ImportLocalFileDialog> createState() => _ImportLocalFileDialogState();
}

class _ImportLocalFileDialogState extends State<ImportLocalFileDialog> {
  List<PlatformFile> _selectedFiles = [];
  final TextEditingController _schemaPromptController = TextEditingController();
  bool _isDragging = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'csv', 'md', 'json'],
      );

      if (result != null) {
        _addFiles(result.files);
      }
    } catch (e) {
      print("Error picking files: $e");
    }
  }

  void _addFiles(List<PlatformFile> files) {
    setState(() {
      int currentLength = _selectedFiles.length;
      int availableSlots = 5 - currentLength;

      if (availableSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Limit of 5 files reached.')),
        );
        return;
      }

      if (files.length > availableSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only select up to 5 files.')),
        );
        _selectedFiles.addAll(files.sublist(0, availableSlots));
      } else {
        _selectedFiles.addAll(files);
      }
    });
  }

  void _removeFile(PlatformFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
  }

  @override
  void dispose() {
    _schemaPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importProvider = Provider.of<ImportProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: null,
      titlePadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            DropTarget(
              onDragEntered: (_) => setState(() => _isDragging = true),
              onDragExited: (_) => setState(() => _isDragging = false),
              onDragDone: (details) async {
                setState(() => _isDragging = false);

                final List<PlatformFile> newFiles = [];
                for (final XFile xfile in details.files) {
                  final int size = await xfile.length();
                  Uint8List? bytes;

                  if (kIsWeb) {
                    bytes = await xfile.readAsBytes();
                  }

                  newFiles.add(PlatformFile(
                    name: xfile.name,
                    size: size,
                    bytes: bytes,
                    path: kIsWeb ? null : xfile.path,
                    readStream: null,
                  ));
                }

                _addFiles(newFiles);
              },
              child: GestureDetector(
                onTap: _pickFiles,
                child: Container(
                  height: _selectedFiles.isEmpty ? 180 : null,
                  constraints: const BoxConstraints(minHeight: 180),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isDragging ? Colors.blue.withOpacity(0.05) : AppColors.sidebarBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isDragging ? Colors.blue : AppColors.border,
                      width: _isDragging ? 2 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: _selectedFiles.isEmpty
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file_outlined, color: AppColors.primary, size: 32),
                      SizedBox(height: 16),
                      Text(
                        'Select or drag files',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text('Up to 5 files, 15MB each', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('PDF, Word, Excel, code files & more', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${_selectedFiles.length} files selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                          TextButton(onPressed: _pickFiles, child: const Text("Add More"))
                        ],
                      ),
                      const Divider(),
                      ..._selectedFiles.map((file) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(color: AppColors.border),
                            borderRadius: BorderRadius.circular(4)
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.insert_drive_file, color: AppColors.textSecondary, size: 20),
                          title: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('${(file.size / 1024).toStringAsFixed(1)} KB', style: const TextStyle(fontSize: 10)),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                            onPressed: () => _removeFile(file),
                          ),
                        ),
                      )),
                      if (_isDragging)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Center(child: Text("Drop to add...", style: TextStyle(color: Colors.blue))),
                        )
                    ],
                  ),
                ),
              ),
            ),

            // Loading Indicator
            if (importProvider.isImporting) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(value: importProvider.uploadProgress),
              const SizedBox(height: 4),
              Text(
                'Uploading file ${importProvider.currentFileIndex}/${importProvider.totalFiles}...',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],

            const SizedBox(height: 24),
            const Row(
              children: [
                Text('Schema Generation Prompt', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(width: 4),
                Text('(Optional)', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _schemaPromptController,
              decoration: const InputDecoration(
                hintText: "Describe what data to extract (e.g., 'names, emails, phone numbers')",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Documentation Link
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                foregroundColor: AppColors.textPrimary,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('View documentation', style: TextStyle(color: AppColors.textPrimary)),
                  SizedBox(width: 8),
                  Icon(Icons.help_outline, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: importProvider.isImporting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: (importProvider.isImporting || _selectedFiles.isEmpty)
              ? null
              : () async {
            await importProvider.importFiles(files: _selectedFiles);

            if (mounted && importProvider.errorMessage == null) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Files imported successfully!"))
              );
            } else if (mounted && importProvider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: ${importProvider.errorMessage}"))
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: importProvider.isImporting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Add Files'),
        ),
      ],
    );
  }
}
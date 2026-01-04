// lib/screens/knowledge/widgets/import_web_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../services/import_service.dart';
import 'import_dialog_helpers.dart';

enum ImportType { single, whole }

class ImportWebDialog extends StatefulWidget {
  final String knowledgeId;

  const ImportWebDialog({
    super.key,
    required this.knowledgeId,
  });

  @override
  State<ImportWebDialog> createState() => _ImportWebDialogState();
}

class _ImportWebDialogState extends State<ImportWebDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _urlController;

  ImportType _importType = ImportType.single;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _urlController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<ImportService>().importWebsite(
        knowledgeId: widget.knowledgeId,
        unitName: _nameController.text.trim(),
        webUrl: _urlController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Website imported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: null,
      titlePadding: EdgeInsets.zero,

      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                        child: Text(
                            'Import Web Source',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                        )
                    ),
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
                    // Field: Name
                    const Text('Name *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                          hintText: 'Enter knowledge unit name',
                          border: OutlineInputBorder()
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    const Text('Web URL *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                          hintText: 'https://example.com',
                          border: OutlineInputBorder()
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a URL';
                        }
                        final uri = Uri.tryParse(value);
                        if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                          return 'Please enter a valid URL (e.g., https://example.com)';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    const KeepUpdatedSwitch(),

                    const SizedBox(height: 16),
                    const Text('Import Type', style: TextStyle(fontWeight: FontWeight.w500)),
                    RadioListTile<ImportType>(
                      title: const Text('Single page'),
                      value: ImportType.single,
                      groupValue: _importType,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _importType = val!),
                    ),
                    RadioListTile<ImportType>(
                      title: const Text('Whole sites'),
                      value: ImportType.whole,
                      groupValue: _importType,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _importType = val!),
                    ),

                    const SizedBox(height: 16),
                    const LimitationBox(
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
      ),

      actionsPadding: const EdgeInsets.all(24.0),
      actions: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
          )
              : const Text('Import'),
        ),
      ],
    );
  }
}
// lib/screens/knowledge/widgets/import_slack_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/import_provider.dart';
import '/core/constants/colors.dart';

class ImportSlackDialog extends StatefulWidget {
  const ImportSlackDialog({super.key});

  @override
  State<ImportSlackDialog> createState() => _ImportSlackDialogState();
}

class _ImportSlackDialogState extends State<ImportSlackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _onImport() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<ImportProvider>();

    final result = await provider.importSlack(
      unitName: _nameController.text.trim(),
      slackBotToken: _tokenController.text.trim(),
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import Slack successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Import failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ImportProvider, bool>((p) => p.isImporting);

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
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(child: Text('Import Slack Source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
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

              // --- Body ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Name *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(hintText: 'Enter knowledge unit name', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    const Text('Slack Bot Token *', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _tokenController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(hintText: 'xoxb-...', border: OutlineInputBorder()),
                      validator: (v) => v?.isEmpty == true ? 'Token is required' : null,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text("Keep updated automatically"),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.grey),
                          SizedBox(width: 8),
                          Expanded(child: Text('You can view all sessions from the past 60 days', style: TextStyle(fontSize: 13))),
                        ],
                      ),
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
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _onImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Import'),
        ),
      ],
    );
  }
}
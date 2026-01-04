import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/import_provider.dart';
import '/core/constants/colors.dart';

class ImportConfluenceDialog extends StatefulWidget {
  const ImportConfluenceDialog({super.key});

  @override
  State<ImportConfluenceDialog> createState() => _ImportConfluenceDialogState();
}

class _ImportConfluenceDialogState extends State<ImportConfluenceDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _keepUpdated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleImport() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final provider = context.read<ImportProvider>();

    final result = await provider.importConfluence(
      unitName: _nameController.text.trim(),
      wikiPageUrl: _urlController.text.trim(),
      confluenceUsername: _usernameController.text.trim(),
      confluenceAccessToken: _tokenController.text.trim(),
      autoReindexEnabled: _keepUpdated,
    );

    if (!mounted) return;

    if (result != null) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Import Confluence successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Import failed'),
          backgroundColor: Colors.red,
        ),
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
                    const Expanded(
                        child: Text(
                          'Import Confluence Source',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary
                          ),
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

              // --- Form Fields ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildLabel('Name'),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                          hintText: 'Enter knowledge unit name',
                          border: OutlineInputBorder()
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // URL Field
                    _buildLabel('Wiki Page URL'),
                    TextFormField(
                      controller: _urlController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                          hintText: 'https://your-domain.atlassian.net',
                          border: OutlineInputBorder()
                      ),
                      validator: (v) => v?.isEmpty == true ? 'URL is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Username Field
                    _buildLabel('Username'),
                    TextFormField(
                      controller: _usernameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                          hintText: 'Enter your Confluence username',
                          border: OutlineInputBorder()
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Username is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Token Field
                    _buildLabel('API Token'),
                    TextFormField(
                      controller: _tokenController,
                      enabled: !isLoading,
                      obscureText: true, // Ẩn token
                      decoration: const InputDecoration(
                          hintText: 'Enter your Confluence API token',
                          border: OutlineInputBorder()
                      ),
                      validator: (v) => v?.isEmpty == true ? 'Token is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Switch Keep Updated
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Keep Files Updated Automatically',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Switch(
                          value: _keepUpdated,
                          onChanged: isLoading ? null : (val) => setState(() => _keepUpdated = val),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Current Limitation:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[800], fontSize: 13)),
                              const SizedBox(width: 4),
                              Icon(Icons.help_outline, size: 16, color: Colors.blue[800]),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildBulletPoint('You can retrieve up to 128 pages at a time'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('•  ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(color: Colors.blue[900], fontSize: 13),
                                    children: const [
                                      TextSpan(text: 'Need more? '),
                                      TextSpan(text: 'hello@jarvis.cx', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
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
          onPressed: isLoading ? null : _handleImport,
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

  // Helper tạo label có dấu *
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: '$text ',
          style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
          children: const [
            TextSpan(text: '*', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('•  ', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        Expanded(child: Text(text, style: TextStyle(color: Colors.blue[900], fontSize: 13))),
      ],
    );
  }
}
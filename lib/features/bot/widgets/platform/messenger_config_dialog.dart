import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/colors.dart';
import '../../models/assistant_model.dart';
import '../../providers/assistant_provider.dart';

class MessengerConfigDialog extends StatefulWidget {
  final Assistant assistant;

  const MessengerConfigDialog({super.key, required this.assistant});

  @override
  State<MessengerConfigDialog> createState() => _MessengerConfigDialogState();
}

class _MessengerConfigDialogState extends State<MessengerConfigDialog> {
  final _formKey = GlobalKey<FormState>();
  final _botTokenController = TextEditingController();
  final _pageIdController = TextEditingController();
  final _appSecretController = TextEditingController();
  bool _isVerifying = false;

  @override
  void dispose() {
    _botTokenController.dispose();
    _pageIdController.dispose();
    _appSecretController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isVerifying = true);

    try {
      final assistantProvider = context.read<AssistantProvider>();
      final success = await assistantProvider.verifyMessengerConfig(
        botToken: _botTokenController.text.trim(),
        pageId: _pageIdController.text.trim(),
        appSecret: _appSecretController.text.trim(),
      );

      if (mounted) {
        setState(() => _isVerifying = false);

        if (success) {
          Navigator.pop(context, {
            'verified': true,
            'config': {
              'botToken': _botTokenController.text.trim(),
              'pageId': _pageIdController.text.trim(),
              'appSecret': _appSecretController.text.trim(),
            },
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to verify Messenger credentials'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configure Messenger',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _botTokenController,
                  decoration: InputDecoration(
                    labelText: 'Page Access Token *',
                    hintText: 'Enter page access token',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.key),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter page access token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pageIdController,
                  decoration: InputDecoration(
                    labelText: 'Page ID *',
                    hintText: 'Enter Facebook page ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.tag),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter page ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _appSecretController,
                  decoration: InputDecoration(
                    labelText: 'App Secret *',
                    hintText: 'Enter app secret',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.security),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter app secret';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isVerifying ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verify & Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

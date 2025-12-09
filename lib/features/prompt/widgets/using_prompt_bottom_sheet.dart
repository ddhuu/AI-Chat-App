import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';

class UsingPromptBottomSheet extends StatefulWidget {
  final PromptModel prompt;

  const UsingPromptBottomSheet({super.key, required this.prompt});

  @override
  State<UsingPromptBottomSheet> createState() => _UsingPromptBottomSheetState();
}

class _UsingPromptBottomSheetState extends State<UsingPromptBottomSheet> {
  List<TextEditingController> _controllers = [];
  List<String> _keywords = [];
  bool _isShowPrompt = false;

  @override
  void initState() {
    super.initState();
    _keywords = widget.prompt.extractKeywords();

    // Create controllers for each keyword
    for (var _ in _keywords) {
      _controllers.add(TextEditingController());
    }

    // If no keywords, show prompt immediately
    if (_keywords.isEmpty) {
      _isShowPrompt = true;
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getFilledPrompt() {
    Map<String, String> inputs = {};
    for (int i = 0; i < _keywords.length; i++) {
      inputs[_keywords[i]] = _controllers[i].text;
    }
    return widget.prompt.fillKeywords(inputs);
  }

  void _sendPrompt() {
    try {
      final filledPrompt = _getFilledPrompt();
      print(
        'Sending filled prompt: ${filledPrompt.substring(0, filledPrompt.length > 50 ? 50 : filledPrompt.length)}...',
      );
      // Close this bottom sheet and return filled prompt
      Navigator.pop(context, filledPrompt);
    } catch (e) {
      print('Error in _sendPrompt: $e');
      // Still try to close the bottom sheet
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _addToChatInput() {
    // Return raw prompt content to be added to chat input
    Navigator.pop(context, widget.prompt.content);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isShowPrompt ? 500 : 400,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.prompt.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // View Prompt Button or Prompt Display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: !_isShowPrompt
                ? TextButton(
                    onPressed: () {
                      setState(() {
                        _isShowPrompt = true;
                      });
                    },
                    child: const Text(
                      'View Prompt',
                      style: TextStyle(fontSize: 14, color: AppColors.primary),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Prompt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: _addToChatInput,
                            child: const Text(
                              'Add to chat input',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 100),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Text(
                            widget.prompt.content,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
          ),

          // User Input Section
          if (_keywords.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Icon(Icons.edit_note, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Fill in the details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _keywords.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _keywords[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _controllers[index],
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Enter ${_keywords[index].toLowerCase()}',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.divider.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ] else
            const Spacer(),

          // Send Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendPrompt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';

class UsingPromptBottomSheet extends StatefulWidget {
  final PromptModel prompt;

  const UsingPromptBottomSheet({
    super.key,
    required this.prompt,
  });

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
    final filledPrompt = _getFilledPrompt();
    // Close all bottom sheets and return to chat
    Navigator.of(context).popUntil((route) => route.isFirst);
    
    // TODO: Send prompt to chat
    // This will be implemented when integrating with ChatPage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Prompt sent: ${filledPrompt.substring(0, 50)}...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _isShowPrompt ? 450 : 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.prompt.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
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
                            onPressed: () {
                              // TODO: Add to chat input
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to chat input'),
                                ),
                              );
                            },
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                'User input',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _keywords.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: _controllers[index],
                      decoration: InputDecoration(
                        hintText: _keywords[index],
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
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

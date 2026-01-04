import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';
import '../providers/prompt_provider.dart';
import 'using_prompt_bottom_sheet.dart';

/// Quick prompt suggestion overlay that appears when user types "/"
class PromptSuggestionOverlay extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String?) onUsePrompt;

  const PromptSuggestionOverlay({
    super.key,
    required this.onClose,
    required this.onUsePrompt,
  });

  @override
  State<PromptSuggestionOverlay> createState() =>
      _PromptSuggestionOverlayState();
}

class _PromptSuggestionOverlayState extends State<PromptSuggestionOverlay> {
  bool _isLoading = true;
  List<PublicPrompt> _prompts = [];
  int _offset = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    // Load prompts after build is complete to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPrompts();
    });
  }

  Future<void> _loadPrompts() async {
    if (!mounted) return;

    final promptProvider = context.read<PromptProvider>();

    await promptProvider.loadPublicPrompts(
      offset: _offset,
      limit: 20,
      isLoadMore: _offset > 0,
    );

    if (mounted) {
      setState(() {
        _prompts = promptProvider.publicPrompts;
        _hasMore = promptProvider.publicHasNext;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _offset += 20;
    });

    await _loadPrompts();
  }

  Future<void> _handlePromptTap(PublicPrompt prompt) async {
    widget.onClose();

    final String? filledPrompt = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UsingPromptBottomSheet(prompt: prompt),
    );

    widget.onUsePrompt(filledPrompt);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_prompts.isEmpty) {
      return Center(
        child: Text(
          'No prompts available',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      shrinkWrap: true,
      itemCount: _prompts.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Load more button
        if (index == _prompts.length) {
          return Center(
            child: TextButton(
              onPressed: _loadMore,
              child: const Text(
                'Load more...',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          );
        }

        final prompt = _prompts[index];
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            prompt.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: prompt.description.isNotEmpty
              ? Text(
                  prompt.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textHint,
          ),
          onTap: () => _handlePromptTap(prompt),
        );
      },
    );
  }
}

/// Creates an overlay entry for prompt suggestions
class PromptSuggestionOverlayHelper {
  final BuildContext context;
  final VoidCallback onClose;
  final Function(String?) onUsePrompt;

  PromptSuggestionOverlayHelper({
    required this.context,
    required this.onClose,
    required this.onUsePrompt,
  });

  OverlayEntry createOverlayEntry() {
    // Get the position of the text field
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      throw Exception('RenderBox not found');
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate position ABOVE the text field
    final overlayHeight = 300.0;
    final bottomPosition =
        screenHeight - offset.dy + 8; // Space above text field

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent background to detect taps outside
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(color: Colors.transparent),
          ),

          // The actual overlay - positioned ABOVE the text field
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPosition,
            height: overlayHeight,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 8.0,
              shadowColor: Colors.black.withOpacity(0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Quick Prompts',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),

                  // Prompt list
                  Expanded(
                    child: PromptSuggestionOverlay(
                      onClose: onClose,
                      onUsePrompt: onUsePrompt,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

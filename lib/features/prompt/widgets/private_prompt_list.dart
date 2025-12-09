import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';
import '../dialogs/edit_prompt_dialog.dart';
import '../dialogs/delete_prompt_dialog.dart';
import 'using_prompt_bottom_sheet.dart';

class PrivatePromptList extends StatefulWidget {
  final List<PrivatePrompt> prompts;
  final Function(String) onDelete;
  final Function(PrivatePrompt) onEdit;
  final Function(String, bool) onToggleFavorite;

  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const PrivatePromptList({
    super.key,
    required this.prompts,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleFavorite,
    required this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  State<PrivatePromptList> createState() => _PrivatePromptListState();
}

class _PrivatePromptListState extends State<PrivatePromptList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !widget.isLoadingMore &&
        widget.hasMore) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prompts.isEmpty && !widget.isLoadingMore) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_add_outlined, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'No private prompts yet',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first prompt',
              style: TextStyle(fontSize: 14, color: AppColors.textHint),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: widget.prompts.length + (widget.hasMore ? 1 : 0),
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: AppColors.divider),
      itemBuilder: (context, index) {
        if (index == widget.prompts.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final prompt = widget.prompts[index];
        return ListTile(
          contentPadding: const EdgeInsets.only(
            left: 20,
            right: 4,
            top: 4,
            bottom: 4,
          ),
          title: Text(
            prompt.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  prompt.isFavorite ? Icons.star : Icons.star_border,
                  color: prompt.isFavorite
                      ? Colors.amber
                      : AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () =>
                    widget.onToggleFavorite(prompt.id, !prompt.isFavorite),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditPromptDialog(
                      prompt: prompt,
                      onSave: (updatedPrompt) => widget.onEdit(updatedPrompt),
                    ),
                  );
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeletePromptDialog(
                      promptName: prompt.name,
                      onConfirm: () => widget.onDelete(prompt.id),
                    ),
                  );
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () async {
                  final String? filledPrompt =
                      await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            UsingPromptBottomSheet(prompt: prompt),
                      );

                  // Close PromptLibraryBottomSheet and return filled prompt
                  if (filledPrompt != null && filledPrompt.isNotEmpty) {
                    if (context.mounted) {
                      Navigator.pop(context, filledPrompt);
                    }
                  }
                },
                icon: Icon(
                  Icons.arrow_forward,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

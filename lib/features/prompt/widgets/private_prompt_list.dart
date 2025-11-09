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

  const PrivatePromptList({
    super.key,
    required this.prompts,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleFavorite,
  });

  @override
  State<PrivatePromptList> createState() => _PrivatePromptListState();
}

class _PrivatePromptListState extends State<PrivatePromptList> {
  @override
  Widget build(BuildContext context) {
    if (widget.prompts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No private prompts yet',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first prompt',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: widget.prompts.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        final prompt = widget.prompts[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
              // Favorite button
              IconButton(
                icon: Icon(
                  prompt.isFavorite ? Icons.star : Icons.star_border,
                  color: prompt.isFavorite ? Colors.amber : AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  widget.onToggleFavorite(prompt.id, !prompt.isFavorite);
                },
              ),
              // Edit button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => EditPromptDialog(
                      prompt: prompt,
                      onSave: (updatedPrompt) {
                        widget.onEdit(updatedPrompt);
                      },
                    ),
                  );
                },
                icon: Icon(
                  Icons.edit_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              // Delete button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => DeletePromptDialog(
                      promptName: prompt.name,
                      onConfirm: () {
                        widget.onDelete(prompt.id);
                      },
                    ),
                  );
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              // Use button
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => UsingPromptBottomSheet(
                      prompt: prompt,
                    ),
                  );
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

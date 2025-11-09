import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';
import '../dialogs/info_prompt_dialog.dart';
import 'using_prompt_bottom_sheet.dart';

class PublicPromptList extends StatefulWidget {
  final List<PublicPrompt> prompts;
  final Function(String, bool) onToggleFavorite;

  const PublicPromptList({
    super.key,
    required this.prompts,
    required this.onToggleFavorite,
  });

  @override
  State<PublicPromptList> createState() => _PublicPromptListState();
}

class _PublicPromptListState extends State<PublicPromptList> {
  @override
  Widget build(BuildContext context) {
    if (widget.prompts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'No prompts found',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prompt.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              if (prompt.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  prompt.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
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
              // Info button
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => InfoPromptDialog(
                      prompt: prompt,
                    ),
                  );
                },
                icon: Icon(
                  Icons.info_outline,
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

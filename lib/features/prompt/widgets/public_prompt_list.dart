import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';
import '../dialogs/info_prompt_dialog.dart';
import 'using_prompt_bottom_sheet.dart';

class PublicPromptList extends StatefulWidget {
  final List<PublicPrompt> prompts;
  final Function(String, bool) onToggleFavorite;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  const PublicPromptList({
    super.key,
    required this.prompts,
    required this.onToggleFavorite,
    required this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  State<PublicPromptList> createState() => _PublicPromptListState();
}

class _PublicPromptListState extends State<PublicPromptList> {
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
            Icon(Icons.search_off, size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              'No prompts found',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      itemCount: widget.prompts.length + (widget.hasMore ? 1 : 0),
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.divider,
      ),
      itemBuilder: (context, index) {
        if (index == widget.prompts.length) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

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
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => InfoPromptDialog(prompt: prompt),
                  );
                },
                icon: Icon(Icons.info_outline, color: AppColors.textSecondary, size: 20),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => UsingPromptBottomSheet(prompt: prompt),
                  );
                },
                icon: Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
              ),
            ],
          ),
        );
      },
    );
  }
}
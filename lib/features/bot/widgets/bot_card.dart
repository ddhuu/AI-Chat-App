import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/bot_model.dart';
import '../models/assistant_model.dart';
import 'publishing_platform_dialog.dart';

class BotCard extends StatelessWidget {
  final BotModel? bot;
  final Assistant? assistant;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onFavorite;
  final VoidCallback? onPublish;
  final VoidCallback? onDelete;

  const BotCard({
    super.key,
    this.bot,
    this.assistant,
    this.onTap,
    this.onEdit,
    this.onFavorite,
    this.onPublish,
    this.onDelete,
  }) : assert(
         bot != null || assistant != null,
         'Either bot or assistant must be provided',
       );

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider.withOpacity(0.3)),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon, Name, Actions
            Row(
              children: [
                // Bot Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Bot Name
                Expanded(
                  child: Text(
                    bot?.name ?? assistant?.assistantName ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Action Icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Share/Publish Button
                    IconButton(
                      icon: Icon(
                        Icons.share_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () async {
                        final platforms = await showDialog<List<String>>(
                          context: context,
                          builder: (context) =>
                              const PublishingPlatformDialog(),
                        );
                        if (platforms != null && onPublish != null) {
                          onPublish!();
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),

                    // Favorite Button
                    IconButton(
                      icon: Icon(
                        (bot?.isFavorite ?? assistant?.isFavorite ?? false)
                            ? Icons.star
                            : Icons.star_border,
                        color:
                            (bot?.isFavorite ?? assistant?.isFavorite ?? false)
                            ? Colors.amber
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),

                    // Delete Button
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              (bot?.description ?? assistant?.description ?? '').isNotEmpty
                  ? (bot?.description ?? assistant?.description ?? '')
                  : 'No description available',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Footer Row: Model Info & Action Buttons
            Row(
              children: [
                // Model Icon & Name
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.psychology_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'GPT-4o mini',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Edit Button
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text(
                    'Edit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(0, 36),
                  ),
                ),
                const SizedBox(width: 8),

                // Chat Now Button
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text(
                    'Chat Now',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                    minimumSize: const Size(0, 36),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

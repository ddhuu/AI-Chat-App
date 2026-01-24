// lib/screens/knowledge/widgets/knowledge_item_card.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';
import 'knowledge_item.dart';

class KnowledgeItemCard extends StatelessWidget {
  final KnowledgeItem item;
  final VoidCallback onTap; // <-- THÊM MỚI
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const KnowledgeItemCard({
    super.key,
    required this.item,
    required this.onTap, // <-- THÊM MỚI
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // SỬA: Bọc trong Material/InkWell để có thể nhấp
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap, // <-- SỬA: Gắn hàm
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.folder_open_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'Delete',
                  ),
                  IconButton(
                    onPressed: onTap, // <-- SỬA: Gắn hàm
                    icon: const Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    tooltip: 'View details',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../models/knowledge_model.dart';

class SelectKnowledgeDialog extends StatefulWidget {
  final List<String> selectedKnowledgeIds;

  const SelectKnowledgeDialog({super.key, required this.selectedKnowledgeIds});

  @override
  State<SelectKnowledgeDialog> createState() => _SelectKnowledgeDialogState();
}

class _SelectKnowledgeDialogState extends State<SelectKnowledgeDialog> {
  final List<KnowledgeModel> _allKnowledge = KnowledgeModel.getMockKnowledge();
  final TextEditingController _searchController = TextEditingController();
  List<KnowledgeModel> _filteredKnowledge = [];

  @override
  void initState() {
    super.initState();
    _filteredKnowledge = _allKnowledge;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterKnowledge(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredKnowledge = _allKnowledge;
      } else {
        _filteredKnowledge = _allKnowledge
            .where((k) => k.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.selectKnowledge,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Search Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterKnowledge,
                decoration: InputDecoration(
                  hintText: 'knowledge.search_knowledge'.tr(),
                  hintStyle: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Knowledge List
            Expanded(
              child: _filteredKnowledge.isEmpty
                  ? const Center(
                      child: Text(
                        AppStrings.noKnowledge,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredKnowledge.length,
                      itemBuilder: (context, index) {
                        final knowledge = _filteredKnowledge[index];
                        final isSelected = widget.selectedKnowledgeIds.contains(
                          knowledge.id,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.library_books,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              knowledge.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${knowledge.size.toStringAsFixed(2)} MB',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, knowledge);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? AppColors.success
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                elevation: 0,
                                minimumSize: const Size(0, 32),
                              ),
                              child: Text(
                                isSelected ? 'Đã thêm' : 'Thêm',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

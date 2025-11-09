import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';
import '../data/mock_prompts.dart';
import '../widgets/private_prompt_list.dart';
import '../widgets/public_prompt_list.dart';
import '../dialogs/add_prompt_dialog.dart';

class PromptLibraryBottomSheet extends StatefulWidget {
  const PromptLibraryBottomSheet({super.key});

  @override
  State<PromptLibraryBottomSheet> createState() => _PromptLibraryBottomSheetState();
}

class _PromptLibraryBottomSheetState extends State<PromptLibraryBottomSheet> {
  // Tab selection: 0 = Private, 1 = Public
  int _selectedTab = 0;
  
  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Favorite filter
  bool _showFavoritesOnly = false;
  
  // Category filter (for public prompts)
  String _selectedCategory = PromptCategory.all;
  bool _showAllCategories = false;
  
  // Data
  List<PrivatePrompt> _privatePrompts = [];
  List<PublicPrompt> _publicPrompts = [];

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPrompts() {
    setState(() {
      _privatePrompts = MockPrivatePrompts.getPrompts();
      _publicPrompts = MockPublicPrompts.getPrompts();
    });
  }

  List<PrivatePrompt> _getFilteredPrivatePrompts() {
    return _privatePrompts.where((prompt) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!prompt.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !prompt.content.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      // Favorite filter
      if (_showFavoritesOnly && !prompt.isFavorite) {
        return false;
      }
      return true;
    }).toList();
  }

  List<PublicPrompt> _getFilteredPublicPrompts() {
    return _publicPrompts.where((prompt) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!prompt.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !prompt.content.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !prompt.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      // Category filter
      if (_selectedCategory != PromptCategory.all && prompt.category != _selectedCategory) {
        return false;
      }
      // Favorite filter
      if (_showFavoritesOnly && !prompt.isFavorite) {
        return false;
      }
      return true;
    }).toList();
  }

  void _handleAddPrompt(PrivatePrompt prompt) {
    setState(() {
      _privatePrompts.add(prompt);
    });
  }

  void _handleEditPrompt(PrivatePrompt updatedPrompt) {
    setState(() {
      final index = _privatePrompts.indexWhere((p) => p.id == updatedPrompt.id);
      if (index != -1) {
        _privatePrompts[index] = updatedPrompt;
      }
    });
  }

  void _handleDeletePrompt(String id) {
    setState(() {
      _privatePrompts.removeWhere((p) => p.id == id);
    });
  }

  void _handleToggleFavorite(String id, bool isFavorite) {
    setState(() {
      if (_selectedTab == 0) {
        final prompt = _privatePrompts.firstWhere((p) => p.id == id);
        prompt.isFavorite = isFavorite;
      } else {
        final prompt = _publicPrompts.firstWhere((p) => p.id == id);
        prompt.isFavorite = isFavorite;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPrivatePrompts = _getFilteredPrivatePrompts();
    final filteredPublicPrompts = _getFilteredPublicPrompts();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
          // Modern Header with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prompt Library',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Choose or create your prompts',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddPromptDialog(
                            onAdd: _handleAddPrompt,
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tab Navigation with better design
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Private', 0),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTabButton('Public', 1),
                  ),
                ],
              ),
            ),
          ),

          // Search Box with better styling
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.divider.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search prompts...',
                        hintStyle: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _showFavoritesOnly
                        ? Colors.amber.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _showFavoritesOnly
                          ? Colors.amber
                          : AppColors.divider.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _showFavoritesOnly = !_showFavoritesOnly;
                      });
                    },
                    icon: Icon(
                      _showFavoritesOnly ? Icons.star : Icons.star_border,
                      color: _showFavoritesOnly
                          ? Colors.amber
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category Filter (for Public tab only)
          if (_selectedTab == 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (_showAllCategories
                              ? PromptCategory.allCategories
                              : PromptCategory.allCategories.sublist(0, 4))
                          .map((category) => ChoiceChip(
                                label: Text(category),
                                selected: _selectedCategory == category,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                selectedColor: AppColors.primary,
                                backgroundColor: AppColors.surface,
                                labelStyle: TextStyle(
                                  color: _selectedCategory == category
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                                shape: const StadiumBorder(side: BorderSide.none),
                                showCheckmark: false,
                              ))
                          .toList(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showAllCategories = !_showAllCategories;
                      });
                    },
                    icon: Icon(
                      _showAllCategories
                          ? Icons.arrow_drop_up
                          : Icons.arrow_drop_down,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // Prompt List
          Expanded(
            child: _selectedTab == 0
                ? PrivatePromptList(
                    prompts: filteredPrivatePrompts,
                    onDelete: _handleDeletePrompt,
                    onEdit: _handleEditPrompt,
                    onToggleFavorite: _handleToggleFavorite,
                  )
                : PublicPromptList(
                    prompts: filteredPublicPrompts,
                    onToggleFavorite: _handleToggleFavorite,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Icon(
                  index == 0 ? Icons.lock_outline : Icons.public,
                  color: AppColors.primary,
                  size: 18,
                ),
              if (isSelected) const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

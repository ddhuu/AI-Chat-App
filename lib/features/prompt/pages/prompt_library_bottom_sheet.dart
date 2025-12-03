import 'package:ai_chat_assistant/features/prompt/providers/prompt_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../models/prompt_model.dart';
import '../widgets/private_prompt_list.dart';
import '../widgets/public_prompt_list.dart';
import '../dialogs/add_prompt_dialog.dart';
import 'dart:async';

class PromptLibraryBottomSheet extends StatefulWidget {
  const PromptLibraryBottomSheet({super.key});

  @override
  State<PromptLibraryBottomSheet> createState() =>
      _PromptLibraryBottomSheetState();
}

class _PromptLibraryBottomSheetState extends State<PromptLibraryBottomSheet> {
  // Tab selection: 0 = Private, 1 = Public
  int _selectedTab = 0;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  // Favorite filter
  bool _showFavoritesOnly = false;

  // Category filter (for public prompts)
  String _selectedCategory = PromptCategory.all;
  bool _showAllCategories = false;

  static const int _limit = 20;
  int _publicOffset = 0;
  bool _isLoadingMorePublic = false;
  bool _hasMorePublic = true;

  // Pagination Params cho Private Tab
  int _privateOffset = 0;
  bool _isLoadingMorePrivate = false;
  bool _hasMorePrivate = true;

  @override
  void initState() {
    super.initState();
    _loadData(isRefresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData({bool isRefresh = false}) async {
    final promptProvider = context.read<PromptProvider>();

    if (_selectedTab == 0 || isRefresh) {
      if (isRefresh) {
        _privateOffset = 0;
        _hasMorePrivate = true;
      }

      await promptProvider.loadPrivatePrompts(
        category: _selectedCategory != PromptCategory.all ? _selectedCategory : null,
        isFavorite: _showFavoritesOnly ? true : null,

        offset: _privateOffset,
        limit: _limit,
        isLoadMore: !isRefresh,
      );

      if (mounted) {
        setState(() {
          _hasMorePrivate = promptProvider.privateHasNext;
        });
      }
    }

    if (_selectedTab == 1 || isRefresh) {
      if (isRefresh) {
        _publicOffset = 0;
        _hasMorePublic = true;
      }

      await promptProvider.loadPublicPrompts(
        category: _selectedCategory != PromptCategory.all ? _selectedCategory.toLowerCase() : null,
        isFavorite: _showFavoritesOnly ? true : null,
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
        offset: _publicOffset,
        limit: _limit,
        isLoadMore: !isRefresh,
      );

      if (mounted) {
        setState(() {
          _hasMorePublic = promptProvider.publicHasNext;
        });
      }
    }
  }

  Future<void> _handleLoadMorePublic() async {
    if (_isLoadingMorePublic || !_hasMorePublic) return;

    setState(() {
      _isLoadingMorePublic = true;
    });

    _publicOffset += _limit;

    await _loadData(isRefresh: false);

    setState(() {
      _isLoadingMorePublic = false;
    });
  }

  Future<void> _handleLoadMorePrivate() async {
    if (_isLoadingMorePrivate || !_hasMorePrivate) return;

    setState(() {
      _isLoadingMorePrivate = true;
    });

    _privateOffset += _limit;

    await _loadData(isRefresh: false);

    setState(() {
      _isLoadingMorePrivate = false;
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = value;
        _loadData(isRefresh: true);
      });
    });
  }

  Future<void> _handleAddPrompt(PrivatePrompt prompt) async {
    final promptProvider = context.read<PromptProvider>();
    await promptProvider.createPrompt(prompt);
  }

  Future<void> _handleEditPrompt(PrivatePrompt updatedPrompt) async {
    final promptProvider = context.read<PromptProvider>();
    await promptProvider.updatePrompt(updatedPrompt);
  }

  Future<void> _handleDeletePrompt(String id) async {
    final promptProvider = context.read<PromptProvider>();
    final prompt = _selectedTab == 0
        ? promptProvider.privatePrompts.firstWhere((p) => p.id == id)
        : promptProvider.publicPrompts.firstWhere((p) => p.id == id);
    await promptProvider.deletePrompt(prompt);
  }

  Future<void> _handleToggleFavorite(String id, bool isFavorite) async {
    final promptProvider = context.read<PromptProvider>();
    final prompt = _selectedTab == 0
        ? promptProvider.privatePrompts.firstWhere((p) => p.id == id)
        : promptProvider.publicPrompts.firstWhere((p) => p.id == id);
    await promptProvider.toggleFavorite(prompt);
  }

  @override
  Widget build(BuildContext context) {
    final promptProvider = context.watch<PromptProvider>();

    final filteredPrivatePrompts = _getFilteredPrivatePrompts(promptProvider.privatePrompts);
    final publicPrompts = promptProvider.publicPrompts;
    final privatePrompts = promptProvider.privatePrompts;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(child: _buildTabButton('Private', 0)),
                  const SizedBox(width: 4),
                  Expanded(child: _buildTabButton('Public', 1)),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider.withOpacity(0.5), width: 1),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged, // Dùng hàm debounce
                      decoration: InputDecoration(
                        hintText: 'Search prompts...',
                        hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 22),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: _showFavoritesOnly ? Colors.amber.withOpacity(0.1) : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _showFavoritesOnly ? Colors.amber : AppColors.divider.withOpacity(0.5), width: 1),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _showFavoritesOnly = !_showFavoritesOnly;
                        _loadData(isRefresh: true); // Reload từ server
                      });
                    },
                    icon: Icon(
                      _showFavoritesOnly ? Icons.star : Icons.star_border,
                      color: _showFavoritesOnly ? Colors.amber : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                            _selectedCategory = category.toLowerCase();
                            _loadData(isRefresh: true);
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                            color: _selectedCategory == category ? Colors.white : AppColors.textPrimary,
                            fontSize: 13),
                        shape: const StadiumBorder(side: BorderSide.none),
                        showCheckmark: false,
                      ))
                          .toList(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showAllCategories = !_showAllCategories),
                    icon: Icon(_showAllCategories ? Icons.arrow_drop_up : Icons.arrow_drop_down),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // List Data
          Expanded(
            child: (promptProvider.isLoading && _selectedTab == 0 && _privateOffset == 0) ||
                (promptProvider.isLoading && _selectedTab == 1 && _publicOffset == 0)
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                ? PrivatePromptList(
              prompts: privatePrompts,
              onDelete: _handleDeletePrompt,
              onEdit: _handleEditPrompt,
              onToggleFavorite: _handleToggleFavorite,
              onLoadMore: _handleLoadMorePrivate,
              hasMore: _hasMorePrivate,
              isLoadingMore: _isLoadingMorePrivate,
            )
                : PublicPromptList(
              prompts: publicPrompts,
              onToggleFavorite: _handleToggleFavorite,
              onLoadMore: _handleLoadMorePublic,
              hasMore: _hasMorePublic,
              isLoadingMore: _isLoadingMorePublic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prompt Library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Choose or create your prompts', style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showDialog(context: context, builder: (c) => AddPromptDialog(onAdd: _handleAddPrompt)),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.add, color: AppColors.primary, size: 20),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PrivatePrompt> _getFilteredPrivatePrompts(List<PrivatePrompt> prompts) {
    return prompts.where((prompt) {
      if (_searchQuery.isNotEmpty) {
        if (!prompt.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !prompt.content.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }
      if (_showFavoritesOnly && !prompt.isFavorite) return false;
      return true;
    }).toList();
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
          _loadData(isRefresh: true);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) Icon(index == 0 ? Icons.lock_outline : Icons.public, color: AppColors.primary, size: 18),
              if (isSelected) const SizedBox(width: 6),
              Text(label, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
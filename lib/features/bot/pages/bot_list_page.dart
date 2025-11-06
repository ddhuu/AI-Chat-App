import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../shared/widgets/AppDrawer.dart';
import '../models/bot_model.dart';
import '../widgets/bot_card.dart';
import '../widgets/bot_dashboard.dart';
import '../widgets/create_bot_dialog.dart';
import 'chat_with_bot_page.dart';

class BotListPage extends StatefulWidget {
  const BotListPage({super.key});

  @override
  State<BotListPage> createState() => _BotListPageState();
}

class _BotListPageState extends State<BotListPage> {
  List<BotModel> _allBots = [];
  List<BotModel> _filteredBots = [];
  String _currentFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBots();
  }

  void _loadBots() {
    setState(() {
      _allBots = BotModel.getMockBots();
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredBots = _allBots.where((bot) {
        // Apply filter
        bool matchesFilter = true;
        if (_currentFilter == 'favorite') {
          matchesFilter = bot.isFavorite;
        }

        // Apply search
        bool matchesSearch = true;
        if (_searchQuery.isNotEmpty) {
          matchesSearch = bot.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              bot.description.toLowerCase().contains(_searchQuery.toLowerCase());
        }

        return matchesFilter && matchesSearch;
      }).toList();
    });
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _currentFilter = filter;
      _applyFilters();
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _showCreateBotDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateBotDialog(
        onConfirm: (name, description, knowledgeIds) {
          // Mock: Add new bot
          final newBot = BotModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name,
            description: description,
            createdDate: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            knowledgeList: knowledgeIds,
          );
          
          setState(() {
            _allBots.insert(0, newBot);
            _applyFilters();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.botCreated),
              backgroundColor: AppColors.success,
            ),
          );
        },
      ),
    );
  }

  void _handleToggleFavorite(BotModel bot) {
    setState(() {
      bot.isFavorite = !bot.isFavorite;
      _applyFilters();
    });
  }

  void _handleTogglePublish(BotModel bot) {
    setState(() {
      bot.isPublished = !bot.isPublished;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          bot.isPublished ? AppStrings.published : AppStrings.draft,
        ),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _handleDeleteBot(BotModel bot) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: const Text(AppStrings.confirmDeleteBot),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allBots.remove(bot);
                _applyFilters();
              });
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.botDeleted),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.deleteBot),
          ),
        ],
      ),
    );
  }

  void _handleBotTap(BotModel bot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatWithBotPage(bot: bot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.myBots,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Token counter (placeholder)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.bolt, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text(
                  '1,000',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: const SafeArea(child: AppDrawer()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dashboard (Search & Filter)
            BotDashboard(
              onFilterChanged: _handleFilterChanged,
              onSearch: _handleSearch,
              onCreateBot: _showCreateBotDialog,
            ),
            const SizedBox(height: 20),

            // Bot List
            Expanded(
              child: _filteredBots.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filteredBots.length,
                      itemBuilder: (context, index) {
                        final bot = _filteredBots[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: BotCard(
                            bot: bot,
                            onTap: () => _handleBotTap(bot),
                            onFavorite: () => _handleToggleFavorite(bot),
                            onPublish: () => _handleTogglePublish(bot),
                            onDelete: () => _handleDeleteBot(bot),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            AppStrings.noBots,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.createFirstBot,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateBotDialog,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createNewBot),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

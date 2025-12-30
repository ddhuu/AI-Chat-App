import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../shared/widgets/AppDrawer.dart';
import '../../../shared/providers/token_usage_provider.dart';
import '../models/assistant_model.dart';
import '../providers/assistant_provider.dart';
import '../widgets/bot_card.dart';
import '../widgets/bot_dashboard.dart';
import '../widgets/create_assistant_dialog.dart';
import '../widgets/edit_assistant_dialog.dart';
import '../../chat/chat_page.dart';

class AssistantListPage extends StatefulWidget {
  const AssistantListPage({super.key});

  @override
  State<AssistantListPage> createState() => _AssistantListPageState();
}

class _AssistantListPageState extends State<AssistantListPage> {
  final _scrollController = ScrollController();
  String _currentFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load assistants on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssistantProvider>().loadAssistants();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<AssistantProvider>();
      if (provider.hasNext && !provider.isLoading) {
        provider.loadAssistants(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
          isFavorite: _currentFilter == 'favorite' ? true : null,
          isLoadMore: true,
        );
      }
    }
  }

  void _handleFilterChanged(String filter) {
    setState(() {
      _currentFilter = filter;
    });

    context.read<AssistantProvider>().loadAssistants(
      query: _searchQuery.isNotEmpty ? _searchQuery : null,
      isFavorite: filter == 'favorite' ? true : null,
    );
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == query && mounted) {
        context.read<AssistantProvider>().loadAssistants(
          query: query.isNotEmpty ? query : null,
          isFavorite: _currentFilter == 'favorite' ? true : null,
        );
      }
    });
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const CreateAssistantDialog(),
    );

    if (result != null && mounted) {
      final provider = context.read<AssistantProvider>();
      final success = await provider.createAssistant(
        assistantName: result['name'] as String,
        description: result['description'] as String?,
        instructions: result['instructions'] as String?,
        model: result['model'] as String?,
        datasources: result['datasources'] as List<String>?,
      );

      if (success && mounted) {
        _showSuccessSnackBar(AppStrings.botCreated);
      } else if (mounted) {
        _showErrorSnackBar(
          provider.errorMessage ?? 'Failed to create assistant',
        );
      }
    }
  }

  Future<void> _showEditDialog(Assistant assistant) async {
    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (context) => EditAssistantDialog(assistant: assistant),
    );

    if (result != null && mounted) {
      final provider = context.read<AssistantProvider>();
      final success = await provider.updateAssistant(
        id: assistant.id,
        assistantName: result['name'],
        description: result['description'],
        instructions: result['instructions'],
      );

      if (success && mounted) {
        _showSuccessSnackBar('Assistant updated successfully');
      } else if (mounted) {
        _showErrorSnackBar(
          provider.errorMessage ?? 'Failed to update assistant',
        );
      }
    }
  }

  Future<void> _handleToggleFavorite(Assistant assistant) async {
    final provider = context.read<AssistantProvider>();
    await provider.toggleFavorite(assistant.id);
  }

  Future<void> _handleDeleteBot(Assistant assistant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDelete),
        content: Text(
          'Are you sure you want to delete "${assistant.assistantName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(AppStrings.deleteBot),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final provider = context.read<AssistantProvider>();
      final success = await provider.deleteAssistant(assistant.id);

      if (success && mounted) {
        _showSuccessSnackBar(AppStrings.botDeleted);
      } else if (mounted) {
        _showErrorSnackBar(
          provider.errorMessage ?? 'Failed to delete assistant',
        );
      }
    }
  }

  void _handleBotTap(Assistant assistant) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChatPage(initialBot: assistant)),
      (route) => false,
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokenUsageProvider = context.watch<TokenUsageProvider>();
    final assistantProvider = context.watch<AssistantProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.myBots,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Token counter
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  tokenUsageProvider.tokenUsage.toString(),
                  style: const TextStyle(
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
      body: RefreshIndicator(
        onRefresh: () => assistantProvider.refresh(
          query: _searchQuery.isNotEmpty ? _searchQuery : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Dashboard (Search & Filter)
              BotDashboard(
                onFilterChanged: _handleFilterChanged,
                onSearch: _handleSearch,
                onCreateBot: _showCreateDialog,
              ),
              const SizedBox(height: 20),

              // Bot List
              Expanded(
                child:
                    assistantProvider.isLoading &&
                        assistantProvider.assistants.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : assistantProvider.assistants.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            assistantProvider.assistants.length +
                            (assistantProvider.hasNext ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= assistantProvider.assistants.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final assistant = assistantProvider.assistants[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: BotCard(
                              assistant: assistant,
                              onTap: () => _handleBotTap(assistant),
                              onEdit: () => _showEditDialog(assistant),
                              onFavorite: () =>
                                  _handleToggleFavorite(assistant),
                              onDelete: () => _handleDeleteBot(assistant),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.smart_toy_outlined, size: 80, color: AppColors.textHint),
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
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.createBot),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

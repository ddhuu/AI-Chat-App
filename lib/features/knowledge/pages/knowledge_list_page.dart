import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/AppDrawer.dart';
import '../../../data/services/api_service.dart';
import '../models/knowledge_model.dart';
import '../providers/knowledge_provider.dart';
import '../widgets/knowledge_item.dart';
import '../widgets/knowledge_item_card.dart';
import '../widgets/create_knowledge_dialog_new.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'knowledge_detail_page.dart';

class KnowledgeListPage extends StatefulWidget {
  const KnowledgeListPage({super.key});

  @override
  State<KnowledgeListPage> createState() => _KnowledgeListPageState();
}

class _KnowledgeListPageState extends State<KnowledgeListPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);

    // Load knowledges on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KnowledgeProvider>().loadKnowledges();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == _searchQuery) return;
      setState(() {
        _searchQuery = _searchController.text;
      });
      context.read<KnowledgeProvider>().loadKnowledges(query: _searchQuery);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<KnowledgeProvider>();
      if (provider.hasNext && !provider.isLoading) {
        provider.loadKnowledges(isLoadMore: true, query: _searchQuery);
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const CreateKnowledgeDialog(),
    );

    if (result != null && mounted) {
      final provider = context.read<KnowledgeProvider>();
      final success = await provider.createKnowledge(
        knowledgeName: result['name']!,
        description: result['description']!,
      );

      if (success && mounted) {
        _showSuccessToast('Knowledge base created successfully');
      } else if (mounted) {
        _showErrorToast(provider.errorMessage ?? 'Failed to create knowledge');
      }
    }
  }

  Future<void> _showEditDialog(Knowledge knowledge) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => CreateKnowledgeDialog(
        initialName: knowledge.knowledgeName,
        initialDescription: knowledge.description,
      ),
    );

    if (result != null && mounted) {
      final provider = context.read<KnowledgeProvider>();
      final success = await provider.updateKnowledge(
        id: knowledge.id,
        knowledgeName: result['name']!,
        description: result['description']!,
      );

      if (success && mounted) {
        _showSuccessToast('Knowledge base updated successfully');
      } else if (mounted) {
        _showErrorToast(provider.errorMessage ?? 'Failed to update knowledge');
      }
    }
  }

  Future<void> _showDeleteDialog(Knowledge knowledge) async {
    final bool didConfirm =
        await showDialog(
          context: context,
          builder: (context) =>
              DeleteConfirmationDialog(knowledgeName: knowledge.knowledgeName),
        ) ??
        false;

    if (didConfirm && mounted) {
      final provider = context.read<KnowledgeProvider>();
      final success = await provider.deleteKnowledge(knowledge.id);

      if (success && mounted) {
        _showSuccessToast('Knowledge base deleted successfully');
      } else if (mounted) {
        _showErrorToast(provider.errorMessage ?? 'Failed to delete knowledge');
      }
    }
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F7F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 100,
          left: 20,
          right: 20,
        ),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red),
          ),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Knowledge Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
        //     onPressed: () {
        //       context.read<KnowledgeProvider>().refresh(query: _searchQuery);
        //     },
        //   ),
        // ],
      ),
      drawer: const SafeArea(child: AppDrawer()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildMasterPanel(context, isMobile),
    );
  }

  Widget _buildMasterPanel(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 32,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search knowledge base...',
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Knowledge list
          Expanded(
            child: Consumer<KnowledgeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.knowledges.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.knowledges.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount:
                      provider.knowledges.length + (provider.hasNext ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Loading indicator at bottom
                    if (index == provider.knowledges.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final knowledge = provider.knowledges[index];
                    final item = KnowledgeItem(
                      id: knowledge.id,
                      title: knowledge.knowledgeName,
                      description: knowledge.description,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: KnowledgeItemCard(
                        item: item,
                        onTap: () {
                          // Navigate to detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KnowledgeDetailPage(
                                knowledge: knowledge,
                                apiService: context.read<ApiService>(),
                              ),
                            ),
                          );
                        },
                        onEdit: () => _showEditDialog(knowledge),
                        onDelete: () => _showDeleteDialog(knowledge),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textHint),
            const SizedBox(height: 24),
            const Text(
              'No knowledge found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppColors.textHint),
          const SizedBox(height: 24),
          const Text(
            'No knowledge bases yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _showCreateDialog,
            child: const Text(
              'Create your first knowledge base',
              style: TextStyle(color: AppColors.primary, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

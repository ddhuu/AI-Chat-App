import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/api_service.dart';
import '../../knowledge/models/knowledge_model.dart';
import '../../knowledge/providers/knowledge_provider.dart';
import '../providers/assistant_provider.dart';
import '../models/assistant_model.dart';
import 'add_knowledge_dialog.dart';
import '../../knowledge/pages/knowledge_detail_page.dart';

class KnowledgeBaseSection extends StatefulWidget {
  final Assistant assistant;

  const KnowledgeBaseSection({super.key, required this.assistant});

  @override
  State<KnowledgeBaseSection> createState() => _KnowledgeBaseSectionState();
}

class _KnowledgeBaseSectionState extends State<KnowledgeBaseSection> {
  List<Knowledge> _knowledges = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadKnowledges();
  }

  Future<void> _loadKnowledges() async {
    setState(() => _isLoading = true);

    try {
      print(
        '📚 [KnowledgeBaseSection] Loading knowledges for assistant: ${widget.assistant.id}',
      );

      final provider = context.read<AssistantProvider>();
      final result = await provider.getAssistantKnowledges(widget.assistant.id);

      print('📚 [KnowledgeBaseSection] Loaded ${result.length} knowledges');

      setState(() {
        _knowledges = result.map((item) => Knowledge.fromJson(item)).toList();
      });
    } catch (e) {
      print('❌ [KnowledgeBaseSection] Error loading knowledges: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load knowledge bases: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddKnowledgeDialog() async {
    final apiService = context.read<ApiService>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => KnowledgeProvider(apiService),
        child: AddKnowledgeDialog(
          assistantId: widget.assistant.id,
          existingKnowledgeIds: _knowledges.map((k) => k.id).toList(),
        ),
      ),
    );

    if (result == true) {
      _loadKnowledges();
    }
  }

  Future<void> _removeKnowledge(Knowledge knowledge) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Knowledge Base'),
        content: Text(
          'Are you sure you want to remove "${knowledge.knowledgeName}" from this assistant?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      print('🗑️ [KnowledgeBaseSection] Removing knowledge: ${knowledge.id}');

      final provider = context.read<AssistantProvider>();
      final success = await provider.removeKnowledge(
        assistantId: widget.assistant.id,
        knowledgeId: knowledge.id,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Knowledge base removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadKnowledges();
        }
      } else {
        throw Exception('Failed to remove knowledge');
      }
    } catch (e) {
      print('❌ [KnowledgeBaseSection] Error removing knowledge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove knowledge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToKnowledgeDetail(Knowledge knowledge) {
    print(
      '📖 [KnowledgeBaseSection] Navigating to knowledge detail: ${knowledge.id}',
    );

    final apiService = context.read<ApiService>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            KnowledgeDetailPage(knowledge: knowledge, apiService: apiService),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.library_books_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Knowledge Base',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Choose a knowledge base below to add knowledge units.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),

          const SizedBox(height: 16),

          // Knowledge List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_knowledges.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: Text(
                  'No knowledge bases added yet',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _knowledges.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final knowledge = _knowledges[index];
                return _buildKnowledgeItem(knowledge);
              },
            ),

          // Add Knowledge Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: _showAddKnowledgeDialog,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Add knowledge source',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeItem(Knowledge knowledge) {
    return InkWell(
      onTap: () => _navigateToKnowledgeDetail(knowledge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    knowledge.knowledgeName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (knowledge.description != null &&
                      knowledge.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      knowledge.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  onPressed: () => _removeKnowledge(knowledge),
                  tooltip: 'Remove',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

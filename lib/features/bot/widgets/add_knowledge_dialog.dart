import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../knowledge/models/knowledge_model.dart';
import '../../knowledge/providers/knowledge_provider.dart';
import '../providers/assistant_provider.dart';

class AddKnowledgeDialog extends StatefulWidget {
  final String assistantId;
  final List<String> existingKnowledgeIds;

  const AddKnowledgeDialog({
    super.key,
    required this.assistantId,
    required this.existingKnowledgeIds,
  });

  @override
  State<AddKnowledgeDialog> createState() => _AddKnowledgeDialogState();
}

class _AddKnowledgeDialogState extends State<AddKnowledgeDialog> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKnowledges();
    });
  }

  Future<void> _loadKnowledges() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<KnowledgeProvider>();
      await provider.loadKnowledges();
    } catch (e) {
      print('❌ [AddKnowledgeDialog] Error loading knowledges: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _importKnowledge(Knowledge knowledge) async {
    try {
      print('📚 [AddKnowledgeDialog] Importing knowledge: ${knowledge.id}');

      final provider = context.read<AssistantProvider>();
      final success = await provider.importKnowledge(
        assistantId: widget.assistantId,
        knowledgeId: knowledge.id,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Knowledge imported successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to import knowledge');
      }
    } catch (e) {
      print('❌ [AddKnowledgeDialog] Error importing knowledge: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import knowledge: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : _buildKnowledgeList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Knowledge',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeList() {
    return Consumer<KnowledgeProvider>(
      builder: (context, provider, child) {
        if (provider.knowledges.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No knowledge available',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: provider.knowledges.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            final knowledge = provider.knowledges[index];
            final isAdded = widget.existingKnowledgeIds.contains(knowledge.id);
            return _buildKnowledgeItem(knowledge, isAdded);
          },
        );
      },
    );
  }

  Widget _buildKnowledgeItem(Knowledge knowledge, bool isAdded) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.description_outlined,
            color: AppColors.primary,
            size: 24,
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
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                if (knowledge.description != null &&
                    knowledge.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    knowledge.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: isAdded ? null : () => _importKnowledge(knowledge),
            style: TextButton.styleFrom(
              backgroundColor: isAdded
                  ? Colors.grey.shade100
                  : Colors.blue.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              minimumSize: const Size(0, 32),
              disabledBackgroundColor: Colors.grey.shade100,
            ),
            child: Text(
              isAdded ? 'Added' : 'Import',
              style: TextStyle(
                fontSize: 12,
                color: isAdded ? Colors.grey.shade500 : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

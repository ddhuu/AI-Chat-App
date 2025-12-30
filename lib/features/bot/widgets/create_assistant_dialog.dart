import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/api_service.dart';
import '../../knowledge/models/knowledge_model.dart';
import '../../knowledge/providers/knowledge_provider.dart';

class CreateAssistantDialog extends StatefulWidget {
  const CreateAssistantDialog({super.key});

  @override
  State<CreateAssistantDialog> createState() => _CreateAssistantDialogState();
}

class _CreateAssistantDialogState extends State<CreateAssistantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedModel = 'gpt-4o-mini';
  final List<String> _availableModels = [
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-4-turbo',
    'gpt-3.5-turbo',
  ];

  List<Knowledge> _selectedKnowledges = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _showAddKnowledgeDialog() async {
    final apiService = context.read<ApiService>();

    final result = await showDialog<Knowledge>(
      context: context,
      builder: (context) => ChangeNotifierProvider(
        create: (_) => KnowledgeProvider(apiService),
        child: _SelectKnowledgeDialog(
          existingKnowledgeIds: _selectedKnowledges.map((k) => k.id).toList(),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedKnowledges.add(result);
      });
    }
  }

  void _removeKnowledge(Knowledge knowledge) {
    setState(() {
      _selectedKnowledges.removeWhere((k) => k.id == knowledge.id);
    });
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      final result = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'instructions': _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
        'model': _selectedModel,
        'datasources': _selectedKnowledges.map((k) => k.id).toList(),
      };
      Navigator.pop(context, result);
    }
  }

  Widget _buildKnowledgeBaseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Knowledge base (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enhance your bot\'s intelligence by adding relevant knowledge sources.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 12),

        // Selected Knowledges List
        if (_selectedKnowledges.isNotEmpty) ...[
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedKnowledges.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final knowledge = _selectedKnowledges[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        knowledge.knowledgeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      onPressed: () => _removeKnowledge(knowledge),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],

        // Add Knowledge Button
        InkWell(
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
      ],
    );
  }

  Widget _buildModelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Model',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedModel,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.psychology_outlined),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: _availableModels.map((model) {
            return DropdownMenuItem(
              value: model,
              child: Text(model, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedModel = value;
              });
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.smart_toy,
                      color: AppColors.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Create AI Assistant',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Assistant Name *',
                    hintText: 'e.g., Code Helper, Email Writer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter assistant name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Brief description of what this assistant does',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description_outlined),
                  ),
                  maxLines: 2,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Instructions field
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    labelText: 'Instructions (Optional)',
                    hintText: 'System instructions for the AI assistant...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.settings_outlined),
                    helperText: 'Define how the assistant should behave',
                  ),
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // Knowledge Base Section
                _buildKnowledgeBaseSection(),
                const SizedBox(height: 24),

                // Model Selector
                _buildModelSelector(),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _handleCreate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Create Assistant'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Select Knowledge Dialog for Create Bot
class _SelectKnowledgeDialog extends StatefulWidget {
  final List<String> existingKnowledgeIds;

  const _SelectKnowledgeDialog({required this.existingKnowledgeIds});

  @override
  State<_SelectKnowledgeDialog> createState() => _SelectKnowledgeDialogState();
}

class _SelectKnowledgeDialogState extends State<_SelectKnowledgeDialog> {
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
      print('❌ [SelectKnowledgeDialog] Error loading knowledges: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectKnowledge(Knowledge knowledge) {
    Navigator.pop(context, knowledge);
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
    return InkWell(
      onTap: isAdded ? null : () => _selectKnowledge(knowledge),
      child: Container(
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
            if (isAdded)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Added',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              )
            else
              const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

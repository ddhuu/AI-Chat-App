import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constants/colors.dart';
import '../../../data/services/api_service.dart';
import '../models/assistant_model.dart';
import '../services/assistant_service.dart';
import '../../knowledge/models/knowledge_model.dart';
import '../../knowledge/providers/knowledge_provider.dart';

class EditBotPage extends StatefulWidget {
  final Assistant assistant;

  const EditBotPage({super.key, required this.assistant});

  @override
  State<EditBotPage> createState() => _EditBotPageState();
}

class _EditBotPageState extends State<EditBotPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructionsController;

  List<Knowledge> _selectedKnowledges = [];
  bool _isLoadingKnowledges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.assistant.assistantName,
    );
    _descriptionController = TextEditingController(
      text: widget.assistant.description ?? '',
    );
    _instructionsController = TextEditingController(
      text: widget.assistant.instructions ?? '',
    );
    _loadAssistantKnowledges();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _loadAssistantKnowledges() async {
    setState(() => _isLoadingKnowledges = true);

    try {
      final apiService = context.read<ApiService>();
      final assistantService = AssistantService(apiService);
      final knowledgesData = await assistantService.getAssistantKnowledges(
        assistantId: widget.assistant.id,
      );

      if (mounted) {
        setState(() {
          _selectedKnowledges = knowledgesData
              .map((json) => Knowledge.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoadingKnowledges = false;
        });
      }
    } catch (e) {
      print('Error loading knowledges: $e');
      if (mounted) {
        setState(() => _isLoadingKnowledges = false);
      }
    }
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
      await _addKnowledgeToAssistant(result);
    }
  }

  Future<void> _addKnowledgeToAssistant(Knowledge knowledge) async {
    try {
      final apiService = context.read<ApiService>();
      final assistantService = AssistantService(apiService);

      final success = await assistantService.importKnowledgeToAssistant(
        assistantId: widget.assistant.id,
        knowledgeId: knowledge.id,
      );

      if (success && mounted) {
        setState(() {
          _selectedKnowledges.add(knowledge);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Knowledge added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add knowledge: $e')));
      }
    }
  }

  Future<void> _removeKnowledge(Knowledge knowledge) async {
    try {
      final apiService = context.read<ApiService>();
      final assistantService = AssistantService(apiService);

      final success = await assistantService.removeKnowledgeFromAssistant(
        assistantId: widget.assistant.id,
        knowledgeId: knowledge.id,
      );

      if (success && mounted) {
        setState(() {
          _selectedKnowledges.removeWhere((k) => k.id == knowledge.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Knowledge removed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove knowledge: $e')),
        );
      }
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final result = <String, String?>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'instructions': _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
      };
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'bot.edit_bot'.tr(),
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Avatar Section
              _buildAvatarSection(),
              const SizedBox(height: 24),

              // Name Section
              _buildNameSection(),
              const SizedBox(height: 16),

              // Bot Settings Section
              _buildBotSettingsSection(),
              const SizedBox(height: 16),

              // Model Display (read-only for edit)
              _buildModelDisplay(),
              const SizedBox(height: 16),

              // Bot Description Section
              _buildDescriptionSection(),
              const SizedBox(height: 16),

              // Knowledge Base Section
              _buildKnowledgeSection(),
              const SizedBox(height: 24),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.smart_toy, size: 50, color: Colors.grey.shade400),
        ),
        Positioned(
          bottom: 0,
          right: 130,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Bot name',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter bot name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBotSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bot settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _instructionsController,
            decoration: InputDecoration(
              hintText:
                  'Example: You are an experienced science fiction writer. You excel at creating unique futuristic worlds and engaging storylines.',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
                height: 1.5,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildModelDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const Icon(Icons.psychology_outlined, color: Colors.black87),
        title: const Text(
          'Model',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        trailing: Text(
          widget.assistant.model ?? 'gpt-4o-mini',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bot description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Example: I\'m an experienced science fiction writer.',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Knowledge base',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enhance your bot\'s intelligence by adding relevant knowledge sources.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Loading State
          if (_isLoadingKnowledges)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            // Selected Knowledges
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
                  border: Border.all(color: AppColors.primary, width: 1.5),
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
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: Text(
            'common.save'.tr(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// Select Knowledge Dialog (reused)
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../bot/models/assistant_model.dart';
import '../../bot/providers/assistant_provider.dart';

class EnhancedAiModelSelector extends StatefulWidget {
  final String? selectedModelId;
  final bool isBot;
  final Function(String modelId, bool isBot) onModelChanged;

  const EnhancedAiModelSelector({
    super.key,
    required this.selectedModelId,
    required this.isBot,
    required this.onModelChanged,
  });

  @override
  State<EnhancedAiModelSelector> createState() =>
      _EnhancedAiModelSelectorState();
}

class _EnhancedAiModelSelectorState extends State<EnhancedAiModelSelector> {
  final List<Map<String, dynamic>> baseAiModels = [
    {
      'id': 'gpt-4o-mini',
      'name': 'GPT-4o mini',
      'icon': Icons.psychology,
      'token': 1,
    },
    {
      'id': 'gpt-4o',
      'name': 'GPT-4o',
      'icon': Icons.psychology_alt,
      'token': 5,
    },
    {
      'id': 'gemini-1.5-flash',
      'name': 'Gemini 1.5 Flash',
      'icon': Icons.auto_awesome,
      'token': 1,
    },
    {
      'id': 'gemini-1.5-pro',
      'name': 'Gemini 1.5 Pro',
      'icon': Icons.stars,
      'token': 2,
    },
    {
      'id': 'gemini-2.0-flash',
      'name': 'Gemini 2.0 Flash',
      'icon': Icons.flash_on,
      'token': 1,
    },
    {
      'id': 'claude-3-haiku',
      'name': 'Claude 3 Haiku',
      'icon': Icons.smart_toy,
      'token': 3,
    },
    {
      'id': 'claude-3.5-sonnet',
      'name': 'Claude 3.5 Sonnet',
      'icon': Icons.psychology_outlined,
      'token': 4,
    },
    {
      'id': 'deepseek-chat',
      'name': 'Deepseek Chat',
      'icon': Icons.chat_bubble_outline,
      'token': 2,
    },
    {
      'id': 'qwen2.5-coder-32b',
      'name': 'Qwen2.5-Coder-32B-Instruct',
      'icon': Icons.code,
      'token': 2,
    },
    {
      'id': 'qwen3-32b',
      'name': 'Qwen3-32B',
      'icon': Icons.code_outlined,
      'token': 2,
    },
    {
      'id': 'saola3.1-medium',
      'name': 'SaoLa3.1-medium',
      'icon': Icons.language,
      'token': 1,
    },
    {
      'id': 'saola-llama3.1-planner',
      'name': 'SaoLa-Llama3.1-planner',
      'icon': Icons.schedule,
      'token': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: _showModelSelector,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getCurrentIcon(), size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  _getCurrentName(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCurrentIcon() {
    if (widget.isBot) {
      return Icons.smart_toy;
    }
    final model = baseAiModels.firstWhere(
      (m) => m['id'] == widget.selectedModelId,
      orElse: () => baseAiModels[0],
    );
    return model['icon'] as IconData;
  }

  String _getCurrentName() {
    if (widget.isBot) {
      final provider = context.watch<AssistantProvider>();
      final bot = provider.assistants.firstWhere(
        (a) => a.id == widget.selectedModelId,
        orElse: () => Assistant(
          id: '',
          assistantName: 'Bot',
          userId: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return bot.assistantName;
    }
    final model = baseAiModels.firstWhere(
      (m) => m['id'] == widget.selectedModelId,
      orElse: () => baseAiModels[0],
    );
    return model['name'] as String;
  }

  void _showModelSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ModelSelectorSheet(
        baseModels: baseAiModels,
        selectedModelId: widget.selectedModelId,
        isBot: widget.isBot,
        onModelSelected: (modelId, isBot) {
          widget.onModelChanged(modelId, isBot);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _ModelSelectorSheet extends StatefulWidget {
  final List<Map<String, dynamic>> baseModels;
  final String? selectedModelId;
  final bool isBot;
  final Function(String modelId, bool isBot) onModelSelected;

  const _ModelSelectorSheet({
    required this.baseModels,
    required this.selectedModelId,
    required this.isBot,
    required this.onModelSelected,
  });

  @override
  State<_ModelSelectorSheet> createState() => _ModelSelectorSheetState();
}

class _ModelSelectorSheetState extends State<_ModelSelectorSheet> {
  @override
  void initState() {
    super.initState();
    // Load bots when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssistantProvider>().loadAssistants();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Base AI Models Section
                _buildSectionHeader('Base AI Models'),
                const SizedBox(height: 8),
                ...widget.baseModels.map(
                  (model) => _buildModelItem(
                    id: model['id'] as String,
                    name: model['name'] as String,
                    icon: model['icon'] as IconData,
                    token: model['token'] as int,
                    isBot: false,
                    isSelected:
                        !widget.isBot && widget.selectedModelId == model['id'],
                  ),
                ),

                const SizedBox(height: 24),

                // Your Bots Section
                _buildSectionHeader('Your Bots'),
                const SizedBox(height: 8),
                Consumer<AssistantProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading && provider.assistants.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (provider.assistants.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No bots yet. Create one from the Bot page!',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    return Column(
                      children: provider.assistants.map((bot) {
                        return _buildModelItem(
                          id: bot.id,
                          name: bot.assistantName,
                          icon: Icons.smart_toy,
                          token: 0,
                          isBot: true,
                          isSelected:
                              widget.isBot && widget.selectedModelId == bot.id,
                          subtitle: bot.description,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModelItem({
    required String id,
    required String name,
    required IconData icon,
    required int token,
    required bool isBot,
    required bool isSelected,
    String? subtitle,
  }) {
    return InkWell(
      onTap: () => widget.onModelSelected(id, isBot),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
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
            if (!isBot && token > 0) ...[
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    token.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                ],
              ),
            ],
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AiModelSelector extends StatefulWidget {
  final String selectedModel;
  final Function(String) onModelChanged;

  const AiModelSelector({
    super.key,
    required this.selectedModel,
    required this.onModelChanged,
  });

  @override
  State<AiModelSelector> createState() => _AiModelSelectorState();
}

class _AiModelSelectorState extends State<AiModelSelector> {
  final List<Map<String, dynamic>> aiModels = [
    {'name': 'GPT-4o mini', 'token': 1, 'icon': Icons.psychology},
    {'name': 'GPT-4o', 'token': 5, 'icon': Icons.psychology_alt},
    {'name': 'Gemini 1.5 Flash', 'token': 1, 'icon': Icons.auto_awesome},
    {'name': 'Gemini 1.5 Pro', 'token': 2, 'icon': Icons.stars},
    {'name': 'Claude 3 Haiku', 'token': 3, 'icon': Icons.smart_toy},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      child: DropdownButton<String>(
        items: aiModels.map((model) {
          return DropdownMenuItem<String>(
            value: model['name'],
            child: _buildDropdownItem(model),
          );
        }).toList(),
        onChanged: (String? value) {
          if (value != null) {
            widget.onModelChanged(value);
          }
        },
        value: widget.selectedModel,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.keyboard_arrow_down),
        iconSize: 20,
        padding: const EdgeInsets.all(0),
        borderRadius: BorderRadius.circular(16),
        selectedItemBuilder: (BuildContext context) {
          return aiModels.map((model) {
            return _buildSelectedItem(model);
          }).toList();
        },
      ),
    );
  }

  Widget _buildDropdownItem(Map<String, dynamic> model) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(model['icon'], size: 20, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(model['name']),
          ],
        ),
        Row(
          children: [
            Text(model['token'].toString()),
            const SizedBox(width: 2),
            const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 20,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectedItem(Map<String, dynamic> model) {
    return SizedBox(
      width: 200,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(model['icon'], size: 20, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(model['name'], style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

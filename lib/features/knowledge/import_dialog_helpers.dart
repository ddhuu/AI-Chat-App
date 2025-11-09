// lib/screens/knowledge/widgets/import_dialog_helpers.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';

// Widget cho "Current Limitation"
class LimitationBox extends StatelessWidget {
  final List<String> limitations;
  const LimitationBox({super.key, required this.limitations});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sidebarBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Current Limitation:',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              Icon(Icons.help_outline, size: 16, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 8),
          ...limitations.map((text) => Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                Expanded(child: Text(text, style: TextStyle(color: AppColors.textSecondary))),
              ],
            ),
          )),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(color: AppColors.textSecondary),
              children: [
                TextSpan(text: '• Need more? '),
                TextSpan(
                  text: 'hello@jarvis.cx',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Widget cho "Keep Files Updated Automatically"
class KeepUpdatedSwitch extends StatefulWidget {
  const KeepUpdatedSwitch({super.key});

  @override
  State<KeepUpdatedSwitch> createState() => _KeepUpdatedSwitchState();
}

class _KeepUpdatedSwitchState extends State<KeepUpdatedSwitch> {
  bool _isEnabled = false;
  @override
  Widget build(BuildContext context) {
    // Dùng ListTile để text tự động ngắt dòng, fix lỗi "Right Overflow"
    return ListTile(
      title: Text(
        'Keep Files Updated Automatically', 
        style: TextStyle(fontWeight: FontWeight.w500)
      ),
      trailing: Switch(
        value: _isEnabled,
        onChanged: (val) => setState(() => _isEnabled = val),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
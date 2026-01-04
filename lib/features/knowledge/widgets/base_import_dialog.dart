// lib/screens/knowledge/widgets/base_import_dialog.dart
import 'package:flutter/material.dart';
import '/core/constants/colors.dart';

class BaseImportDialog extends StatelessWidget {
  final String title;
  final Widget child; // Đây là nội dung form
  final VoidCallback onImport;

  const BaseImportDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      
      // SỬA LỖI: Chuyển Tiêu đề vào 'content'
      title: null,
      titlePadding: EdgeInsets.zero, 

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Padding(
              // Thêm padding cho tiêu đề
              padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SỬA LỖI OVERFLOW: Bọc Text trong Expanded
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Thêm khoảng cách
                  IconButton(
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            
            // 'child' (form) sẽ được đặt ở đây
            // Thêm padding ngang cho nội dung
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: child,
            ),
          ],
        ),
      ),
      
      // Nút bấm
      actionsPadding: const EdgeInsets.all(24.0),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: onImport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Import'),
        ),
      ],
    );
  }
}

// --- WIDGET TÁI SỬ DỤNG (Giữ nguyên) ---

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

class KeepUpdatedSwitch extends StatefulWidget {
  const KeepUpdatedSwitch({super.key});

  @override
  State<KeepUpdatedSwitch> createState() => _KeepUpdatedSwitchState();
}

class _KeepUpdatedSwitchState extends State<KeepUpdatedSwitch> {
  bool _isEnabled = false;
  @override
  Widget build(BuildContext context) {
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
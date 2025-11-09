// lib/screens/knowledge/widgets/add_knowledge_unit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/core/constants/assets.dart';
import '/core/constants/colors.dart';

// Import các dialog
// (Các file này bạn chưa tạo, nhưng chúng ta sẽ import trước)
import 'import_web_dialog.dart';
import 'import_slack_dialog.dart';
import 'import_google_drive_dialog.dart';
import 'import_confluence_dialog.dart';
import 'import_local_file_dialog.dart'; // <-- THÊM MỚI

class AddKnowledgeUnitDialog extends StatelessWidget {
  const AddKnowledgeUnitDialog({super.key});

  void _openDialog(BuildContext context, Widget dialog) {
    // Mở dialog mới (nó sẽ nằm trên dialog hiện tại)
    showDialog(
      context: context, 
      builder: (_) => dialog,
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SingleChildScrollView( 
        child: Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Knowledge Sources',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _SourceTile(
                iconAsset: Assets.file,
                iconPlaceholder: Icons.upload_file,
                title: 'Local files',
                subtitle: 'Upload PDFs, docs, and more',
                onTap: () => _openDialog(context, const ImportLocalFileDialog()), // <-- SỬA
              ),
              _SourceTile(
                iconAsset: Assets.website,
                iconPlaceholder: Icons.link,
                title: 'Website',
                subtitle: 'Sync any website content instantly',
                onTap: () => _openDialog(context, const ImportWebDialog()),
              ),
              _SourceTile(
                iconAsset: Assets.googleDrive,
                iconPlaceholder: Icons.cloud_upload_outlined,
                title: 'Google Drive',
                subtitle: 'Access your Drive files seamlessly',
                onTap: () => _openDialog(context, const ImportGoogleDriveDialog()),
              ),
              _SourceTile(
                iconAsset: Assets.slack,
                iconPlaceholder: Icons.chat_bubble_outline,
                title: 'Slack',
                subtitle: 'Connect your team conversations',
                onTap: () => _openDialog(context, const ImportSlackDialog()),
              ),
              _SourceTile(
                iconAsset: Assets.confluence,
                iconPlaceholder: Icons.groups_outlined,
                title: 'Confluence',
                subtitle: 'Import your knowledge base',
                onTap: () => _openDialog(context, const ImportConfluenceDialog()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget con _SourceTile (Giữ nguyên)
class _SourceTile extends StatelessWidget {
  final String iconAsset;
  final IconData iconPlaceholder;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SourceTile({
    required this.iconAsset,
    required this.iconPlaceholder,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Image.asset(
      iconAsset,
      width: 24,
      height: 24,
      errorBuilder: (context, error, stackTrace) => 
        Icon(iconPlaceholder, color: AppColors.primary),
    );

    return ListTile(
      leading: iconWidget,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
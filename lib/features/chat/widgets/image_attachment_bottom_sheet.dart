import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';

class ImageAttachmentBottomSheet extends StatelessWidget {
  final Function(String imageUrl) onImageSelected;

  const ImageAttachmentBottomSheet({super.key, required this.onImageSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'chat.attach_image'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Options
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildOption(
                    context: context,
                    icon: Icons.camera_alt,
                    iconColor: const Color(0xFFEF4444),
                    iconBgColor: const Color(0xFFFEF2F2),
                    title: 'chat.take_photo'.tr(),
                    subtitle: 'chat.take_photo_desc'.tr(),
                    onTap: () => _handleTakePhoto(context),
                  ),
                  _buildOption(
                    context: context,
                    icon: Icons.content_paste,
                    iconColor: const Color(0xFF6366F1),
                    iconBgColor: const Color(0xFFEEF2FF),
                    title: 'chat.paste_image'.tr(),
                    subtitle: 'chat.paste_image_desc'.tr(),
                    onTap: () => _handlePasteImage(context),
                  ),
                  _buildOption(
                    context: context,
                    icon: Icons.upload_file,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBgColor: const Color(0xFFF5F3FF),
                    title: 'chat.upload_image'.tr(),
                    subtitle: 'chat.upload_image_desc'.tr(),
                    onTap: () => _handleUploadImage(context),
                  ),
                  _buildOption(
                    context: context,
                    icon: Icons.link,
                    iconColor: const Color(0xFF06B6D4),
                    iconBgColor: const Color(0xFFECFEFF),
                    title: 'chat.attach_image_link'.tr(),
                    subtitle: 'chat.attach_image_link_desc'.tr(),
                    onTap: () => _handleAttachLink(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        onImageSelected(photo.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'chat.camera_failed'.tr());
    }
  }

  Future<void> _handlePasteImage(BuildContext context) async {
    Navigator.pop(context);

    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
        final text = clipboardData.text!.trim();

        // Check if it's a valid image URL
        if (_isValidImageUrl(text)) {
          onImageSelected(text);
        } else {
          _showErrorSnackBar(context, 'chat.invalid_image_url'.tr());
        }
      } else {
        _showErrorSnackBar(context, 'chat.clipboard_empty'.tr());
      }
    } catch (e) {
      _showErrorSnackBar(context, 'chat.paste_failed'.tr());
    }
  }

  Future<void> _handleUploadImage(BuildContext context) async {
    Navigator.pop(context);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // For now, we'll use the local path
        // In production, you should upload to server and get URL
        onImageSelected(image.path);
      }
    } catch (e) {
      _showErrorSnackBar(context, 'chat.upload_failed'.tr());
    }
  }

  Future<void> _handleAttachLink(BuildContext context) async {
    Navigator.pop(context);

    final urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFECFEFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.link, color: Color(0xFF06B6D4), size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'chat.attach_image_link'.tr(),
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'chat.paste_image_link'.tr(),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: urlController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'chat.image_url_placeholder'.tr(),
                prefixIcon: const Icon(Icons.link, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty && _isValidImageUrl(value.trim())) {
                  onImageSelected(value.trim());
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'common.cancel'.tr(),
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                if (_isValidImageUrl(url)) {
                  onImageSelected(url);
                  Navigator.pop(context);
                } else {
                  _showErrorSnackBar(context, 'chat.invalid_image_url'.tr());
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('chat.attach'.tr()),
          ),
        ],
      ),
    );
  }

  bool _isValidImageUrl(String url) {
    // Basic URL validation
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    // Check for common image extensions
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    final lowerUrl = url.toLowerCase();

    return imageExtensions.any((ext) => lowerUrl.contains(ext)) ||
        lowerUrl.contains('image') ||
        lowerUrl.contains('img');
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class PublishingPlatformDialog extends StatefulWidget {
  final List<String> initialSelectedPlatforms;

  const PublishingPlatformDialog({
    super.key,
    this.initialSelectedPlatforms = const [],
  });

  @override
  State<PublishingPlatformDialog> createState() =>
      _PublishingPlatformDialogState();
}

class _PublishingPlatformDialogState extends State<PublishingPlatformDialog> {
  final List<PlatformItem> _platforms = [
    PlatformItem(
      id: 'slack',
      name: 'Slack',
      icon: '💬',
      color: const Color(0xFF4A154B),
      isConfigured: false,
    ),
    PlatformItem(
      id: 'telegram',
      name: 'Telegram',
      icon: '✈️',
      color: const Color(0xFF0088CC),
      isConfigured: false,
    ),
    PlatformItem(
      id: 'messenger',
      name: 'Messenger',
      icon: '💬',
      color: const Color(0xFF0084FF),
      isConfigured: true,
      isPublished: true,
    ),
    PlatformItem(
      id: 'discord',
      name: 'Discord',
      icon: '🎮',
      color: const Color(0xFF5865F2),
      isConfigured: false,
    ),
    PlatformItem(
      id: 'whatsapp',
      name: 'WhatsApp',
      icon: '📱',
      color: const Color(0xFF25D366),
      isConfigured: false,
    ),
  ];

  late List<String> _selectedPlatforms;

  @override
  void initState() {
    super.initState();
    _selectedPlatforms = List.from(widget.initialSelectedPlatforms);
  }

  void _togglePlatform(String platformId) {
    setState(() {
      if (_selectedPlatforms.contains(platformId)) {
        _selectedPlatforms.remove(platformId);
      } else {
        _selectedPlatforms.add(platformId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Publishing platform',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Platform List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _platforms.length,
                itemBuilder: (context, index) {
                  final platform = _platforms[index];
                  final isSelected = _selectedPlatforms.contains(platform.id);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: platform.isConfigured
                                ? (value) => _togglePlatform(platform.id)
                                : null,
                            activeColor: AppColors.primary,
                          ),
                          title: Row(
                            children: [
                              Text(
                                platform.icon,
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                platform.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          trailing: platform.isPublished
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Published',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Not Configured',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                        ),
                        if (!platform.isConfigured)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Show configure dialog
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Configure ${platform.name}'),
                                        backgroundColor: AppColors.info,
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Configure',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (platform.isPublished)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Row(
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Your App',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.error,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Text(
                                    'Disconnect',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.divider),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _selectedPlatforms.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context, _selectedPlatforms);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          AppColors.textHint.withOpacity(0.3),
                    ),
                    child: const Text(
                      'Publish',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformItem {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final bool isConfigured;
  final bool isPublished;

  PlatformItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isConfigured = false,
    this.isPublished = false,
  });
}

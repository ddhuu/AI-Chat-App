import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/colors.dart';
import '../../models/assistant_model.dart';
import '../../models/publish_bot_state.dart';
import '../../providers/assistant_provider.dart';
import 'slack_config_dialog.dart';
import 'telegram_config_dialog.dart';
import 'messenger_config_dialog.dart';

class PlatformTile extends StatelessWidget {
  final String icon;
  final String title;
  final String platform;
  final PublishBotState state;
  final Assistant assistant;
  final VoidCallback onStateChanged;

  const PlatformTile({
    super.key,
    required this.icon,
    required this.title,
    required this.platform,
    required this.state,
    required this.assistant,
    required this.onStateChanged,
  });

  bool get isSelected {
    switch (platform) {
      case 'slack':
        return state.slackSelected;
      case 'telegram':
        return state.telegramSelected;
      case 'messenger':
        return state.messengerSelected;
      default:
        return false;
    }
  }

  bool get isVerified {
    switch (platform) {
      case 'slack':
        return state.isSlackVerified;
      case 'telegram':
        return state.isTelegramVerified;
      case 'messenger':
        return state.isMessengerVerified;
      default:
        return false;
    }
  }

  bool get isPublished {
    switch (platform) {
      case 'slack':
        return state.isSlackPublished;
      case 'telegram':
        return state.isTelegramPublished;
      case 'messenger':
        return state.isMessengerPublished;
      default:
        return false;
    }
  }

  String? get redirectUrl {
    switch (platform) {
      case 'slack':
        return state.slackConfig?['redirect'];
      case 'telegram':
        return state.telegramConfig?['redirect'];
      case 'messenger':
        return state.messengerConfig?['redirect'];
      default:
        return null;
    }
  }

  void _toggleSelection() {
    switch (platform) {
      case 'slack':
        state.slackSelected = !state.slackSelected;
        break;
      case 'telegram':
        state.telegramSelected = !state.telegramSelected;
        break;
      case 'messenger':
        state.messengerSelected = !state.messengerSelected;
        break;
    }
    onStateChanged();
  }

  Future<void> _handleConfigure(BuildContext context) async {
    Widget dialog;
    switch (platform) {
      case 'slack':
        dialog = SlackConfigDialog(assistant: assistant);
        break;
      case 'telegram':
        dialog = TelegramConfigDialog(assistant: assistant);
        break;
      case 'messenger':
        dialog = MessengerConfigDialog(assistant: assistant);
        break;
      default:
        return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => dialog,
    );

    if (result != null && result['verified'] == true) {
      switch (platform) {
        case 'slack':
          state.isSlackVerified = true;
          state.slackConfig = result['config'];
          break;
        case 'telegram':
          state.isTelegramVerified = true;
          state.telegramConfig = result['config'];
          break;
        case 'messenger':
          state.isMessengerVerified = true;
          state.messengerConfig = result['config'];
          break;
      }
      onStateChanged();
    }
  }

  Future<void> _handleDisconnect(BuildContext context) async {
    final shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect $title'),
        content: const Text(
          'Are you sure you want to disconnect this bot integration?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (shouldDisconnect == true && context.mounted) {
      final assistantProvider = context.read<AssistantProvider>();
      final success = await assistantProvider.disconnectBot(
        assistant.id,
        platform,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully disconnected $title integration'),
              backgroundColor: AppColors.success,
            ),
          );
          _resetPlatformState();
          onStateChanged();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to disconnect $title integration'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _resetPlatformState() {
    switch (platform) {
      case 'slack':
        state.isSlackVerified = false;
        state.isSlackPublished = false;
        state.slackConfig = null;
        state.slackSelected = false;
        break;
      case 'telegram':
        state.isTelegramVerified = false;
        state.isTelegramPublished = false;
        state.telegramConfig = null;
        state.telegramSelected = false;
        break;
      case 'messenger':
        state.isMessengerVerified = false;
        state.isMessengerPublished = false;
        state.messengerConfig = null;
        state.messengerSelected = false;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = isPublished
        ? AppColors.success
        : isVerified
        ? AppColors.info
        : AppColors.textSecondary;

    final bgColor = isPublished
        ? AppColors.success.withOpacity(0.1)
        : isVerified
        ? AppColors.info.withOpacity(0.1)
        : Colors.grey[100];

    final bool canCheck = isVerified && !isPublished;
    final bool checkboxValue = isPublished ? true : isSelected;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: InkWell(
        onTap: canCheck ? _toggleSelection : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: checkboxValue,
                      onChanged: canCheck
                          ? (bool? value) {
                              if (value != null) {
                                _toggleSelection();
                              }
                            }
                          : null,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPublished
                          ? 'Published'
                          : isVerified
                          ? 'Verified'
                          : 'Not Configured',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (isPublished || !isVerified)
                Padding(
                  padding: const EdgeInsets.only(left: 32, top: 8),
                  child: Row(
                    children: [
                      if (isPublished) ...[
                        if (redirectUrl != null)
                          TextButton(
                            onPressed: () async {
                              final Uri url = Uri.parse(redirectUrl!);
                              if (!await launchUrl(url)) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Could not open app page'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: const Size(0, 0),
                              foregroundColor: AppColors.primary,
                            ),
                            child: const Text(
                              'Your App',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        TextButton(
                          onPressed: () => _handleDisconnect(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 0),
                            foregroundColor: AppColors.error,
                          ),
                          child: const Text(
                            'Disconnect',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ] else
                        TextButton(
                          onPressed: () => _handleConfigure(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: const Size(0, 0),
                            foregroundColor: AppColors.primary,
                          ),
                          child: const Text(
                            'Configure',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

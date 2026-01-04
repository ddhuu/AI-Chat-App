import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../models/assistant_model.dart';
import '../models/publish_bot_state.dart';
import '../providers/assistant_provider.dart';
import 'platform/platform_tile.dart';

class PublishingPlatformDialog extends StatefulWidget {
  final Assistant assistant;
  final List<dynamic> configurations;

  const PublishingPlatformDialog({
    super.key,
    required this.assistant,
    this.configurations = const [],
  });

  @override
  State<PublishingPlatformDialog> createState() =>
      _PublishingPlatformDialogState();
}

class _PublishingPlatformDialogState extends State<PublishingPlatformDialog> {
  late final PublishBotState state;

  @override
  void initState() {
    super.initState();
    state = PublishBotState(widget.configurations);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Platform List
            Expanded(child: _buildPlatforms()),

            // Footer Buttons
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildPlatforms() {
    return Column(
      children: [
        PlatformTile(
          icon: '💬',
          title: 'Slack',
          platform: 'slack',
          state: state,
          assistant: widget.assistant,
          onStateChanged: () => setState(() {}),
        ),
        PlatformTile(
          icon: '✈️',
          title: 'Telegram',
          platform: 'telegram',
          state: state,
          assistant: widget.assistant,
          onStateChanged: () => setState(() {}),
        ),
        PlatformTile(
          icon: '💬',
          title: 'Messenger',
          platform: 'messenger',
          state: state,
          assistant: widget.assistant,
          onStateChanged: () => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _handlePublish(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Publish',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePublish() async {
    final assistantProvider = context.read<AssistantProvider>();
    await state.handlePublish(context, widget.assistant, assistantProvider);
  }
}

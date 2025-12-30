import 'package:flutter/material.dart';
import '../models/assistant_model.dart';
import '../providers/assistant_provider.dart';

class PublishBotState {
  // Selection states
  bool slackSelected = false;
  bool telegramSelected = false;
  bool messengerSelected = false;

  // Verification states
  bool isSlackVerified = false;
  bool isTelegramVerified = false;
  bool isMessengerVerified = false;

  // Published states
  bool isSlackPublished = false;
  bool isTelegramPublished = false;
  bool isMessengerPublished = false;

  // Configuration data
  Map<String, dynamic>? slackConfig;
  Map<String, dynamic>? telegramConfig;
  Map<String, dynamic>? messengerConfig;

  PublishBotState(List<dynamic> configurations) {
    _initializeConfigurations(configurations);
  }

  void _initializeConfigurations(List<dynamic> configurations) {
    for (var config in configurations) {
      final type = config['type'];
      final metadata = config['metadata'];

      switch (type) {
        case 'slack':
          isSlackVerified = true;
          isSlackPublished = true;
          slackSelected = true;
          slackConfig = {
            'botToken': metadata['botToken'],
            'clientId': metadata['clientId'],
            'clientSecret': metadata['clientSecret'],
            'signingSecret': metadata['signingSecret'],
            'redirect': metadata['redirect'],
          };
          break;

        case 'telegram':
          isTelegramVerified = true;
          isTelegramPublished = true;
          telegramSelected = true;
          telegramConfig = {
            'botToken': metadata['botToken'],
            'redirect': metadata['redirect'],
          };
          break;

        case 'messenger':
          isMessengerVerified = true;
          isMessengerPublished = true;
          messengerSelected = true;
          messengerConfig = {
            'botToken': metadata['botToken'],
            'pageId': metadata['pageId'],
            'appSecret': metadata['appSecret'],
            'redirect': metadata['redirect'],
          };
          break;
      }
    }
  }

  Future<void> handlePublish(
    BuildContext context,
    Assistant assistant,
    AssistantProvider assistantProvider,
  ) async {
    if (!slackSelected && !telegramSelected && !messengerSelected) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one platform'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => _buildLoadingDialog(),
      );
    }

    try {
      final result = await _publishToPlatforms(
        context,
        assistant,
        assistantProvider,
      );
      if (context.mounted) {
        Navigator.pop(context);
        _handlePublishResult(context, result);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred during publishing'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildLoadingDialog() {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Publishing...'),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _publishToPlatforms(
    BuildContext context,
    Assistant assistant,
    AssistantProvider assistantProvider,
  ) async {
    bool hasError = false;
    List<String> publishedPlatforms = [];

    if (slackSelected && isSlackVerified && slackConfig != null) {
      final success = await assistantProvider.publishSlackBot(
        assistant.id,
        botToken: slackConfig!['botToken'],
        clientId: slackConfig!['clientId'],
        clientSecret: slackConfig!['clientSecret'],
        signingSecret: slackConfig!['signingSecret'],
      );
      if (success) {
        publishedPlatforms.add('Slack');
      } else {
        hasError = true;
      }
    }

    if (telegramSelected && isTelegramVerified && telegramConfig != null) {
      final success = await assistantProvider.publishTelegramBot(
        assistant.id,
        telegramConfig!['botToken'],
      );
      if (success) {
        publishedPlatforms.add('Telegram');
      } else {
        hasError = true;
      }
    }

    if (messengerSelected && isMessengerVerified && messengerConfig != null) {
      final success = await assistantProvider.publishMessengerBot(
        assistant.id,
        botToken: messengerConfig!['botToken'],
        pageId: messengerConfig!['pageId'],
        appSecret: messengerConfig!['appSecret'],
      );
      if (success) {
        publishedPlatforms.add('Messenger');
      } else {
        hasError = true;
      }
    }

    return {'hasError': hasError, 'publishedPlatforms': publishedPlatforms};
  }

  void _handlePublishResult(BuildContext context, Map<String, dynamic> result) {
    final hasError = result['hasError'] as bool;
    final publishedPlatforms = result['publishedPlatforms'] as List<String>;

    if (publishedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No platforms were published successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasError
                ? 'Some platforms cannot publish. Successfully published: ${publishedPlatforms.join(", ")}'
                : 'Successfully published to: ${publishedPlatforms.join(", ")}',
          ),
          backgroundColor: hasError ? Colors.orange : Colors.green,
        ),
      );
      Navigator.pop(context, true);
    }
  }
}

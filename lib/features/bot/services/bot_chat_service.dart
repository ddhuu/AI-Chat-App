import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';

class BotChatService {
  final ApiService _apiService;

  BotChatService(this._apiService);

  /// Send message to bot and get response
  Future<Map<String, dynamic>> sendMessage({
    required String content,
    required String assistantId,
    required String assistantName,
    required String model,
    List<Map<String, dynamic>>? conversationHistory,
    List<String>? files,
  }) async {
    try {
      // Build conversation history
      final List<Map<String, dynamic>> messages = [];

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (var msg in conversationHistory) {
          messages.add({
            'role': msg['isUser'] == true ? 'user' : 'model',
            'content': msg['message'],
            if (msg['files'] != null) 'files': msg['files'],
            'assistant': {
              'model': model,
              'name': assistantName,
              'id': assistantId,
            },
          });
        }
      }

      // Build request body
      final requestBody = {
        'content': content,
        'files': files ?? [],
        'metadata': {
          'conversation': {'messages': messages},
        },
        'assistant': {'model': model, 'name': assistantName, 'id': assistantId},
      };

      final response = await _apiService.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.aiChatMessages}',
        data: requestBody,
        options: Options(
          extra: {'requireToken': true},
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return {
          'message': response.data['message'] as String? ?? '',
          'remainingUsage': response.data['remainingUsage'] as int? ?? 0,
        };
      }

      throw Exception('Failed to send message');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          print('Status code: ${e.response?.statusCode}');
          print('Response data: ${e.response?.data}');
        }
      }
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send message with streaming response (for future implementation)
  Stream<String> sendMessageStream({
    required String content,
    required String assistantId,
    required String assistantName,
    required String model,
    List<Map<String, dynamic>>? conversationHistory,
  }) async* {
    // TODO: Implement streaming response when API supports it
    final response = await sendMessage(
      content: content,
      assistantId: assistantId,
      assistantName: assistantName,
      model: model,
      conversationHistory: conversationHistory,
    );

    yield response['message'] as String;
  }
}

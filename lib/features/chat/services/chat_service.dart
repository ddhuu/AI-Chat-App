import 'dart:io';
import 'package:ai_chat_assistant/core/constants/ai_models.dart';
import 'package:ai_chat_assistant/core/constants/api_constants.dart';
import 'package:ai_chat_assistant/core/utils/logger.dart';
import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:dio/dio.dart';

/// Chat Service
/// Handles all chat-related API calls
class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  /// Create new thread chat (first message in conversation)
  /// Uses sendMessage with empty messages array
  /// Returns: { conversationId, message, remainingUsage }
  Future<Map<String, dynamic>> createNewThread({
    required String message,
    required String modelDisplayName,
  }) async {
    return sendMessage(
      message: message,
      modelDisplayName: modelDisplayName,
      conversationHistory: [], // Empty = new thread
      conversationId: null, // No ID = new thread
    );
  }

  /// Send message (works for both new thread and existing conversation)
  /// - Empty messages array + no conversationId = new thread
  /// - Has conversationId = existing conversation
  /// Returns: { conversationId, message, remainingUsage }
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String modelDisplayName,
    required List<Map<String, dynamic>> conversationHistory,
    String? conversationId,
  }) async {
    try {
      final modelId = AiModels.getModelId(modelDisplayName);

      final isNewThread = conversationId == null;
      AppLogger.info(
        isNewThread
            ? 'Creating new thread with model: $modelDisplayName'
            : 'Sending message to conversation: $conversationId',
        tag: 'ChatService',
      );
      if (conversationHistory.isNotEmpty) {
        AppLogger.warning(
          'conversationHistory should be empty! Server tracks history by conversationId.',
          tag: 'ChatService',
        );
      }

      final response = await _apiService.dio.post(
        ApiConstants.sendMessage,
        data: {
          "content": message,
          "metadata": {
            "conversation": {
              if (conversationId != null) "id": conversationId,
              "messages": conversationHistory,
            },
          },
          "assistant": {
            "id": modelId,
            "model": "dify",
            "name": modelDisplayName,
          },
        },
        options: Options(
          headers: {HttpHeaders.contentTypeHeader: "application/json"},
          extra: {'requireToken': true},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.info(
          isNewThread
              ? 'New thread created successfully'
              : 'Message sent successfully',
          tag: 'ChatService',
        );
        return response.data;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Failed to send message', tag: 'ChatService', error: e);
      rethrow;
    }
  }

  /// Get all conversations
  /// Requires assistantId and assistantModel parameters
  Future<List<dynamic>> getConversations({
    String assistantId = 'gpt-4o-mini',
    String assistantModel = 'dify',
  }) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.getConversations,
        queryParameters: {
          'assistantId': assistantId,
          'assistantModel': assistantModel,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Response might be array directly or wrapped in object
        if (response.data is List) {
          return response.data;
        } else if (response.data['items'] != null) {
          return response.data['items'];
        } else if (response.data['conversations'] != null) {
          return response.data['conversations'];
        }
        return [];
      }

      return [];
    } catch (e) {
      AppLogger.error(
        'Failed to get conversations',
        tag: 'ChatService',
        error: e,
      );
      return [];
    }
  }

  /// Get conversation history (messages)
  /// Requires assistantModel parameter
  Future<List<dynamic>> getConversationHistory(
    String conversationId, {
    String assistantModel = 'dify',
  }) async {
    try {
      final url = ApiConstants.getConversationHistory.replaceAll(
        '{conversationId}',
        conversationId,
      );

      final response = await _apiService.dio.get(
        url,
        queryParameters: {'assistantModel': assistantModel},
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Response might be array directly or wrapped in object
        if (response.data is List) {
          return response.data;
        } else if (response.data['items'] != null) {
          return response.data['items'];
        } else if (response.data['messages'] != null) {
          return response.data['messages'];
        }
        return [];
      }

      return [];
    } catch (e) {
      AppLogger.error(
        'Failed to get conversation history',
        tag: 'ChatService',
        error: e,
      );
      return [];
    }
  }
}

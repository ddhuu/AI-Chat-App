import 'dart:io';
import 'package:ai_chat_assistant/core/constants/ai_models.dart';
import 'package:ai_chat_assistant/core/constants/api_constants.dart';
import 'package:ai_chat_assistant/core/utils/logger.dart';
import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:dio/dio.dart';

/// Chat Service
class ChatService {
  final ApiService _apiService;

  ChatService(this._apiService);

  /// Create new thread chat
  Future<Map<String, dynamic>> createNewThread({
    required String message,
    required String modelDisplayName,
    List<Map<String, dynamic>>? conversationHistory,
    List<String>? files,
  }) async {
    return sendMessage(
      message: message,
      modelDisplayName: modelDisplayName,
      conversationHistory: conversationHistory ?? [],
      conversationId: null,
      files: files,
    );
  }

  /// Send message
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required String modelDisplayName,
    required List<Map<String, dynamic>> conversationHistory,
    String? conversationId,
    List<String>? files,
  }) async {
    try {
      // 1. Map model display name to ID
      String modelId = _mapDisplayNameToId(modelDisplayName);

      // 2. Prepare request body
      final Map<String, dynamic> body = {
        'content': message, // <--- SỬA LỖI TẠI ĐÂY (Đổi 'message' thành 'content')
        'model': modelId,
        'history': conversationHistory,
        'stream': false,
      };

      if (conversationId != null) {
        body['conversationId'] = conversationId;
      }

      // Xử lý file (URL)
      if (files != null && files.isNotEmpty) {
        body['files'] = files;
      }

      // 3. Call API
      // Sử dụng endpoint aiChatMessages (/api/v1/ai-chat/messages)
      final response = await _apiService.dio.post(
        ApiConstants.aiChatMessages,
        data: body,
        options: Options(extra: {'requireToken': true}),
      );

      // 4. Parse response
      if (response.statusCode == 200) {
        return {
          'message': response.data['message'] ?? response.data['answer'] ?? '',
          'conversationId': response.data['conversationId'],
          'remainingUsage': response.data['remainingUsage'] ?? 0,
        };
      } else {
        throw Exception('Failed to send message: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('Error sending message', error: e);
      rethrow;
    }
  }

  // Helper mapping model names
  String _mapDisplayNameToId(String displayName) {
    final map = {
      'GPT-4o mini': 'gpt-4o-mini',
      'GPT-4o': 'gpt-4o',
      'Gemini 1.5 Flash': 'gemini-1.5-flash',
      'Gemini 1.5 Pro': 'gemini-1.5-pro',
      'Claude 3 Haiku': 'claude-3-haiku',
      'Claude 3.5 Sonnet': 'claude-3.5-sonnet',
    };
    return map[displayName] ?? displayName.toLowerCase().replaceAll(' ', '-');
  }

  /// Get conversations list
  Future<List<dynamic>> getConversations({
    required String assistantId,
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
        if (response.data is List) {
          return response.data;
        } else if (response.data['items'] != null) {
          return response.data['items'];
        }
        return [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get conversation history
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
      return [];
    }
  }
}
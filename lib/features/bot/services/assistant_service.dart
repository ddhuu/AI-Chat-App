import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../models/assistant_model.dart';

class AssistantService {
  final ApiService _apiService;

  AssistantService(this._apiService);

  /// Get list of assistants with filters
  Future<AssistantsResponse> getAssistants({
    String? query,
    String order = 'DESC',
    String? orderField,
    int offset = 0,
    int limit = 10,
    bool? isFavorite,
    bool? isPublished,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'order': order,
        'offset': offset,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (orderField != null && orderField.isNotEmpty) {
        queryParams['order_field'] = orderField;
      }

      if (isFavorite != null) {
        queryParams['is_favorite'] = isFavorite;
      }

      if (isPublished != null) {
        queryParams['is_published'] = isPublished;
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.knowledgeBaseUrl}${ApiConstants.aiAssistant}',
        queryParameters: queryParams,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return AssistantsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }

      throw Exception('Failed to load assistants');
    } catch (e) {
      throw Exception('Failed to load assistants: $e');
    }
  }

  /// Get single assistant by ID
  Future<Assistant> getAssistant(String id) async {
    try {
      final endpoint = ApiConstants.aiAssistantById.replaceAll('{id}', id);
      final response = await _apiService.dio.get(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return Assistant.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to load assistant');
    } catch (e) {
      throw Exception('Failed to load assistant: $e');
    }
  }

  /// Create new assistant
  Future<Assistant> createAssistant({
    required String assistantName,
    String? instructions,
    String? description,
    String? model,
    List<String>? datasources,
  }) async {
    try {

      final requestData = {
        'assistantName': assistantName,
        if (instructions != null) 'instructions': instructions,
        if (description != null) 'description': description,
        if (model != null) 'model': model,
        if (datasources != null) 'datasources': datasources,
      };


      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}${ApiConstants.aiAssistant}',
        data: requestData,
        options: Options(extra: {'requireToken': true}),
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        return Assistant.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to create assistant');
    } catch (e) {
      throw Exception('Failed to create assistant: $e');
    }
  }

  /// Update assistant
  Future<Assistant> updateAssistant({
    required String id,
    String? assistantName,
    String? instructions,
    String? description,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (assistantName != null) data['assistantName'] = assistantName;
      if (instructions != null) data['instructions'] = instructions;
      if (description != null) data['description'] = description;

      final endpoint = ApiConstants.aiAssistantById.replaceAll('{id}', id);
      final response = await _apiService.dio.patch(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: data,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return Assistant.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to update assistant');
    } catch (e) {
      throw Exception('Failed to update assistant: $e');
    }
  }

  /// Delete assistant
  Future<void> deleteAssistant(String id) async {
    try {
      final endpoint = ApiConstants.aiAssistantById.replaceAll('{id}', id);
      await _apiService.dio.delete(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        options: Options(extra: {'requireToken': true}),
      );
    } catch (e) {
      throw Exception('Failed to delete assistant: $e');
    }
  }

  /// Import knowledge to assistant
  Future<bool> importKnowledgeToAssistant({
    required String assistantId,
    required String knowledgeId,
  }) async {
    try {

      final endpoint = ApiConstants.assistantKnowledgeById
          .replaceAll('{assistantId}', assistantId)
          .replaceAll('{knowledgeId}', knowledgeId);


      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        options: Options(
          extra: {'requireToken': true},
          headers: {'x-jarvis-guid': null},
        ),
      );



      // 204 No Content is success for import operation
      return response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to import knowledge: $e');
    }
  }

  /// Remove knowledge from assistant
  Future<bool> removeKnowledgeFromAssistant({
    required String assistantId,
    required String knowledgeId,
  }) async {
    try {

      final endpoint = ApiConstants.assistantKnowledgeById
          .replaceAll('{assistantId}', assistantId)
          .replaceAll('{knowledgeId}', knowledgeId);



      final response = await _apiService.dio.delete(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        options: Options(
          extra: {'requireToken': true},
          headers: {'x-jarvis-guid': null},
        ),
      );



      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to remove knowledge: $e');
    }
  }

  // ==================== PUBLISH BOT METHODS ====================

  /// Verify Slack configuration
  Future<bool> verifySlackConfig({
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
  }) async {
    try {
     

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/slack/validation',
        data: {
          'botToken': botToken,
          'clientId': clientId,
          'clientSecret': clientSecret,
          'signingSecret': signingSecret,
        },
        options: Options(extra: {'requireToken': true}),
      );

 
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Verify Telegram configuration
  Future<bool> verifyTelegramConfig({required String botToken}) async {
    try {

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/telegram/validation',
        data: {'botToken': botToken},
        options: Options(extra: {'requireToken': true}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Verify Messenger configuration
  Future<bool> verifyMessengerConfig({
    required String botToken,
    required String pageId,
    required String appSecret,
  }) async {
    try {

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/messenger/validation',
        data: {'botToken': botToken, 'pageId': pageId, 'appSecret': appSecret},
        options: Options(extra: {'requireToken': true}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Publish bot to Slack
  Future<bool> publishSlackBot({
    required String assistantId,
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
  }) async {
    try {

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/slack/publish/$assistantId',
        data: {
          'botToken': botToken,
          'clientId': clientId,
          'clientSecret': clientSecret,
          'signingSecret': signingSecret,
        },
        options: Options(extra: {'requireToken': true}),
      );


      if (response.data != null && response.data['redirect'] != null) {
        print('[AssistantService] Bot URL: ${response.data['redirect']}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[AssistantService] Publish Slack error: $e');
      return false;
    }
  }

  /// Publish bot to Telegram
  Future<bool> publishTelegramBot({
    required String assistantId,
    required String botToken,
  }) async {
    try {
     
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/telegram/publish/$assistantId',
        data: {'botToken': botToken},
        options: Options(extra: {'requireToken': true}),
      );

     

      if (response.data != null && response.data['redirect'] != null) {
        print('[AssistantService] Bot URL: ${response.data['redirect']}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Publish bot to Messenger
  Future<bool> publishMessengerBot({
    required String assistantId,
    required String botToken,
    required String pageId,
    required String appSecret,
  }) async {
    try {

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/messenger/publish/$assistantId',
        data: {'botToken': botToken, 'pageId': pageId, 'appSecret': appSecret},
        options: Options(extra: {'requireToken': true}),
      );


      if (response.data != null && response.data['redirect'] != null) {
        print('🔗 [AssistantService] Bot URL: ${response.data['redirect']}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Disconnect bot from platform
  Future<bool> disconnectBot({
    required String assistantId,
    required String platform,
  }) async {
    try {

      final response = await _apiService.dio.delete(
        '${ApiConstants.knowledgeBaseUrl}/kb-core/v1/bot-integration/$platform/disconnect/$assistantId',
        options: Options(extra: {'requireToken': true}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== END PUBLISH BOT METHODS ====================

  /// Get assistant's knowledges
  Future<List<dynamic>> getAssistantKnowledges({
    required String assistantId,
    String? query,
    String order = 'DESC',
    String? orderField,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final endpoint = ApiConstants.assistantKnowledges.replaceAll(
        '{assistantId}',
        assistantId,
      );

      final Map<String, dynamic> queryParams = {
        'order': order,
        'offset': offset,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      if (orderField != null && orderField.isNotEmpty) {
        queryParams['order_field'] = orderField;
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        queryParameters: queryParams,
        options: Options(
          extra: {'requireToken': true},
          headers: {'x-jarvis-guid': null},
        ),
      );

      if (response.statusCode == 200) {
        return (response.data['data'] as List?) ?? [];
      }

      throw Exception('Failed to load assistant knowledges');
    } catch (e) {
      throw Exception('Failed to load assistant knowledges: $e');
    }
  }
}

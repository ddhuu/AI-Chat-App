import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../models/knowledge_model.dart';

class KnowledgeService {
  final ApiService _apiService;

  KnowledgeService(this._apiService);

  /// Get list of knowledge bases with pagination
  Future<Map<String, dynamic>> getKnowledges({
    int limit = 20,
    int offset = 0,
    String? query,
  }) async {
    try {
      final queryParams = <String, dynamic>{'limit': limit, 'offset': offset};

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _apiService.dio.get(
        '${ApiConstants.knowledgeBaseUrl}${ApiConstants.knowledge}',
        queryParameters: queryParams,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to load knowledges');
    } catch (e) {
      print('Error loading knowledges: $e');
      rethrow;
    }
  }

  /// Create a new knowledge base
  Future<Knowledge> createKnowledge({
    required String knowledgeName,
    required String description,
  }) async {
    try {
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}${ApiConstants.knowledge}',
        data: {'knowledgeName': knowledgeName, 'description': description},
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Knowledge.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to create knowledge');
    } catch (e) {
      print('Error creating knowledge: $e');
      rethrow;
    }
  }

  /// Get a specific knowledge base by ID
  Future<Knowledge> getKnowledgeById(String id) async {
    try {
      final url = ApiConstants.knowledgeById.replaceFirst('{id}', id);

      final response = await _apiService.dio.get(
        '${ApiConstants.knowledgeBaseUrl}$url',
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return Knowledge.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to load knowledge');
    } catch (e) {
      print('Error loading knowledge: $e');
      rethrow;
    }
  }

  /// Update a knowledge base
  Future<Knowledge> updateKnowledge({
    required String id,
    required String knowledgeName,
    required String description,
  }) async {
    try {
      final url = ApiConstants.knowledgeById.replaceFirst('{id}', id);

      final response = await _apiService.dio.patch(
        '${ApiConstants.knowledgeBaseUrl}$url',
        data: {'knowledgeName': knowledgeName, 'description': description},
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return Knowledge.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to update knowledge');
    } catch (e) {
      print('Error updating knowledge: $e');
      rethrow;
    }
  }

  /// Delete a knowledge base
  Future<void> deleteKnowledge(String id) async {
    try {
      final url = ApiConstants.knowledgeById.replaceFirst('{id}', id);

      final response = await _apiService.dio.delete(
        '${ApiConstants.knowledgeBaseUrl}$url',
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete knowledge');
      }
    } catch (e) {
      print('Error deleting knowledge: $e');
      rethrow;
    }
  }
}

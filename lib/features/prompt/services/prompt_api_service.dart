import 'package:ai_chat_assistant/core/constants/api_constants.dart';
import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:ai_chat_assistant/features/prompt/models/prompt_model.dart';
import 'package:dio/dio.dart';

class PromptApiService {
  final ApiService _apiService;

  PromptApiService(this._apiService);

  /// Get prompts with filters
  Future<Map<String, dynamic>> getPrompts(Map<String, dynamic> params) async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.crudPrompts,
        queryParameters: params,
        options: Options(extra: {'requireToken': true}),
      );
      return response.data;
    } catch (e) {
      print('Error getting prompts: $e');
      rethrow;
    }
  }

  /// Create new prompt
  Future<bool> createPrompt(PromptModel prompt) async {
    try {
      await _apiService.dio.post(
        ApiConstants.crudPrompts,
        data: {
          'title': prompt.name,
          'content': prompt.content,
          'category': prompt.category,
          'description': prompt.description,
          'isPublic': prompt.isPublic,
          'language': 'English',
        },
        options: Options(extra: {'requireToken': true}),
      );
      return true;
    } catch (e) {
      print('Error creating prompt: $e');
      return false;
    }
  }

  /// Update existing prompt
  Future<bool> updatePrompt(PromptModel prompt) async {
    try {
      await _apiService.dio.patch(
        '${ApiConstants.crudPrompts}/${prompt.id}',
        data: {
          'title': prompt.name,
          'content': prompt.content,
          'category': prompt.category,
          'description': prompt.description,
          'isPublic': prompt.isPublic,
          'language': 'English',
        },
        options: Options(extra: {'requireToken': true}),
      );
      return true;
    } catch (e) {
      print('Error updating prompt: $e');
      return false;
    }
  }

  /// Delete prompt
  Future<bool> deletePrompt(String promptId) async {
    try {
      await _apiService.dio.delete(
        '${ApiConstants.crudPrompts}/$promptId',
        options: Options(extra: {'requireToken': true}),
      );
      return true;
    } catch (e) {
      print('Error deleting prompt: $e');
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(
    String promptId,
    bool currentFavoriteStatus,
  ) async {
    try {
      if (currentFavoriteStatus) {
        // Remove from favorite
        await _apiService.dio.delete(
          '${ApiConstants.crudPrompts}/$promptId/favorite',
          options: Options(extra: {'requireToken': true}),
        );
      } else {
        // Add to favorite
        await _apiService.dio.post(
          '${ApiConstants.crudPrompts}/$promptId/favorite',
          options: Options(extra: {'requireToken': true}),
        );
      }
      return true;
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }
}

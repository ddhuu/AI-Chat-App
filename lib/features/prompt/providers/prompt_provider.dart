import 'package:ai_chat_assistant/features/prompt/models/prompt_model.dart';
import 'package:ai_chat_assistant/features/prompt/services/prompt_api_service.dart';
import 'package:flutter/material.dart';

class PromptProvider with ChangeNotifier {
  final PromptApiService _apiService;

  PromptProvider(this._apiService);

  List<PrivatePrompt> _privatePrompts = [];
  List<PublicPrompt> _publicPrompts = [];
  bool _isPrivateLoading = false;
  bool _isPublicLoading = false;

  bool _publicHasNext = true;
  bool _privateHasNext = true;
  String? _errorMessage;

  List<PrivatePrompt> get privatePrompts => _privatePrompts;
  List<PublicPrompt> get publicPrompts => _publicPrompts;

  bool get publicHasNext => _publicHasNext;
  bool get privateHasNext => _privateHasNext;
  bool get isLoading => _isPrivateLoading || _isPublicLoading;
  String? get errorMessage => _errorMessage;

  /// Load private prompts
  Future<void> loadPrivatePrompts({
    String? category,
    bool? isFavorite,
    int offset = 0,
    int limit = 20,
    bool isLoadMore = false
  }) async {
    if (!isLoadMore) {
      _isPrivateLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final params = <String, dynamic>{
        'isPublic': false,
        'offset': offset,
        'limit': limit,
      };

      if (category != null && category != 'All') {
        params['category'] = category;
      }

      if (isFavorite != null && isFavorite) {
        params['isFavorite'] = true;
      }

      final response = await _apiService.getPrompts(params);

      _privateHasNext = response['hasNext'] as bool? ?? false;

      final List<dynamic> promptsJson = response['items'] ?? [];
      final List<PrivatePrompt> newPrompts = promptsJson
          .map((json) => PrivatePrompt.fromJson(json))
          .toList();

      if (isLoadMore) {
        _privatePrompts.addAll(newPrompts);
      } else {
        _privatePrompts = newPrompts;
      }

    } catch (e) {
      _errorMessage = 'Failed to load private prompts: $e';
    } finally {
      _isPrivateLoading = false;
      notifyListeners();
    }
  }

  /// Load public prompts
  Future<void> loadPublicPrompts({
    String? category,
    bool? isFavorite,
    String? query,
    int offset = 0,
    int limit = 20,
    bool isLoadMore = false,
  }) async {
    if (!isLoadMore) {
      _isPublicLoading = true;
      notifyListeners();
    }
    _errorMessage = null;

    try {
      final params = <String, dynamic>{
        'isPublic': true,
        'offset': offset,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) params['query'] = query;

      if (category != null && category != 'All') params['category'] = category.toLowerCase();
      if (isFavorite != null && isFavorite) params['isFavorite'] = true;

      final response = await _apiService.getPrompts(params);
      _publicHasNext = response['hasNext'] as bool? ?? false;

      final List<dynamic> promptsJson = response['items'] ?? [];

      final List<PublicPrompt> newPrompts = [];
      for (var json in promptsJson) {
        try {
          newPrompts.add(PublicPrompt.fromJson(json));
        } catch (e) {
          print("Error parsing specific prompt: $e");
        }
      }

      if (isLoadMore) {
        _publicPrompts.addAll(newPrompts);
      } else {
        _publicPrompts = newPrompts;
      }

    } catch (e) {
      _errorMessage = 'Failed to load public prompts: $e';
      print(_errorMessage);
    } finally {
      _isPublicLoading = false;
      notifyListeners();
    }
  }

  /// Create new prompt
  Future<bool> createPrompt(PromptModel prompt) async {
    try {
      final success = await _apiService.createPrompt(prompt);

      if (success) {
        // Reload prompts immediately without showing loading
        if (prompt.isPublic) {
          await loadPublicPrompts();
        } else {
          await loadPrivatePrompts();
        }
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to create prompt: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update prompt
  Future<bool> updatePrompt(PromptModel prompt) async {
    _isPrivateLoading = true;
    _isPublicLoading=true;
    notifyListeners();

    try {
      final success = await _apiService.updatePrompt(prompt);

      if (success) {
        // Reload prompts
        if (prompt.isPublic) {
          await loadPublicPrompts();
        } else {
          await loadPrivatePrompts();
        }
      }

      _isPrivateLoading = false;
      _isPublicLoading=false;
      notifyListeners();
      return success;
    } catch (e) {
      _isPrivateLoading = false;
      _isPublicLoading=false;
      _errorMessage = 'Failed to update prompt: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete prompt
  Future<bool> deletePrompt(PromptModel prompt) async {
    _isPrivateLoading = true;
    _isPublicLoading=true;
    notifyListeners();

    try {
      final success = await _apiService.deletePrompt(prompt.id);

      if (success) {
        // Remove from local list
        if (prompt.isPublic) {
          _publicPrompts.removeWhere((p) => p.id == prompt.id);
        } else {
          _privatePrompts.removeWhere((p) => p.id == prompt.id);
        }
      }

      _isPrivateLoading = false;
      _isPublicLoading=false;
      notifyListeners();
      return success;
    } catch (e) {
      _isPrivateLoading = false;
      _isPublicLoading=false;
      _errorMessage = 'Failed to delete prompt: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorite
  Future<bool> toggleFavorite(PromptModel prompt) async {
    try {
      final success = await _apiService.toggleFavorite(
        prompt.id,
        prompt.isFavorite,
      );

      if (success) {
        // Update local state
        prompt.isFavorite = !prompt.isFavorite;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = 'Failed to toggle favorite: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

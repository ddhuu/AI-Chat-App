import 'package:ai_chat_assistant/features/prompt/models/prompt_model.dart';
import 'package:ai_chat_assistant/features/prompt/services/prompt_api_service.dart';
import 'package:flutter/material.dart';

class PromptProvider with ChangeNotifier {
  final PromptApiService _apiService;

  PromptProvider(this._apiService);

  List<PrivatePrompt> _privatePrompts = [];
  List<PublicPrompt> _publicPrompts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PrivatePrompt> get privatePrompts => _privatePrompts;
  List<PublicPrompt> get publicPrompts => _publicPrompts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load private prompts
  Future<void> loadPrivatePrompts({String? category, bool? isFavorite}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'isPublic': false};

      if (category != null && category != 'All') {
        params['category'] = category;
      }

      if (isFavorite != null && isFavorite) {
        params['isFavorite'] = true;
      }

      final response = await _apiService.getPrompts(params);
      final List<dynamic> promptsJson = response['items'] ?? [];

      _privatePrompts = promptsJson
          .map((json) => PrivatePrompt.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load private prompts: $e';
      notifyListeners();
    }
  }

  /// Load public prompts
  Future<void> loadPublicPrompts({String? category, bool? isFavorite}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = <String, dynamic>{'isPublic': true};

      if (category != null && category != 'All') {
        params['category'] = category;
      }

      if (isFavorite != null && isFavorite) {
        params['isFavorite'] = true;
      }

      final response = await _apiService.getPrompts(params);
      final List<dynamic> promptsJson = response['items'] ?? [];

      _publicPrompts = promptsJson
          .map((json) => PublicPrompt.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load public prompts: $e';
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
    _isLoading = true;
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

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update prompt: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete prompt
  Future<bool> deletePrompt(PromptModel prompt) async {
    _isLoading = true;
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

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
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

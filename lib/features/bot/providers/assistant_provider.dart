import 'package:flutter/foundation.dart';
import '../models/assistant_model.dart';
import '../services/assistant_service.dart';

class AssistantProvider with ChangeNotifier {
  final AssistantService _assistantService;

  AssistantProvider(this._assistantService);

  List<Assistant> _assistants = [];
  bool _isLoading = false;
  bool _hasNext = false;
  int _offset = 0;
  String? _errorMessage;

  List<Assistant> get assistants => _assistants;
  bool get isLoading => _isLoading;
  bool get hasNext => _hasNext;
  String? get errorMessage => _errorMessage;

  /// Load assistants with optional filters
  Future<void> loadAssistants({
    String? query,
    bool? isFavorite,
    bool? isPublished,
    bool isLoadMore = false,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    if (!isLoadMore) {
      _offset = 0;
      _assistants.clear();
    }

    notifyListeners();

    try {
      final response = await _assistantService.getAssistants(
        query: query,
        offset: _offset,
        limit: 20,
        isFavorite: isFavorite,
        isPublished: isPublished,
        orderField: 'updatedAt',
      );

      if (isLoadMore) {
        _assistants.addAll(response.data);
      } else {
        _assistants = response.data;
      }

      _hasNext = response.meta.hasNext;
      _offset = _assistants.length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh assistants list
  Future<void> refresh({String? query}) async {
    await loadAssistants(query: query);
  }

  /// Get single assistant
  Future<Assistant?> getAssistant(String id) async {
    try {
      return await _assistantService.getAssistant(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Create new assistant
  Future<bool> createAssistant({
    required String assistantName,
    String? instructions,
    String? description,
    String? model,
    List<String>? datasources,
  }) async {
    try {
      _errorMessage = null;
      final assistant = await _assistantService.createAssistant(
        assistantName: assistantName,
        instructions: instructions,
        description: description,
        model: model,
        datasources: datasources,
      );

      // Add to beginning of list
      _assistants.insert(0, assistant);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update assistant
  Future<bool> updateAssistant({
    required String id,
    String? assistantName,
    String? instructions,
    String? description,
  }) async {
    try {
      _errorMessage = null;
      final updatedAssistant = await _assistantService.updateAssistant(
        id: id,
        assistantName: assistantName,
        instructions: instructions,
        description: description,
      );

      // Update in list
      final index = _assistants.indexWhere((a) => a.id == id);
      if (index != -1) {
        _assistants[index] = updatedAssistant;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete assistant
  Future<bool> deleteAssistant(String id) async {
    try {
      _errorMessage = null;
      await _assistantService.deleteAssistant(id);

      // Remove from list
      _assistants.removeWhere((a) => a.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String id) async {
    try {
      final assistant = _assistants.firstWhere((a) => a.id == id);
      final newFavoriteStatus = !assistant.isFavorite;

      // Optimistically update UI
      final index = _assistants.indexWhere((a) => a.id == id);
      if (index != -1) {
        _assistants[index] = assistant.copyWith(isFavorite: newFavoriteStatus);
        notifyListeners();
      }

      // TODO: Call API to update favorite status when endpoint is available
      // For now, just return true
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Import knowledge to assistant
  Future<bool> importKnowledge({
    required String assistantId,
    required String knowledgeId,
  }) async {
    try {
      _errorMessage = null;
      return await _assistantService.importKnowledgeToAssistant(
        assistantId: assistantId,
        knowledgeId: knowledgeId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove knowledge from assistant
  Future<bool> removeKnowledge({
    required String assistantId,
    required String knowledgeId,
  }) async {
    try {
      _errorMessage = null;
      return await _assistantService.removeKnowledgeFromAssistant(
        assistantId: assistantId,
        knowledgeId: knowledgeId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get assistant's knowledges
  Future<List<dynamic>> getAssistantKnowledges(String assistantId) async {
    try {
      _errorMessage = null;
      return await _assistantService.getAssistantKnowledges(
        assistantId: assistantId,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
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
      _errorMessage = null;
      return await _assistantService.verifySlackConfig(
        botToken: botToken,
        clientId: clientId,
        clientSecret: clientSecret,
        signingSecret: signingSecret,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Verify Telegram configuration
  Future<bool> verifyTelegramConfig({required String botToken}) async {
    try {
      _errorMessage = null;
      return await _assistantService.verifyTelegramConfig(botToken: botToken);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      _errorMessage = null;
      return await _assistantService.verifyMessengerConfig(
        botToken: botToken,
        pageId: pageId,
        appSecret: appSecret,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Publish bot to Slack
  Future<bool> publishSlackBot(
    String assistantId, {
    required String botToken,
    required String clientId,
    required String clientSecret,
    required String signingSecret,
  }) async {
    try {
      _errorMessage = null;
      return await _assistantService.publishSlackBot(
        assistantId: assistantId,
        botToken: botToken,
        clientId: clientId,
        clientSecret: clientSecret,
        signingSecret: signingSecret,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Publish bot to Telegram
  Future<bool> publishTelegramBot(String assistantId, String botToken) async {
    try {
      _errorMessage = null;
      return await _assistantService.publishTelegramBot(
        assistantId: assistantId,
        botToken: botToken,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Publish bot to Messenger
  Future<bool> publishMessengerBot(
    String assistantId, {
    required String botToken,
    required String pageId,
    required String appSecret,
  }) async {
    try {
      _errorMessage = null;
      return await _assistantService.publishMessengerBot(
        assistantId: assistantId,
        botToken: botToken,
        pageId: pageId,
        appSecret: appSecret,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Disconnect bot from platform
  Future<bool> disconnectBot(String assistantId, String platform) async {
    try {
      _errorMessage = null;
      return await _assistantService.disconnectBot(
        assistantId: assistantId,
        platform: platform,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

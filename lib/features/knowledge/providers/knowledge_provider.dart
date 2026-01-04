import 'package:flutter/material.dart';
import '../../../data/services/api_service.dart';
import '../models/knowledge_model.dart';
import '../services/knowledge_service.dart';

class KnowledgeProvider with ChangeNotifier {
  final KnowledgeService _knowledgeService;

  KnowledgeProvider(ApiService apiService)
    : _knowledgeService = KnowledgeService(apiService);

  List<Knowledge> _knowledges = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Pagination
  int _offset = 0;
  int _limit = 20;
  bool _hasNext = false;
  int _total = 0;

  // Getters
  List<Knowledge> get knowledges => _knowledges;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasNext => _hasNext;
  int get total => _total;

  /// Load knowledges with pagination
  Future<void> loadKnowledges({bool isLoadMore = false, String? query}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;

    if (!isLoadMore) {
      _offset = 0;
      _knowledges.clear();
    }

    notifyListeners();

    try {
      final response = await _knowledgeService.getKnowledges(
        limit: _limit,
        offset: _offset,
        query: query,
      );

      final List<dynamic> data = response['data'] as List<dynamic>;
      final Map<String, dynamic> meta =
          response['meta'] as Map<String, dynamic>;

      final newKnowledges = data
          .map((json) => Knowledge.fromJson(json as Map<String, dynamic>))
          .toList();

      if (isLoadMore) {
        _knowledges.addAll(newKnowledges);
      } else {
        _knowledges = newKnowledges;
      }

      _offset = _knowledges.length;
      _hasNext = meta['hasNext'] as bool? ?? false;
      _total = meta['total'] as int? ?? 0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load knowledges: ${e.toString()}';
      notifyListeners();
      print('Error in loadKnowledges: $e');
    }
  }

  /// Create a new knowledge base
  Future<bool> createKnowledge({
    required String knowledgeName,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newKnowledge = await _knowledgeService.createKnowledge(
        knowledgeName: knowledgeName,
        description: description,
      );

      // Add to beginning of list
      _knowledges.insert(0, newKnowledge);
      _total++;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create knowledge: ${e.toString()}';
      notifyListeners();
      print('Error in createKnowledge: $e');
      return false;
    }
  }

  /// Update a knowledge base
  Future<bool> updateKnowledge({
    required String id,
    required String knowledgeName,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedKnowledge = await _knowledgeService.updateKnowledge(
        id: id,
        knowledgeName: knowledgeName,
        description: description,
      );

      // Update in list
      final index = _knowledges.indexWhere((k) => k.id == id);
      if (index != -1) {
        _knowledges[index] = updatedKnowledge;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update knowledge: ${e.toString()}';
      notifyListeners();
      print('Error in updateKnowledge: $e');
      return false;
    }
  }

  /// Delete a knowledge base
  Future<bool> deleteKnowledge(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _knowledgeService.deleteKnowledge(id);

      // Remove from list
      _knowledges.removeWhere((k) => k.id == id);
      _total--;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to delete knowledge: ${e.toString()}';
      notifyListeners();
      print('Error in deleteKnowledge: $e');
      return false;
    }
  }

  /// Refresh knowledge list
  Future<void> refresh({String? query}) async {
    await loadKnowledges(isLoadMore: false, query: query);
  }

  /// Clear all data
  void clear() {
    _knowledges.clear();
    _offset = 0;
    _hasNext = false;
    _total = 0;
    _errorMessage = null;
    notifyListeners();
  }
}

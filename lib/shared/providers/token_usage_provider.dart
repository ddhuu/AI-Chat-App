import 'package:ai_chat_assistant/core/constants/api_constants.dart';
import 'package:ai_chat_assistant/data/models/user_model.dart';
import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TokenUsageProvider with ChangeNotifier {
  final ApiService _apiService;

  TokenUsageProvider(this._apiService);

  // State
  bool _isAuthenticated = false;
  int _tokenUsage = 0;
  int _totalTokens = 50; // Default for free plan
  UserModel? _currentUser;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  int get tokenUsage => _tokenUsage;
  int get totalTokens => _totalTokens;
  int get remainingTokens => _totalTokens - _tokenUsage;
  UserModel get currentUser =>
      _currentUser ??
      UserModel(
        id: '',
        email: '',
        username: 'Guest',
        plan: 'free',
        createdAt: DateTime.now(),
      );
  bool get isLoading => _isLoading;

  // Setters
  void setIsAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void setTokenUsage(int usage) {
    _tokenUsage = usage;
    notifyListeners();
  }

  void setTotalTokens(int total) {
    _totalTokens = total;
    notifyListeners();
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // API Calls
  Future<void> getUsage() async {
    try {
      final response = await _apiService.dio.get(
        ApiConstants.getUsage,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        // API returns: { availableTokens, totalTokens, unlimited, date }
        final availableTokens = response.data['availableTokens'] as int? ?? 0;
        final totalTokens = response.data['totalTokens'] as int? ?? 50;

        // Calculate used tokens
        _tokenUsage = totalTokens - availableTokens;
        _totalTokens = totalTokens;
        notifyListeners();
      }
    } catch (e) {
      print('Error getting usage: $e');
      // Set default values on error
      _tokenUsage = 0;
      _totalTokens = 50;
      notifyListeners();
    }
  }

  Future<void> getUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.dio.get(
        ApiConstants.getUser,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['user'];
        if (userData != null) {
          _currentUser = UserModel.fromJson(userData);
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      print('Error getting user: $e');
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    await _apiService.loadTokens();
    if (_apiService.token != null) {
      await getUser();
      await getUsage();
    }
  }

  void clearUserData() {
    _isAuthenticated = false;
    _tokenUsage = 0;
    _totalTokens = 50;
    _currentUser = null;
    notifyListeners();
  }
}

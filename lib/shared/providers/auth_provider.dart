import 'package:ai_chat_assistant/core/constants/api_constants.dart';
import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:ai_chat_assistant/shared/providers/token_usage_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final TokenUsageProvider _tokenUsageProvider;

  AuthProvider(this._apiService, this._tokenUsageProvider);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Register
  Future<String?> register(
    String email,
    String password,
    String username,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        ApiConstants.register,
        data: {"email": email, "password": password, "username": username},
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return "success";
      }

      _isLoading = false;
      notifyListeners();
      return "Registration failed";
    } catch (e) {
      _isLoading = false;
      if (e is DioException && e.response != null) {
        _errorMessage = e.response?.data["details"][0]["issue"];
        notifyListeners();
        return _errorMessage;
      }
      _errorMessage = "Network error. Please check your connection.";
      notifyListeners();
      return _errorMessage;
    }
  }

  // Login
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.dio.post(
        ApiConstants.login,
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        final accessToken = response.data['token']['accessToken'];
        final refreshToken = response.data['token']['refreshToken'];

        // Save tokens
        await _apiService.saveTokens(accessToken, refreshToken);

        // Load user info and token usage
        await _tokenUsageProvider.getUser();
        await _tokenUsageProvider.getUsage();

        // Set authenticated
        _tokenUsageProvider.setIsAuthenticated(true);

        _isLoading = false;
        notifyListeners();
        return "success";
      }

      _isLoading = false;
      notifyListeners();
      return "Login failed";
    } catch (e) {
      _isLoading = false;
      if (e is DioException && e.response != null) {
        _errorMessage = e.response?.data["details"][0]["issue"];
        notifyListeners();
        return _errorMessage;
      }
      _errorMessage = "Network error. Please check your connection.";
      notifyListeners();
      return _errorMessage;
    }
  }

  // Logout
  Future<String?> logout() async {
    _isLoading = true;
    notifyListeners();

    // Set unauthenticated immediately
    _tokenUsageProvider.setIsAuthenticated(false);

    try {
      final response = await _apiService.dio.get(
        ApiConstants.logout,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        // Clear tokens and user data
        await _apiService.clearTokens();
        _tokenUsageProvider.clearUserData();

        _isLoading = false;
        notifyListeners();
        return "success";
      }

      _isLoading = false;
      notifyListeners();
      return "Logout failed";
    } catch (e) {
      // Even if API call fails, clear local data
      await _apiService.clearTokens();
      _tokenUsageProvider.clearUserData();

      _isLoading = false;
      notifyListeners();
      return "success"; // Still return success since local data is cleared
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

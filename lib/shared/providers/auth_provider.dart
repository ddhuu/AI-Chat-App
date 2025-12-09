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
        '${ApiConstants.authBaseUrl}${ApiConstants.register}',
        data: {
          "email": email,
          "password": password,
          "verification_callback_url":
              "https://auth.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.jarvis.cx%252Fauth%252Foauth%252Fsuccess",
        },
        options: Options(
          headers: {
            'X-Stack-Access-Type': ApiConstants.stackAccessType,
            'X-Stack-Project-Id': ApiConstants.stackProjectId,
            'X-Stack-Publishable-Client-Key':
                ApiConstants.stackPublishableClientKey,
          },
        ),
      );

      // Stack Auth returns 200 for successful registration
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Stack Auth returns access_token and refresh_token directly
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

        if (accessToken != null && refreshToken != null) {
          // Save tokens
          await _apiService.saveTokens(accessToken, refreshToken);
        }

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
        // Handle Stack Auth error format
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map) {
          _errorMessage =
              errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              "Registration failed";
        } else {
          _errorMessage = "Registration failed";
        }
        notifyListeners();
        return _errorMessage;
      }
      _errorMessage = e.toString();
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
        '${ApiConstants.authBaseUrl}${ApiConstants.login}',
        data: {"email": email, "password": password},
        options: Options(
          headers: {
            'X-Stack-Access-Type': ApiConstants.stackAccessType,
            'X-Stack-Project-Id': ApiConstants.stackProjectId,
            'X-Stack-Publishable-Client-Key':
                ApiConstants.stackPublishableClientKey,
          },
        ),
      );

      if (response.statusCode == 200) {
        // Stack Auth returns access_token and refresh_token directly
        final accessToken = response.data['access_token'];
        final refreshToken = response.data['refresh_token'];

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
        // Handle Stack Auth error format
        final errorData = e.response?.data;
        if (errorData != null && errorData is Map) {
          _errorMessage =
              errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              "Login failed";
        } else {
          _errorMessage = "Login failed";
        }
        notifyListeners();
        return _errorMessage;
      }
      _errorMessage = e.toString();
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
      // Get refresh token for logout
      final refreshToken = _apiService.refreshToken;

      final response = await _apiService.dio.delete(
        '${ApiConstants.authBaseUrl}${ApiConstants.logout}',
        options: Options(
          headers: {
            'X-Stack-Access-Type': ApiConstants.stackAccessType,
            'X-Stack-Project-Id': ApiConstants.stackProjectId,
            'X-Stack-Publishable-Client-Key':
                ApiConstants.stackPublishableClientKey,
            if (refreshToken != null) 'X-Stack-Refresh-Token': refreshToken,
          },
          extra: {'requireToken': true},
        ),
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

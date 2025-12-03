import 'package:ai_chat_assistant/core/constants/api_constants.dart';
import 'package:ai_chat_assistant/core/utils/event_bus.dart';
import 'package:ai_chat_assistant/core/utils/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

class ApiService {
  final Dio _dio = Dio();
  static const _storage = FlutterSecureStorage();

  String? _accessToken;
  String? _refreshToken;

  String? get token => _accessToken;

  Future<void> init() async {
    await loadTokens();
  }

  ApiService() {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 20);
    _dio.options.receiveTimeout = const Duration(seconds: 20);

    // Logger Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppLogger.apiRequest(
            method: options.method,
            url: options.uri.toString(),
            headers: options.headers,
            data: options.data,
            queryParams: options.queryParameters,
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.apiResponse(
            statusCode: response.statusCode ?? 0,
            url: response.requestOptions.uri.toString(),
            data: response.data,
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.apiError(
            url: error.requestOptions.uri.toString(),
            statusCode: error.response?.statusCode,
            message: error.message,
            error: error.response?.data,
          );
          return handler.next(error);
        },
      ),
    );

    // Token Management Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requireToken = options.extra['requireToken'] ?? false;

          if (requireToken) {
            if (_accessToken == null || await isTokenExpired()) {
              await refreshAccessToken();
            }
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            AppLogger.error(
              'Network error',
              tag: 'ApiService',
              error: e.message,
            );
            Fluttertoast.showToast(
              msg: 'Please check your Internet connection.',
            );
          } else {
            AppLogger.error('API error', tag: 'ApiService', error: e.message);
          }
          return handler.next(e);
        },
      ),
    );

    loadTokens();
  }

  Future<void> loadTokens() async {
    _accessToken = await _storage.read(key: 'accessToken');
    _refreshToken = await _storage.read(key: 'refreshToken');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<bool> isTokenExpired() async {
    if (_accessToken == null) return true;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length != 3) throw Exception('Invalid token format');

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Refresh if less than 20 seconds remaining
      return exp - now <= 20;
    } catch (e) {
      return true;
    }
  }

  Future<void> refreshAccessToken() async {
    await loadTokens();
    try {
      final response = await _dio.get(
        ApiConstants.refreshToken,
        queryParameters: {'refreshToken': _refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['token']['accessToken'];
        _accessToken = newAccessToken;
        await saveTokens(newAccessToken, _refreshToken!);
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      _accessToken = null;
      _refreshToken = null;
      await _storage.deleteAll();
      eventBus.fire(TokenRefreshFailedEvent());
    }
  }

  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _storage.deleteAll();
  }

  Dio get dio => _dio;
}

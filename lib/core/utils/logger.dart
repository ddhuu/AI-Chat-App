import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static const String _name = 'AI_CHAT_APP';
  static bool _enabled = true;

  // Enable/disable logging (useful for production)
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  // Debug logs (blue)
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  // Info logs (green)
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  // Warning logs (yellow)
  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  // Error logs (red)
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  // API Request logs
  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) {
    if (!_enabled || kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.writeln('🚀 API REQUEST [$method]');
    buffer.writeln('   URL: $url');

    if (headers != null && headers.isNotEmpty) {
      buffer.writeln('   Headers: ${_formatJson(headers)}');
    }

    if (data != null) {
      buffer.writeln('   Body: ${_formatJson(data)}');
    }

    if (queryParams != null && queryParams.isNotEmpty) {
      buffer.writeln('   Query: ${_formatJson(queryParams)}');
    }

    debugPrint(buffer.toString());
  }

  // API Response logs
  static void apiResponse({
    required int statusCode,
    required String url,
    dynamic data,
    Duration? duration,
  }) {
    if (!_enabled || kReleaseMode) return;

    final buffer = StringBuffer();
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '⚠️';

    buffer.writeln('$emoji API RESPONSE [$statusCode]');
    buffer.writeln('   URL: $url');

    if (duration != null) {
      buffer.writeln('   Duration: ${duration.inMilliseconds}ms');
    }

    if (data != null) {
      buffer.writeln('   Data: ${_formatJson(data)}');
    }

    debugPrint(buffer.toString());
  }

  // API Error logs
  static void apiError({
    required String url,
    int? statusCode,
    String? message,
    dynamic error,
  }) {
    if (!_enabled || kReleaseMode) return;

    final buffer = StringBuffer();
    buffer.writeln('❌ API ERROR ${statusCode != null ? "[$statusCode]" : ""}');
    buffer.writeln('   URL: $url');

    if (message != null) {
      buffer.writeln('   Message: $message');
    }

    if (error != null) {
      buffer.writeln('   Error: ${_formatJson(error)}');
    }

    debugPrint(buffer.toString());
  }

  // Private log method
  static void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled || kReleaseMode) return;

    final emoji = _getEmoji(level);
    final levelName = level.name.toUpperCase();
    final tagStr = tag != null ? '[$tag]' : '';
    final timestamp = DateTime.now().toIso8601String();

    final buffer = StringBuffer();
    buffer.write('$emoji [$_name][$levelName]$tagStr ');
    buffer.write('$message');

    if (error != null) {
      buffer.write('\n   Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n   StackTrace: $stackTrace');
    }

    debugPrint(buffer.toString());
  }

  // Get emoji for log level
  static String _getEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
    }
  }

  // Format JSON for better readability
  static String _formatJson(dynamic data) {
    if (data == null) return 'null';

    try {
      if (data is Map || data is List) {
        return data.toString();
      }
      return data.toString();
    } catch (e) {
      return data.toString();
    }
  }
}

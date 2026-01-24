import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration using flutter_dotenv
class EnvConfig {
  // API URLs
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.jarvis.cx';

  static String get authBaseUrl =>
      dotenv.env['AUTH_BASE_URL'] ?? 'https://auth-api.jarvis.cx';

  static String get knowledgeBaseUrl =>
      dotenv.env['KNOWLEDGE_BASE_URL'] ?? 'https://knowledge-api.jarvis.cx';

  // Stack Auth
  static String get stackAccessType =>
      dotenv.env['STACK_ACCESS_TYPE'] ?? 'client';

  static String get stackProjectId => dotenv.env['STACK_PROJECT_ID'] ?? '';

  static String get stackPublishableClientKey =>
      dotenv.env['STACK_PUBLISHABLE_CLIENT_KEY'] ?? '';

  // Gemini AI
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // App Info
  static String get appName => dotenv.env['APP_NAME'] ?? 'Jarvis AI Assistant';

  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';

  // Validation
  static bool get isConfigured {
    return stackProjectId.isNotEmpty &&
        stackPublishableClientKey.isNotEmpty &&
        geminiApiKey.isNotEmpty;
  }

  // Initialize environment
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }
}

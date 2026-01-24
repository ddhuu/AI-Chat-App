import 'env_config.dart';

/// Gemini API Configuration
class GeminiConfig {
  // API Key from environment variables
  static String get apiKey => EnvConfig.geminiApiKey;

  // Model configurations
  static const String defaultTextModel = 'gemini-2.0-flash';
  static const String defaultVisionModel = 'gemini-2.0-flash';
  static const String proTextModel = 'gemini-2.0-pro';
  static const String proVisionModel = 'gemini-2.0-pro';

  // Safety settings
  static const bool enableSafetySettings = true;

  // Generation config
  static const double temperature = 0.7;
  static const int maxOutputTokens = 2048;
  static const double topP = 0.95;
  static const int topK = 40;
}

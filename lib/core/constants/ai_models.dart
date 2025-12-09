
class AiModels {
  
  static const String gpt4oMini = 'GPT-4o mini';
  static const String gpt4o = 'GPT-4o';
  static const String gemini15Flash = 'Gemini 1.5 Flash';
  static const String gemini15Pro = 'Gemini 1.5 Pro';
  static const String claude3Haiku = 'Claude 3 Haiku';
  static const String claude3Sonnet = 'Claude 3 Sonnet';

  static const Map<String, String> modelIds = {
    gpt4oMini: 'gpt-4o-mini',
    gpt4o: 'gpt-4o',
    gemini15Flash: 'gemini-1.5-flash-latest',
    gemini15Pro: 'gemini-1.5-pro-latest',
    claude3Haiku: 'claude-3-haiku-20240307',
    claude3Sonnet: 'claude-3-sonnet-20240229',
  };

  /// Get API model ID from display name
  static String getModelId(String displayName) {
    return modelIds[displayName] ?? modelIds[gpt4oMini]!;
  }

  /// Get display name from API model ID
  static String getDisplayName(String modelId) {
    return modelIds.entries
        .firstWhere(
          (entry) => entry.value == modelId,
          orElse: () => const MapEntry(gpt4oMini, 'gpt-4o-mini'),
        )
        .key;
  }

  /// Check if model is available
  static bool isValidModel(String displayName) {
    return modelIds.containsKey(displayName);
  }
}

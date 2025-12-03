class ApiConstants {
  // Base URL
  static const String baseUrl = "https://api.dev.jarvis.cx";
  
  // Auth Endpoints
  static const String login = "/api/v1/auth/sign-in";
  static const String register = "/api/v1/auth/sign-up";
  static const String logout = "/api/v1/auth/sign-out";
  static const String getUser = "/api/v1/auth/me";
  static const String refreshToken = "/api/v1/auth/refresh";
  
  // Token Usage
  static const String getUsage = "/api/v1/tokens/usage";
  
  
  // Prompt Endpoints
  static const String crudPrompts = "/api/v1/prompts";
}

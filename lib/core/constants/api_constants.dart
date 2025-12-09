class ApiConstants {
  // Base URLs
  static const String baseUrl = "https://api.jarvis.cx";
  static const String authBaseUrl = "https://auth-api.jarvis.cx";

  static const String stackAccessType = "client";
  static const String stackProjectId = "45a1e2fd-77ee-4872-9fb7-987b8c119633";
  static const String stackPublishableClientKey =
      "pck_7wjweasxxnfspvr20dvmyd9pjj0p9kp755bxxcm4ae1er";

  static const String login = "/api/v1/auth/password/sign-in";
  static const String register = "/api/v1/auth/password/sign-up";
  static const String logout = "/api/v1/auth/sessions/current";
  static const String getUser = "/api/v1/auth/me";
  static const String refreshToken = "/api/v1/auth/refresh";

  // Token Usage
  static const String getUsage = "/api/v1/tokens/usage";

  // Prompt Endpoints
  static const String crudPrompts = "/api/v1/prompts";

  // Chat Endpoints
  static const String getConversations = "/api/v1/ai-chat/conversations";
  static const String getConversationHistory =
      "/api/v1/ai-chat/conversations/{conversationId}/messages";
  static const String newThreadChat =
      "/api/v1/ai-chat"; // Create new conversation
  static const String sendMessage =
      "/api/v1/ai-chat/messages"; // Send to existing conversation
}

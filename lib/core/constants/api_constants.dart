class ApiConstants {
  // Base URLs
  static const String baseUrl = "https://api.jarvis.cx";
  static const String authBaseUrl = "https://auth-api.jarvis.cx";
  static const String knowledgeBaseUrl = "https://knowledge-api.jarvis.cx";

  // Stack Auth Headers
  static const String stackAccessType = "client";
  static const String stackProjectId = "45a1e2fd-77ee-4872-9fb7-987b8c119633";
  static const String stackPublishableClientKey =
      "pck_7wjweasxxnfspvr20dvmyd9pjj0p9kp755bxxcm4ae1er";

  // Auth Endpoints
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

  // Knowledge Base Endpoints
  static const String knowledge = "/kb-core/v1/knowledge";
  static const String knowledgeById = "/kb-core/v1/knowledge/{id}";
  static const String knowledgeDatasources =
      "/kb-core/v1/knowledge/{id}/datasources";
  static const String knowledgeDatasourceById =
      "/kb-core/v1/knowledge/{id}/datasources/{datasourceId}";

  // Knowledge Import Endpoints
  static const String importWeb = "/kb-core/v1/knowledge/{id}/web";
  static const String importConfluence =
      "/kb-core/v1/knowledge/{id}/confluence";
  static const String importSlack = "/kb-core/v1/knowledge/{id}/slack";
  static const String importGoogleDrive =
      "/kb-core/v1/knowledge/{id}/google-drive";
  static const String importLocalFile = "/kb-core/v1/knowledge/{id}/local-file";

  // AI Assistant (Bot) Endpoints
  static const String aiAssistant = "/kb-core/v1/ai-assistant";
  static const String aiAssistantById = "/kb-core/v1/ai-assistant/{id}";
  static const String assistantKnowledges =
      "/kb-core/v1/ai-assistant/{assistantId}/knowledges";
  static const String assistantKnowledgeById =
      "/kb-core/v1/ai-assistant/{assistantId}/knowledges/{knowledgeId}";

  // AI Chat Endpoints (for chatting with bot)
  static const String aiChatMessages = "/api/v1/ai-chat/messages";

  // AI Email Endpoints
  static const String aiEmailReply = "/api/v1/ai-email";
  static const String aiEmailSuggestIdeas = "/api/v1/ai-email/reply-ideas";
}

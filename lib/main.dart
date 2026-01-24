import 'package:ai_chat_assistant/core/utils/event_bus.dart';
import 'package:ai_chat_assistant/core/config/env_config.dart';
import 'package:ai_chat_assistant/data/services/api_service.dart';
import 'package:ai_chat_assistant/features/auth/pages/auth_page.dart';
import 'package:ai_chat_assistant/features/bot/providers/assistant_provider.dart';
import 'package:ai_chat_assistant/features/bot/services/assistant_service.dart';
import 'package:ai_chat_assistant/features/knowledge/providers/knowledge_provider.dart';
import 'package:ai_chat_assistant/features/prompt/providers/prompt_provider.dart';
import 'package:ai_chat_assistant/features/prompt/services/prompt_api_service.dart';
import 'package:ai_chat_assistant/features/ai_agent/providers/ai_agent_provider.dart';
import 'package:ai_chat_assistant/shared/providers/auth_provider.dart';
import 'package:ai_chat_assistant/shared/providers/token_usage_provider.dart';
import 'package:ai_chat_assistant/shared/widgets/ad_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/theme/AppTheme.dart';
import 'features/chat/chat_page.dart';
import 'features/knowledge/services/import_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize environment variables
  await EnvConfig.initialize();

  // Initialize ApiService
  final apiService = ApiService();
  await apiService.init();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi'),
      child: MyApp(apiService: apiService),
    ),
  );
}

class MyApp extends StatefulWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  // Static method to access the global state
  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Global state for user's Pro status
  bool _isProUser = false;

  void setIsProUser(bool value) {
    setState(() {
      _isProUser = value;
    });
  }

  bool get isProUser => _isProUser;

  @override
  void initState() {
    super.initState();

    // Listen for token refresh failures
    eventBus.on<TokenRefreshFailedEvent>().listen((event) {
      // Navigate to login page when token refresh fails
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide ApiService
        Provider<ApiService>.value(value: widget.apiService),

        Provider<ImportService>(
          create: (context) => ImportService(widget.apiService),
        ),

        // Provide TokenUsageProvider
        ChangeNotifierProvider<TokenUsageProvider>(
          create: (context) => TokenUsageProvider(widget.apiService),
        ),

        // Provide AuthProvider
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            widget.apiService,
            context.read<TokenUsageProvider>(),
          ),
        ),

        // Provide PromptProvider
        ChangeNotifierProvider<PromptProvider>(
          create: (context) =>
              PromptProvider(PromptApiService(widget.apiService)),
        ),

        // Provide KnowledgeProvider
        ChangeNotifierProvider<KnowledgeProvider>(
          create: (context) => KnowledgeProvider(widget.apiService),
        ),

        // Provide AssistantProvider
        ChangeNotifierProvider<AssistantProvider>(
          create: (context) =>
              AssistantProvider(AssistantService(widget.apiService)),
        ),

        // Provide AiAgentProvider
        ChangeNotifierProvider<AiAgentProvider>(
          create: (context) => AiAgentProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Jarvis AI Chat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: const SplashScreen(),
      ),
    );
  }
}

// Splash Screen to check authentication status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final tokenUsageProvider = context.read<TokenUsageProvider>();

    // Check if user has valid token
    await tokenUsageProvider.checkAuthStatus();

    // Navigate based on authentication status
    if (mounted) {
      if (tokenUsageProvider.isAuthenticated) {
        // User is authenticated, go to ChatPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => AdManager(
              isProUser: MyApp.of(context).isProUser,
              child: const ChatPage(),
            ),
          ),
        );
      } else {
        // User is not authenticated, go to AuthPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Jarvis AI Chat',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

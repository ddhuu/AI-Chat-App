import 'package:ai_chat_assistant/shared/widgets/ad_manager.dart';
import 'package:flutter/material.dart';
import 'core/theme/AppTheme.dart';
import 'features/chat/chat_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // Static method to access the global state
  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;

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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis AI Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Integrate AdManager as a wrapper for the entire application (home)
      // This allows AdManager to display Banner Ads outside the main content area
      home: AdManager(
        isProUser: _isProUser,
        child: const ChatPage(),
      ),
    );
  }
}
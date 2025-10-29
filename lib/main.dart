import 'package:flutter/material.dart';
import 'core/theme/AppTheme.dart';
import 'features/chat/ChatPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jarvis AI Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ChatPage(),
    );
  }
}

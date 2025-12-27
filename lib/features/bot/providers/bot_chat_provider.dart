import 'package:flutter/foundation.dart';
import '../models/assistant_model.dart';
import '../services/bot_chat_service.dart';

class BotChatProvider with ChangeNotifier {
  final BotChatService _chatService;
  final Assistant assistant;

  BotChatProvider({
    required BotChatService chatService,
    required this.assistant,
  }) : _chatService = chatService;

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _remainingUsage = 0;
  String _selectedModel = 'knowledge-base';

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get remainingUsage => _remainingUsage;
  String get selectedModel => _selectedModel;

  void setModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  void initializeChat() {
    _messages = [
      {
        'isUser': false,
        'message':
            'Hi! I\'m ${assistant.assistantName}. ${assistant.description ?? "How can I help you today?"}',
        'timestamp': DateTime.now(),
      },
    ];
    notifyListeners();
  }

  Future<void> sendMessage(String content, {List<String>? files}) async {
    if (content.trim().isEmpty) return;

    _errorMessage = null;

    // Add user message
    final userMessage = {
      'isUser': true,
      'message': content,
      'timestamp': DateTime.now(),
      if (files != null && files.isNotEmpty) 'files': files,
    };
    _messages.add(userMessage);
    notifyListeners();

    // Set loading
    _isLoading = true;
    notifyListeners();

    try {
      // Prepare conversation history (exclude the just-added user message)
      final conversationHistory = _messages.sublist(0, _messages.length - 1);

      // Send to API
      final response = await _chatService.sendMessage(
        content: content,
        assistantId: assistant.id,
        assistantName: assistant.assistantName,
        model: _selectedModel,
        conversationHistory: conversationHistory,
        files: files,
      );

      // Add bot response
      final botMessage = {
        'isUser': false,
        'message': response['message'] as String,
        'timestamp': DateTime.now(),
      };
      _messages.add(botMessage);

      // Update remaining usage
      _remainingUsage = response['remainingUsage'] as int;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;

      // Add error message to chat
      _messages.add({
        'isUser': false,
        'message': 'Sorry, I encountered an error: ${e.toString()}',
        'timestamp': DateTime.now(),
        'isError': true,
      });

      notifyListeners();
    }
  }

  void clearChat() {
    initializeChat();
  }

  void removeMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

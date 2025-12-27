import 'package:flutter/material.dart';
import '../services/email_service.dart';
import '../models/email_models.dart';
import '../../../shared/providers/token_usage_provider.dart';

class EmailProvider with ChangeNotifier {
  final EmailService _emailService;
  final TokenUsageProvider _tokenUsageProvider;

  EmailProvider(this._emailService, this._tokenUsageProvider);

  // State
  EmailReplyResponse? _emailResponse;
  SuggestIdeasResponse? _suggestIdeasResponse;
  bool _isLoading = false;
  bool _isLoadingSuggestions = false;
  String? _errorMessage;

  // Getters
  EmailReplyResponse? get emailResponse => _emailResponse;
  SuggestIdeasResponse? get suggestIdeasResponse => _suggestIdeasResponse;
  bool get isLoading => _isLoading;
  bool get isLoadingSuggestions => _isLoadingSuggestions;
  String? get errorMessage => _errorMessage;

  /// Reply to email
  Future<void> replyEmail({
    required String email,
    required String mainIdea,
    String? subject,
    String? sender,
    String? receiver,
    String? length,
    String? formality,
    String? tone,
    String? language,
    List<EmailContent>? context,
    String? assistantId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _emailService.replyEmail(
        email: email,
        mainIdea: mainIdea,
        subject: subject,
        sender: sender,
        receiver: receiver,
        length: length,
        formality: formality,
        tone: tone,
        language: language,
        context: context,
        assistantId: assistantId,
      );

      _emailResponse = response;

      // Update token usage if available
      if (response.remainingUsage != null) {
        await _tokenUsageProvider.getUsage();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Get suggest ideas
  Future<void> getSuggestIdeas({
    required String email,
    String? subject,
    String? sender,
    String? receiver,
    String? language,
    List<EmailContent>? context,
    String? assistantId,
  }) async {
    _isLoadingSuggestions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _emailService.getSuggestIdeas(
        email: email,
        subject: subject,
        sender: sender,
        receiver: receiver,
        language: language,
        context: context,
        assistantId: assistantId,
      );

      _suggestIdeasResponse = response;
      _isLoadingSuggestions = false;
      notifyListeners();
    } catch (e) {
      _isLoadingSuggestions = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear email response
  void clearEmailResponse() {
    _emailResponse = null;
    notifyListeners();
  }

  /// Clear suggestions
  void clearSuggestions() {
    _suggestIdeasResponse = null;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

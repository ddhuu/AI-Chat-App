import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/gemini_config.dart';

/// Gemini Service for direct API integration
class GeminiService {
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  GeminiService() {
    // Text-only model
    _model = GenerativeModel(
      model: GeminiConfig.defaultTextModel,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.temperature,
        maxOutputTokens: GeminiConfig.maxOutputTokens,
        topP: GeminiConfig.topP,
        topK: GeminiConfig.topK,
      ),
    );

    // Vision model (supports images)
    _visionModel = GenerativeModel(
      model: GeminiConfig.defaultVisionModel,
      apiKey: GeminiConfig.apiKey,
      generationConfig: GenerationConfig(
        temperature: GeminiConfig.temperature,
        maxOutputTokens: GeminiConfig.maxOutputTokens,
        topP: GeminiConfig.topP,
        topK: GeminiConfig.topK,
      ),
    );
  }

  /// Chat with text only
  Future<String> chatWithText({
    required String message,
    List<Content>? history,
  }) async {
    try {
      final chat = _model.startChat(history: history);
      final response = await chat.sendMessage(Content.text(message));
      return response.text ?? 'No response';
    } catch (e) {
      AppLogger.error('Error in Gemini text chat', error: e);
      rethrow;
    }
  }

  /// Chat with image (Vision)
  Future<String> chatWithImage({
    required String message,
    required String imagePath,
    List<Content>? history,
  }) async {
    try {
      // Read image file
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Determine MIME type
      String mimeType = 'image/jpeg';
      if (imagePath.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (imagePath.toLowerCase().endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (imagePath.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      // Create content with image and text
      final prompt = [
        Content.multi([
          TextPart(message.isEmpty ? 'What is in this image?' : message),
          DataPart(mimeType, imageBytes),
        ])
      ];

      final response = await _visionModel.generateContent(prompt);
      return response.text ?? 'No response';
    } catch (e) {
      AppLogger.error('Error in Gemini vision chat', error: e);
      rethrow;
    }
  }

  /// Chat with image URL
  Future<String> chatWithImageUrl({
    required String message,
    required String imageUrl,
    List<Content>? history,
  }) async {
    try {
      // For URL images, we need to download first
      // Or use Gemini's URL support if available
      final prompt = [
        Content.multi([
          TextPart(message.isEmpty ? 'What is in this image?' : message),
          // Note: Gemini may support direct URLs in newer versions
          TextPart('Image URL: $imageUrl'),
        ])
      ];

      final response = await _visionModel.generateContent(prompt);
      return response.text ?? 'No response';
    } catch (e) {
      AppLogger.error('Error in Gemini vision chat with URL', error: e);
      rethrow;
    }
  }

  /// Convert conversation history to Gemini format
  List<Content> convertHistoryToGeminiFormat(
    List<Map<String, dynamic>> history,
  ) {
    return history.map((msg) {
      final role = msg['role'] == 'user' ? 'user' : 'model';
      final content = msg['content']?.toString() ?? '';
      return Content(role, [TextPart(content)]);
    }).toList();
  }

  /// Stream chat with text (for real-time responses)
  Stream<String> streamChatWithText({
    required String message,
    List<Content>? history,
  }) async* {
    try {
      final chat = _model.startChat(history: history);
      final response = chat.sendMessageStream(Content.text(message));
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      AppLogger.error('Error in Gemini stream chat', error: e);
      rethrow;
    }
  }

  /// Stream chat with image
  Stream<String> streamChatWithImage({
    required String message,
    required String imagePath,
  }) async* {
    try {
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();

      String mimeType = 'image/jpeg';
      if (imagePath.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (imagePath.toLowerCase().endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (imagePath.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      }

      final prompt = [
        Content.multi([
          TextPart(message.isEmpty ? 'What is in this image?' : message),
          DataPart(mimeType, imageBytes),
        ])
      ];

      final response = _visionModel.generateContentStream(prompt);
      
      await for (final chunk in response) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e) {
      AppLogger.error('Error in Gemini stream vision chat', error: e);
      rethrow;
    }
  }
}

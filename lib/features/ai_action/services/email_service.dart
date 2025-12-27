import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../models/email_models.dart';

class EmailService {
  final ApiService _apiService;

  EmailService(this._apiService);

  /// Reply to email with AI
  Future<EmailReplyResponse> replyEmail({
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
    print('📧 [EmailService] Starting replyEmail...');
    print('📧 [EmailService] Email length: ${email.length}');
    print('📧 [EmailService] Main idea: $mainIdea');
    print(
      '📧 [EmailService] Style: length=$length, formality=$formality, tone=$tone',
    );

    try {
      final request = EmailReplyRequest(
        assistant: AssistantDto(id: assistantId ?? 'gpt-4o-mini'),
        email: email,
        mainIdea: mainIdea,
        metadata: AiEmailMetadata(
          context: context ?? [],
          subject: subject ?? '',
          sender: sender ?? '',
          receiver: receiver ?? '',
          style: EmailStyleDto(
            length: length,
            formality: formality,
            tone: tone,
          ),
          language: language ?? 'vietnamese',
        ),
      );

      print(
        '📧 [EmailService] Sending request to: ${ApiConstants.baseUrl}${ApiConstants.aiEmailReply}',
      );

      final requestJson = request.toJson();
      print('📧 [EmailService] Full request body:');
      print('   assistant: ${requestJson['assistant']}');
      print('   model: ${requestJson['model']}');
      print('   email length: ${requestJson['email']?.toString().length}');
      print('   action: ${requestJson['action']}');
      print('   mainIdea: ${requestJson['mainIdea']}');
      print('   metadata: ${requestJson['metadata']}');

      final response = await _apiService.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.aiEmailReply}',
        data: request.toJson(),
        options: Options(extra: {'requireToken': true}),
      );

      print(' [EmailService] Response status: ${response.statusCode}');
      print(' [EmailService] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return EmailReplyResponse.fromJson(response.data);
      }

      throw Exception('Failed to generate email reply');
    } catch (e) {
      print(' [EmailService] Error: $e');
      if (e is DioException) {
        print(' [EmailService] DioException type: ${e.type}');
        if (e.response != null) {
          print(' [EmailService] Response status: ${e.response?.statusCode}');
          print(' [EmailService] Response data: ${e.response?.data}');
          throw Exception(
            e.response?.data['message'] ?? 'Failed to generate email reply',
          );
        }
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Get suggest ideas for email reply
  Future<SuggestIdeasResponse> getSuggestIdeas({
    required String email,
    String? subject,
    String? sender,
    String? receiver,
    String? language,
    List<EmailContent>? context,
    String? assistantId,
  }) async {
    print(' [EmailService] Starting getSuggestIdeas...');
    print(' [EmailService] Email length: ${email.length}');

    try {
      final request = EmailSuggestIdeasRequest(
        // Don't send assistant and model for suggest ideas
        email: email,
        action: 'Suggest 3 ideas for this email',
        metadata: AiEmailReplyIdeasMetadata(
          context: context ?? [],
          subject: subject ?? '',
          sender: sender ?? '',
          receiver: receiver ?? '',
          language: language ?? 'vietnamese',
        ),
      );

      print(
        ' [EmailService] Sending request to: ${ApiConstants.baseUrl}${ApiConstants.aiEmailSuggestIdeas}',
      );

      final response = await _apiService.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.aiEmailSuggestIdeas}',
        data: request.toJson(),
        options: Options(extra: {'requireToken': true}),
      );

      print(' [EmailService] Response status: ${response.statusCode}');
      print(' [EmailService] Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SuggestIdeasResponse.fromJson(response.data);
      }

      throw Exception('Failed to get suggest ideas');
    } catch (e) {
      if (e is DioException) {
        if (e.response != null) {
          throw Exception(
            e.response?.data['message'] ?? 'Failed to get suggest ideas',
          );
        }
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

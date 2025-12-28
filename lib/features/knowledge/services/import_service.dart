import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../models/unit_model.dart';

class ImportService {
  final ApiService _apiService;

  ImportService(this._apiService);

  void _handleException(Object e) {
    if (e is DioException) {
      if (e.response != null) {
        print("Status code: ${e.response?.statusCode}");
        print("Response data: ${e.response?.data}");
      } else {
        print("Error message: ${e.message}");
      }
    }
  }

  /// Import from website
  Future<Unit?> importWebsite({
    required String knowledgeId,
    required String unitName,
    required String webUrl,
  }) async {
    try {
      final endpoint = ApiConstants.knowledgeDatasources.replaceAll('{id}', knowledgeId);

      final body = {
        "datasources": [
          {
            "name": unitName,
            "type": "web",
            "credentials": {
              "url": webUrl,
            }
          }
        ]
      };

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: body,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          if (response.data is List && response.data.isNotEmpty) {
            return Unit.fromJson(response.data[0]);
          } else if (response.data is Map<String, dynamic>) {
            if (response.data['datasources'] != null &&
                (response.data['datasources'] as List).isNotEmpty) {
              return Unit.fromJson(response.data['datasources'][0]);
            }
            return Unit.fromJson(response.data);
          }
        } catch (parseError) {
          return null;
        }
      }
    } catch (e) {
      _handleException(e);
      print("Error when import from web: $e");
      rethrow;
    }
    return null;
  }

  /// Import from Slack
  Future<Unit?> importSlack({
    required String knowledgeId,
    required String unitName,
    required String slackWorkspace,
    required String slackBotToken,
  }) async {
    try {
      final endpoint = ApiConstants.importSlack.replaceAll('{id}', knowledgeId);
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: {
          'unitName': unitName,
          'slackWorkspace': slackWorkspace,
          'slackBotToken': slackBotToken,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Unit.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _handleException(e);
      print("Error when import from Slack: $e");
      rethrow;
    }
    return null;
  }

  /// Import from Confluence
  Future<Unit?> importConfluence({
    required String knowledgeId,
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
  }) async {
    try {
      final endpoint = ApiConstants.importConfluence.replaceAll(
        '{id}',
        knowledgeId,
      );
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: {
          'unitName': unitName,
          'wikiPageUrl': wikiPageUrl,
          'confluenceUsername': confluenceUsername,
          'confluenceAccessToken': confluenceAccessToken,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Unit.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _handleException(e);
      print("Error when import from Confluence: $e");
      rethrow;
    }
    return null;
  }

  /// Import from Google Drive
  Future<Unit?> importGoogleDrive({
    required String knowledgeId,
    required String unitName,
    required String driveFileId,
    required String accessToken,
  }) async {
    try {
      final endpoint = ApiConstants.importGoogleDrive.replaceAll(
        '{id}',
        knowledgeId,
      );
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: {
          'unitName': unitName,
          'driveFileId': driveFileId,
          'accessToken': accessToken,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Unit.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _handleException(e);
      print("Error when import from Google Drive: $e");
      rethrow;
    }
    return null;
  }

  /// Get content type based on file extension
  MediaType _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
      case 'docx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.wordprocessingml.document',
        );
      case 'xls':
      case 'xlsx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
      case 'ppt':
      case 'pptx':
        return MediaType(
          'application',
          'vnd.openxmlformats-officedocument.presentationml.presentation',
        );
      case 'txt':
        return MediaType('text', 'plain');
      case 'csv':
        return MediaType('text', 'csv');
      case 'json':
        return MediaType('application', 'json');
      case 'xml':
        return MediaType('application', 'xml');
      case 'md':
        return MediaType('text', 'markdown');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Import local file
  Future<Unit?> importLocalFile({
    required String knowledgeId,
    required PlatformFile file,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      MultipartFile multipartFile;

      if (!kIsWeb) {
        // Handle mobile or desktop
        if (file.path == null) {
          throw Exception('File path is null');
        }
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
          contentType: _getContentType(file.name),
        );
      } else {
        // Handle web
        if (file.bytes == null) {
          throw Exception('File bytes are null');
        }
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
          contentType: _getContentType(file.name),
        );
      }

      // Create form data
      final formData = FormData.fromMap({'file': multipartFile});

      // Call API
      final endpoint = ApiConstants.importLocalFile.replaceAll(
        '{id}',
        knowledgeId,
      );
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          extra: {'requireToken': true},
        ),
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Unit.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _handleException(e);
      print("Error when import local file: $e");
      rethrow;
    }
    return null;
  }

  /// Import multiple local files
  Future<List<Unit>> importMultipleFiles({
    required String knowledgeId,
    required List<PlatformFile> files,
    Function(int fileIndex, int sent, int total)? onProgress,
  }) async {
    final List<Unit> importedUnits = [];

    for (int i = 0; i < files.length; i++) {
      try {
        final unit = await importLocalFile(
          knowledgeId: knowledgeId,
          file: files[i],
          onProgress: (sent, total) {
            onProgress?.call(i, sent, total);
          },
        );

        if (unit != null) {
          importedUnits.add(unit);
        }
      } catch (e) {
        print("Error importing file ${files[i].name}: $e");
        // Continue with next file
      }
    }

    return importedUnits;
  }
}

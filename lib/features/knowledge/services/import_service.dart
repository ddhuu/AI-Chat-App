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

  Future<Unit?> importSlack({
    required String knowledgeId,
    required String unitName,
    required String slackBotToken,
  }) async {
    try {
      final endpoint = ApiConstants.knowledgeDatasources.replaceAll('{id}', knowledgeId);

      final body = {
        "datasources": [
          {
            "type": "slack",
            "name": unitName,
            "credentials": {
              "token": slackBotToken
            },
            "autoReindexEnabled": true,
            "autoReindexIntervalHours": 12
          }
        ]
      };

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: body,
        options: Options(
          extra: {'requireToken': true},
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['datasources'] != null && (data['datasources'] as List).isNotEmpty) {
            return Unit.fromJson(data['datasources'][0]);
          }
          return Unit.fromJson(data);
        }
      }
    } catch (e) {
      _handleException(e);
      print("Error body sent: $unitName - Token length: ${slackBotToken.length}");
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
    bool autoReindexEnabled = false,
  }) async {
    try {
      final endpoint = ApiConstants.knowledgeDatasources.replaceAll('{id}', knowledgeId);

      final body = {
        "datasources": [
          {
            "type": "confluence",
            "name": unitName,
            "credentials": {
              "url": wikiPageUrl,
              "username": confluenceUsername,
              "token": confluenceAccessToken
            },
            "autoReindexEnabled": autoReindexEnabled
          }
        ]
      };

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: body,
        options: Options(
          extra: {'requireToken': true},
          contentType: Headers.jsonContentType,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Parse response trả về
        if (data is Map<String, dynamic>) {
          if (data['datasources'] != null && (data['datasources'] as List).isNotEmpty) {
            return Unit.fromJson(data['datasources'][0]);
          }
          return Unit.fromJson(data);
        }
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
      case 'pdf': return MediaType('application', 'pdf');
      case 'doc':
      case 'docx': return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
      case 'xlsx': return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'jpg':
      case 'jpeg': return MediaType('image', 'jpeg');
      case 'png': return MediaType('image', 'png');
      case 'txt': return MediaType('text', 'plain');
      case 'csv': return MediaType('text', 'csv');
      case 'json': return MediaType('application', 'json');
      case 'md': return MediaType('text', 'markdown');
      default: return MediaType('application', 'octet-stream');
    }
  }

  // --- STEP 1: Upload File ---
  Future<String?> _uploadFileStep1({
    required PlatformFile file,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      MultipartFile multipartFile;

      if (kIsWeb) {
        if (file.bytes == null) throw Exception('File bytes are null');
        multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
          contentType: _getContentType(file.name),
        );
      } else {
        if (file.path == null) throw Exception('File path is null');
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      }

      // FIX 1: Use 'file' (singular). The 400 error proved 'files' was wrong.
      final formData = FormData.fromMap({
        'files': [multipartFile],
      });

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}${ApiConstants.uploadFile}',
        data: formData,
        options: Options(
          // FIX 2: Do NOT set content-type here.
          // Dio/Browser will automatically set 'multipart/form-data; boundary=...'
          extra: {'requireToken': true},
        ),
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Parse logic matching your success response: {"files": [{"id": "..."}]}
        if (data is Map<String, dynamic> && data['files'] != null) {
          final filesList = data['files'];
          if (filesList is List && filesList.isNotEmpty) {
            return filesList[0]['id'];
          }
        }
      }
      return null;
    } catch (e) {
      print("Error uploading file (Step 1): $e");
      rethrow;
    }
  }

  Future<Unit?> _createDatasourceStep2({
    required String knowledgeId,
    required String fileName,
    required String fileId,
  }) async {
    try {
      final endpoint =
      ApiConstants.knowledgeDatasources.replaceAll('{id}', knowledgeId);

      final body = {
        "datasources": [
          {
            "type": "local_file",
            "name": fileName,
            "credentials": {
              "file": fileId,
            }
          }
        ]
      };

      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: body,
        options: Options(
          // ✅ KHÔNG set Content-Type
          extra: {'requireToken': true},
        ),
      );



      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['datasources'] != null &&
              (data['datasources'] as List).isNotEmpty) {
            return Unit.fromJson(data['datasources'][0]);
          }
          return Unit.fromJson(data);
        } else if (data is List && data.isNotEmpty) {
          return Unit.fromJson(data[0]);
        }
      }
      return null;
    } catch (e) {
      print("Error linking datasource (Step 2): $e");
      rethrow;
    }
  }

  // --- Main Function ---
  Future<Unit?> importLocalFile({
    required String knowledgeId,
    required PlatformFile file,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      // 1. Upload
      final fileId = await _uploadFileStep1(
        file: file,
        onProgress: onProgress,
      );

      if (fileId == null) {
        throw Exception("Failed to upload file: No ID returned from server");
      }

      // 2. Link Datasource
      return await _createDatasourceStep2(
        knowledgeId: knowledgeId,
        fileName: file.name,
        fileId: fileId,
      );

    } catch (e) {
      _handleException(e);
      rethrow;
    }
  }

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
        if (unit != null) importedUnits.add(unit);
      } catch (e) {
        print("Failed to import ${files[i].name}: $e");
      }
    }
    return importedUnits;
  }
}

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/knowledge_model.dart';
import '../models/unit_model.dart';
import '../services/import_service.dart';

class ImportProvider with ChangeNotifier {
  final ImportService _importService;
  final Knowledge knowledge;

  ImportProvider({
    required ImportService importService,
    required this.knowledge,
  }) : _importService = importService;

  bool _isImporting = false;
  String? _errorMessage;
  double _uploadProgress = 0.0;
  int _currentFileIndex = 0;
  int _totalFiles = 0;

  bool get isImporting => _isImporting;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;
  int get currentFileIndex => _currentFileIndex;
  int get totalFiles => _totalFiles;

  /// Import from website
  Future<Unit?> importWebsite({
    required String unitName,
    required String webUrl,
  }) async {
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final unit = await _importService.importWebsite(
        knowledgeId: knowledge.id,
        unitName: unitName,
        webUrl: webUrl,
      );

      _isImporting = false;
      notifyListeners();
      return unit;
    } catch (e) {
      _errorMessage = e.toString();
      _isImporting = false;
      notifyListeners();
      return null;
    }
  }

  /// Import from Slack
  Future<Unit?> importSlack({
    required String unitName,
    required String slackBotToken,
  }) async {
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final unit = await _importService.importSlack(
        knowledgeId: knowledge.id,
        unitName: unitName,
        slackBotToken: slackBotToken,
      );

      _isImporting = false;
      notifyListeners();
      return unit;
    } catch (e) {
      if (e.toString().contains("500")) {
        _errorMessage = "Server error. Please check your Slack Token permissions.";
      } else {
        _errorMessage = e.toString();
      }
      _isImporting = false;
      notifyListeners();
      return null;
    }
  }

  /// Import from Confluence
  Future<Unit?> importConfluence({
    required String unitName,
    required String wikiPageUrl,
    required String confluenceUsername,
    required String confluenceAccessToken,
    required bool autoReindexEnabled,
  }) async {
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final unit = await _importService.importConfluence(
        knowledgeId: knowledge.id,
        unitName: unitName,
        wikiPageUrl: wikiPageUrl,
        confluenceUsername: confluenceUsername,
        confluenceAccessToken: confluenceAccessToken,
        autoReindexEnabled: autoReindexEnabled,
      );

      _isImporting = false;
      notifyListeners();
      return unit;
    } catch (e) {
      final errorString = e.toString();

      if (errorString.contains("500")) {
        _errorMessage = "Connection failed. Please check your Confluence URL, Username (Email), and API Token.";
      } else if (errorString.contains("401") || errorString.contains("403")) {
        _errorMessage = "Unauthorized. Please check your API Token and permissions.";
      } else {
        _errorMessage = "Import failed: ${errorString.replaceAll('Exception:', '').trim()}";
      }

      _isImporting = false;
      notifyListeners();
      return null;
    }
  }

  /// Import from Google Drive
  Future<Unit?> importGoogleDrive({
    required String unitName,
    required String driveFileId,
    required String accessToken,
  }) async {
    _isImporting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final unit = await _importService.importGoogleDrive(
        knowledgeId: knowledge.id,
        unitName: unitName,
        driveFileId: driveFileId,
        accessToken: accessToken,
      );

      _isImporting = false;
      notifyListeners();
      return unit;
    } catch (e) {
      _errorMessage = e.toString();
      _isImporting = false;
      notifyListeners();
      return null;
    }
  }

  /// Reset state
  void reset() {
    _isImporting = false;
    _errorMessage = null;
    _uploadProgress = 0.0;
    _currentFileIndex = 0;
    _totalFiles = 0;
    notifyListeners();
  }

  Future<List<Unit>?> importFiles({
    required List<PlatformFile> files,
  }) async {
    _isImporting = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    _currentFileIndex = 0;
    _totalFiles = files.length;
    notifyListeners();

    try {
      final units = await _importService.importMultipleFiles(
        knowledgeId: knowledge.id,
        files: files,
        onProgress: (fileIndex, sent, total) {
          _currentFileIndex = fileIndex + 1;
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      _isImporting = false;
      notifyListeners();
      return units;
    } catch (e) {
      _errorMessage = e.toString();
      _isImporting = false;
      notifyListeners();
      return null;
    }
  }
}

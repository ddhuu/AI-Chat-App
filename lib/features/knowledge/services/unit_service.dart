import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/services/api_service.dart';
import '../models/unit_model.dart';

class UnitService {
  final ApiService _apiService;

  UnitService(this._apiService);

  /// Get units (datasources) for a knowledge base
  Future<UnitsResponse> getUnits({
    required String knowledgeId,
    int offset = 0,
    int limit = 10,
    String? query,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'offset': offset,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final endpoint = ApiConstants.knowledgeDatasources.replaceAll(
        '{id}',
        knowledgeId,
      );
      final response = await _apiService.dio.get(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        queryParameters: queryParams,
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200) {
        return UnitsResponse.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to load units');
    } catch (e) {
      throw Exception('Failed to load units: $e');
    }
  }

  /// Create a new unit (datasource)
  Future<Unit> createUnit({
    required String knowledgeId,
    required String name,
    required String type,
    String? description,
  }) async {
    try {
      final endpoint = ApiConstants.knowledgeDatasources.replaceAll(
        '{id}',
        knowledgeId,
      );
      final response = await _apiService.dio.post(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        data: {
          'name': name,
          'type': type,
          if (description != null) 'description': description,
        },
        options: Options(extra: {'requireToken': true}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Unit.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to create unit');
    } catch (e) {
      throw Exception('Failed to create unit: $e');
    }
  }

  /// Delete a unit (datasource)
  Future<void> deleteUnit({
    required String knowledgeId,
    required String datasourceId,
  }) async {
    try {
      final endpoint = ApiConstants.knowledgeDatasourceById
          .replaceAll('{id}', knowledgeId)
          .replaceAll('{datasourceId}', datasourceId);

      await _apiService.dio.delete(
        '${ApiConstants.knowledgeBaseUrl}$endpoint',
        options: Options(extra: {'requireToken': true}),
      );
    } catch (e) {
      throw Exception('Failed to delete unit: $e');
    }
  }
}

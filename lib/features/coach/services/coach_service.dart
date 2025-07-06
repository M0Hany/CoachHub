import 'package:dio/dio.dart';
import '../../../core/network/http_client.dart';
import '../../../core/config/api_config.dart';
import '../data/models/coach_model.dart';

class CoachService {
  final HttpClient _httpClient;

  CoachService({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  Future<CoachPaginatedResponse> getCoaches({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await _httpClient.get(
        '/api/coach',
        queryParameters: queryParams,
      );

      return CoachPaginatedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch coaches');
    }
  }

  Future<CoachPaginatedResponse> getRecommendedCoaches({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpClient.get(
        '/api/recommendation/coaches',
        queryParameters: queryParams,
      );

      return CoachPaginatedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to fetch recommended coaches');
    }
  }
} 
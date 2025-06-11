import 'package:dio/dio.dart';
import 'http_client.dart';

/// Base class for all API services
abstract class BaseApiService {
  final HttpClient _client = HttpClient();

  /// Protected getter for the HTTP client
  HttpClient get client => _client;

  /// Helper method to handle API responses
  T handleResponse<T>(Response<dynamic> response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as T;
    } else {
      throw Exception('Failed to process request');
    }
  }

  /// Helper method to create FormData from Map
  FormData createFormData(Map<String, dynamic> data) {
    return FormData.fromMap(data);
  }

  /// Helper method to create multipart file
  Future<MultipartFile> createMultipartFile(String filePath, {String? filename}) async {
    return await MultipartFile.fromFile(filePath, filename: filename);
  }

  /// Helper method to create CancelToken
  CancelToken createCancelToken() {
    return CancelToken();
  }
} 
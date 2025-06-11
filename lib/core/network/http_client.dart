import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../errors/network_error.dart';
import '../config/api_config.dart';
import 'dart:developer' as developer;

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  final Dio _dio;
  final TokenService _tokenService;

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal()
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          validateStatus: (status) => true,
        )),
        _tokenService = TokenService() {
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => developer.log(object.toString(), name: 'HttpClient'),
    ));
  }

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
    );
    }

  Future<Response<T>> download<T>(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: options,
      );
      return response as Response<T>;
    } catch (e) {
      rethrow;
    }
  }
} 
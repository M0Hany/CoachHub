import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final FlutterSecureStorage _storage;
  final Dio _dio;

  TokenService()
      : _storage = const FlutterSecureStorage(),
        _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  // Store tokens
  Future<void> saveTokens({
    String? token,
    String? refreshToken,
  }) async {
    try {
      if (token != null) {
        await _storage.write(key: _tokenKey, value: token);
        developer.log('Token saved: ${token.substring(0, 10)}...', name: 'TokenService');
      }
      if (refreshToken != null) {
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        developer.log('Refresh token saved', name: 'TokenService');
      }
    } catch (e) {
      developer.log('Error saving tokens: $e', name: 'TokenService', error: e);
      rethrow;
    }
  }

  // Get access token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        developer.log('Token retrieved: ${token.substring(0, 10)}...', name: 'TokenService');
      } else {
        developer.log('No token found in storage', name: 'TokenService');
      }
      return token;
    } catch (e) {
      developer.log('Error retrieving token: $e', name: 'TokenService', error: e);
      return null;
    }
  }

  // Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      developer.log('Refresh token ${refreshToken != null ? 'found' : 'not found'} in storage', name: 'TokenService');
      return refreshToken;
    } catch (e) {
      developer.log('Error retrieving refresh token: $e', name: 'TokenService', error: e);
      return null;
    }
  }

  // Clear tokens
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _refreshTokenKey),
      ]);
      developer.log('All tokens cleared from storage', name: 'TokenService');
    } catch (e) {
      developer.log('Error clearing tokens: $e', name: 'TokenService', error: e);
      rethrow;
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.data?['success'] == true) {
        final newToken = response.data?['data']['token'] as String?;
        final newRefreshToken = response.data?['data']['refresh_token'] as String?;
        
        if (newToken != null && newRefreshToken != null) {
          await saveTokens(
            token: newToken,
            refreshToken: newRefreshToken,
          );
          return true;
        }
      }
      
      return false;
    } catch (e) {
      await clearTokens();
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      final isAuth = token != null;
      developer.log('Authentication check: ${isAuth ? 'authenticated' : 'not authenticated'}', name: 'TokenService');
      return isAuth;
    } catch (e) {
      developer.log('Error checking authentication: $e', name: 'TokenService', error: e);
      return false;
    }
  }
} 
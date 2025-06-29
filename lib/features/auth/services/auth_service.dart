import 'dart:io';
import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../../core/network/http_client.dart';
import '../../../core/services/token_service.dart';
import '../../../core/config/api_config.dart';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;

class AuthService {
  final HttpClient _httpClient;
  final TokenService _tokenService;

  AuthService(this._httpClient, this._tokenService);

  // Register a new user
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/api/auth/register',
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final authResponse = AuthResponseModel.fromJson(response.data!);
    
    if (authResponse.success && 
        authResponse.data?.token != null && 
        authResponse.data?.refreshToken != null) {
      await _tokenService.saveTokens(
        token: authResponse.data!.token!,
        refreshToken: authResponse.data!.refreshToken!,
      );
    }

    return authResponse;
  }

  // Verify OTP
  Future<AuthResponseModel> verifyOtp(String otp) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/api/auth/verify',
      data: {'otp': otp},
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
      ),
    );

    final authResponse = AuthResponseModel.fromJson(response.data!);
    
    // Save the temporary token for profile completion
    if (authResponse.success && authResponse.data?.token != null) {
      developer.log('Saving temporary token after OTP verification', name: 'AuthService');
      await _tokenService.saveTokens(
        token: authResponse.data!.token!,
        refreshToken: null, // No refresh token at this stage
      );
    } else {
      developer.log('No token received from OTP verification', name: 'AuthService');
    }

    return authResponse;
  }

  // Complete profile information
  Future<AuthResponseModel> completeProfile({
    required String fullName,
    required Gender gender,
    required UserType type,
    File? image,
    String bio = '',  // Default empty string
    List<String>? experienceIds,
    List<String>? goalIds,
    int? age,
    double? height,
    double? weight,
    double? bodyFat,
    double? bodyMuscle,
  }) async {
    final formData = FormData.fromMap({
      'full_name': fullName,
      'gender': gender.toString().split('.').last.toLowerCase(),
      'type': type.toString().split('.').last.toLowerCase(),
      'bio': bio,
      if (image != null)
        'image': await MultipartFile.fromFile(
          image.path,
          filename: path.basename(image.path),
        ),
      if (experienceIds != null) 'experience_IDs': experienceIds,
      if (goalIds != null) 'goals_IDs': goalIds,
      if (age != null) 'age': age,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (bodyFat != null) 'body_fat': bodyFat,
      if (bodyMuscle != null) 'body_muscle': bodyMuscle,
    });

    final response = await _httpClient.post<Map<String, dynamic>>(
      '/api/auth/complete-info',
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  // Sign in
  Future<AuthResponseModel> signIn({
    required String username,
    required String password,
  }) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/api/auth/sign-in',
      data: {
        'username': username,
        'password': password,
      },
    );

    final authResponse = AuthResponseModel.fromJson(response.data!);
    
    if (authResponse.success && 
        authResponse.data?.token != null && 
        authResponse.data?.refreshToken != null) {
      await _tokenService.saveTokens(
        token: authResponse.data!.token!,
        refreshToken: authResponse.data!.refreshToken!,
      );
    }

    return authResponse;
  }

  // Request password reset
  Future<AuthResponseModel> requestPasswordReset(String email) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/api/auth/request-password-reset',
      data: {'email': email},
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  // Reset password
  Future<AuthResponseModel> resetPassword(String password) async {
    final response = await _httpClient.post<Map<String, dynamic>>(
      '/api/auth/reset-password',
      data: {'password': password},
    );

    return AuthResponseModel.fromJson(response.data!);
  }

  // Sign out
  Future<void> signOut() async {
    await _tokenService.clearTokens();
  }

  // Check authentication status
  Future<bool> isAuthenticated() async {
    return _tokenService.isAuthenticated();
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _tokenService.saveTokens(
      token: token,
      refreshToken: null, // No refresh token at this stage
    );
  }

  // Fetch user profile
  Future<AuthResponseModel> fetchProfile() async {
    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/profile/',
      );

      if (response.data == null) {
        return AuthResponseModel(
          success: false,
          error: 'No response data',
        );
      }

      // Check if the response has a status field
      final isSuccess = response.data!['status'] == 'success';
      
      if (!isSuccess) {
        return AuthResponseModel(
          success: false,
          error: response.data!['message'] ?? 'Failed to fetch profile',
        );
      }

      // Extract user data from the profile response
      final userData = response.data!['data']['profile'];
      if (userData == null) {
        return AuthResponseModel(
          success: false,
          error: 'No profile data found',
        );
      }

      try {
        final user = UserModel.fromJson(userData);
        return AuthResponseModel(
          success: true,
          data: AuthData(user: user),
        );
      } catch (e) {
        developer.log('Error parsing user data: $e', name: 'AuthService', error: e);
        return AuthResponseModel(
          success: false,
          error: 'Error parsing profile data: $e',
        );
      }
    } catch (e) {
      developer.log('Error fetching profile: $e', name: 'AuthService', error: e);
      return AuthResponseModel(
        success: false,
        error: e.toString(),
      );
    }
  }
} 
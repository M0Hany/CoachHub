import 'dart:io';
import 'package:dio/dio.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../../../core/network/http_client.dart';
import '../../../core/services/token_service.dart';
import '../../../core/services/fcm_service.dart';
import '../../../core/config/api_config.dart';
import 'dart:developer' as developer;
import 'package:path/path.dart' as path;

class AuthService {
  final HttpClient _httpClient;
  final TokenService _tokenService;
  final FCMService _fcmService = FCMService();

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
      
      // Send FCM token to backend after successful registration
      await _fcmService.sendTokenToBackend();
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
      
      // Send FCM token to backend after successful OTP verification
      await _fcmService.sendTokenToBackend();
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
    String? hypertension,
    String? diabetes,
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
      if (hypertension != null) 'hypertension': hypertension,
      if (diabetes != null) 'diabetes': diabetes,
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

    final authResponse = AuthResponseModel.fromJson(response.data!);
    
    // Save the new token if profile completion is successful
    if (authResponse.success && authResponse.data?.token != null) {
      developer.log('Saving new token after profile completion', name: 'AuthService');
      await _tokenService.saveTokens(
        token: authResponse.data!.token!,
        refreshToken: null, // No refresh token at this stage
      );
      
      // Send FCM token to backend after successful profile completion
      await _fcmService.sendTokenToBackend();
    } else {
      developer.log('No token received from profile completion', name: 'AuthService');
    }

    return authResponse;
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
    
    developer.log('Sign-in response: success=${authResponse.success}, hasToken=${authResponse.data?.token != null}, hasRefreshToken=${authResponse.data?.refreshToken != null}', name: 'AuthService');
    developer.log('Sign-in raw response: ${response.data}', name: 'AuthService');
    developer.log('Sign-in parsed data: ${authResponse.data?.toJson()}', name: 'AuthService');
    
    if (authResponse.success && 
        authResponse.data?.token != null && 
        authResponse.data?.refreshToken != null) {
      developer.log('Saving tokens and sending FCM token to backend', name: 'AuthService');
      await _tokenService.saveTokens(
        token: authResponse.data!.token!,
        refreshToken: authResponse.data!.refreshToken!,
      );
      
      // Send FCM token to backend after successful sign in
      developer.log('Calling FCM service to send token to backend', name: 'AuthService');
      await _fcmService.sendTokenToBackend();
      developer.log('FCM token sending completed', name: 'AuthService');
    } else {
      developer.log('Sign-in not successful or missing tokens, skipping FCM token send', name: 'AuthService');
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
    try {
      // Clear all tokens
      await _tokenService.clearTokens();
      
      // Clear any cached data if needed
      // TODO: Clear any other cached data here
      
      developer.log('Successfully signed out and cleared tokens', name: 'AuthService');
    } catch (e) {
      developer.log('Error during sign out: $e', name: 'AuthService', error: e);
      rethrow;
    }
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
        // Create a new map with the profile data and add the trainee data at the root level
        final Map<String, dynamic> userDataWithTraineeData = {
          ...userData,
          'trainee_data': {
            'goals': userData['goals'] ?? [],
            'weight': userData['weight'],
            'height': userData['height'],
            'body_fat': userData['body_fat'],
            'body_muscle': userData['body_muscle'],
            'age': userData['age'],
          },
        };

        final user = UserModel.fromJson(userDataWithTraineeData);
        return AuthResponseModel(
          success: true,
          data: AuthData(
            user: user,
            token: await _tokenService.getToken(), // Preserve the current token
          ),
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
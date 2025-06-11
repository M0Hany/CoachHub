import 'user_model.dart';

class AuthResponseModel {
  final bool success;
  final String? message;
  final AuthData? data;
  final String? error;

  AuthResponseModel({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    bool isSuccess = false;
    if (json['success'] is bool) {
      isSuccess = json['success'] as bool;
    } else if (json['status'] is String) {
      isSuccess = (json['status'] as String) == 'success';
    }
    
    return AuthResponseModel(
      success: isSuccess,
      message: json['message'] as String?,
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      error: json['error'] as String?,
    );
  }
}

class AuthData {
  final String? token;
  final String? refreshToken;
  final UserModel? user;
  final bool requiresOtp;
  final bool requiresProfileCompletion;

  AuthData({
    this.token,
    this.refreshToken,
    this.user,
    this.requiresOtp = false,
    this.requiresProfileCompletion = false,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      requiresOtp: json['requires_otp'] as bool? ?? true, // Default to true for registration
      requiresProfileCompletion: json['requires_profile_completion'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'token': token,
      if (refreshToken != null) 'refresh_token': refreshToken,
      if (user != null) 'user': user!.toJson(),
      'requires_otp': requiresOtp,
      'requires_profile_completion': requiresProfileCompletion,
    };
  }
} 
import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../models/auth_response_model.dart';
import '../../services/auth_service.dart';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:coachhub/core/models/models.dart';
import 'package:coachhub/features/auth/models/user_model.dart';
import 'dart:convert';
import 'dart:convert' show base64Url;
import 'dart:convert' show utf8;

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  requiresOtp,
  requiresProfileCompletion,
  error,
  unverified,
  profileIncomplete,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _error;
  bool _isLoading = false;
  String? _token;
  String? _pendingEmail;
  String? _role;
  UserType? _userType;

  // Temporary storage for profile completion
  String? _tempFullName;
  Gender? _tempGender;
  UserType? _tempUserType;
  File? _tempProfileImage;
  String? _tempBio;

  AuthProvider(this._authService) {
    _checkAuthStatus();
  }

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  UserType? get userType => _userType;
  String? get token => _token;
  String get userRole => _currentUser?.type.toString().split('.').last ?? '';
  String? get pendingEmail => _pendingEmail;  // Add getter for email

  void updateAuthState({
    AuthStatus? status,
    UserType? userType,
    bool? isLoading,
    String? error,
  }) {
    bool shouldNotify = false;

    if (status != null && status != _status) {
      _status = status;
      shouldNotify = true;
    }

    // Only update userType if it's provided and different from current
    if (userType != null && userType != _userType) {
      _userType = userType;
      shouldNotify = true;
    }

    if (isLoading != null && isLoading != _isLoading) {
      _isLoading = isLoading;
      shouldNotify = true;
    }

    if (error != null && error != _error) {
      _error = error;
      shouldNotify = true;
    }

    print('[AuthProvider] Auth state updated - Status: $_status, User Type: $_userType, IsLoading: $_isLoading');

    if (shouldNotify) {
      notifyListeners();
    }
  }

  // Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final isAuthenticated = await _authService.isAuthenticated();
      if (!isAuthenticated) {
        _status = AuthStatus.unauthenticated;
        _userType = null;
      } else {
        // Get profile to determine user type
        final profile = await _authService.fetchProfile();
        if (profile.success && profile.data?.user != null) {
          _userType = profile.data!.user!.type == UserType.coach ? UserType.coach : UserType.trainee;
          _status = AuthStatus.authenticated;
        } else {
          // If we can't determine user type, treat as unauthenticated
          _status = AuthStatus.unauthenticated;
          _userType = null;
        }
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _userType = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    developer.log('Starting registration in AuthProvider', name: 'AuthProvider');

    try {
      final response = await _authService.register(
        username: username,
        email: email,
        password: password,
      );

      developer.log(
        'Registration response: success=${response.success}, message=${response.message}',
        name: 'AuthProvider',
      );

      if (response.success) {
        _pendingEmail = email;  // Store the email
        updateAuthState(status: AuthStatus.requiresOtp);
        developer.log('Registration successful, status set to requiresOtp', name: 'AuthProvider');
        return true;
      } else {
        _error = response.error ?? 'Registration failed';
        developer.log('Registration failed: $_error', name: 'AuthProvider');
        return false;
      }
    } catch (e) {
      _error = e.toString();
      developer.log('Registration error: $_error', name: 'AuthProvider', error: e);
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.verifyOtp(otp);

      if (response.success) {
        // Store the temporary token
        if (response.data?.token != null) {
          _token = response.data!.token;
          developer.log('Token saved in AuthProvider after OTP: ${_token?.substring(0, 10)}...', name: 'AuthProvider');
        } else {
          developer.log('No token received from OTP verification', name: 'AuthProvider');
        }
        
        // After successful OTP verification, user needs to complete their profile
        updateAuthState(status: AuthStatus.requiresProfileCompletion);
        return true;
      } else {
        _error = response.error ?? 'OTP verification failed';
        return false;
      }
    } catch (e) {
      developer.log('OTP verification error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Store basic profile info
  Future<bool> storeBasicProfile({
    required String fullName,
    required Gender gender,
    required UserType type,
    File? imageFile,
    String? bio,
  }) async {
    try {
      _tempFullName = fullName;
      _tempGender = gender;
      _tempUserType = type;
      _tempProfileImage = imageFile;
      _tempBio = bio;
      updateAuthState(status: AuthStatus.profileIncomplete, userType: type);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Complete profile for trainee with health data
  Future<bool> updateTraineeHealthData(TraineeHealthDataUpdateRequest request) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.completeProfile(
        fullName: _tempFullName!,
        gender: _tempGender!,
        type: UserType.trainee,
        image: _tempProfileImage,
        bio: _tempBio ?? '',
        goalIds: request.goalIds.map((id) => id.toString()).toList(),
        age: request.age,
        height: request.height,
        weight: request.weight,
        bodyFat: request.fatPercentage,
        bodyMuscle: request.musclePercentage,
        hypertension: request.hypertension != null ? (request.hypertension! ? 'true' : 'false') : null,
        diabetes: request.diabetes != null ? (request.diabetes! ? 'true' : 'false') : null,
      );

      if (response.success) {
        // Save the new token if it's provided in the response
        if (response.data?.token != null) {
          _token = response.data!.token;
          developer.log('New token saved in AuthProvider after trainee health data: ${_token?.substring(0, 10)}...', name: 'AuthProvider');
        }
        
        updateAuthState(status: AuthStatus.authenticated, userType: UserType.trainee);
        _currentUser = response.data?.user;
        // Clear temporary data
        _clearTempData();
        return true;
      } else {
        _error = response.error ?? 'Failed to update health data';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Complete profile for coach with expertise
  Future<bool> updateCoachExpertise(CoachExpertiseUpdateRequest request) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.completeProfile(
        fullName: _tempFullName!,
        gender: _tempGender!,
        type: UserType.coach,
        image: _tempProfileImage,
        bio: _tempBio ?? '',
        experienceIds: request.experienceIds.map((id) => id.toString()).toList(),
      );

      if (response.success) {
        // Save the new token if it's provided in the response
        if (response.data?.token != null) {
          _token = response.data!.token;
          developer.log('New token saved in AuthProvider after coach expertise: ${_token?.substring(0, 10)}...', name: 'AuthProvider');
        }
        
        updateAuthState(status: AuthStatus.authenticated, userType: UserType.coach);
        _currentUser = response.data?.user;
        // Clear temporary data
        _clearTempData();
        return true;
      } else {
        _error = response.error ?? 'Failed to update expertise';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  void _clearTempData() {
    _tempFullName = null;
    _tempGender = null;
    _tempUserType = null;
    _tempProfileImage = null;
    _tempBio = null;
  }

  // Complete initial profile
  Future<bool> completeProfile({
    required String fullName,
    required Gender gender,
    required UserType type,
    File? imageFile,
    String? imageUrl,
    String? bio = '',  // Default empty string to handle nullable bio
  }) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.completeProfile(
        fullName: fullName,
        gender: gender,
        type: type,
        image: imageFile,  // Pass the File directly to the service
        bio: bio ?? '',  // Convert null to empty string
      );

      if (response.success) {
        updateAuthState(status: AuthStatus.profileIncomplete);  // Next step will be health data or expertise
        _currentUser = response.data?.user;
        return true;
      } else {
        _error = response.error ?? 'Failed to complete profile';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Sign in
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.signIn(
        username: username,
        password: password,
      );

      if (response.success) {
        if (response.data?.token != null) {
          // Parse the JWT token to get the role
          final parts = response.data!.token!.split('.');
          if (parts.length == 3) {
            final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
            );
            final role = payload['role'];
            
            // Update token and role
            await setToken(response.data!.token!);
            await setRole(role);
            
            // Fetch user profile
            final profileResponse = await _authService.fetchProfile();
            if (profileResponse.success && profileResponse.data?.user != null) {
              // Update state in a single call to avoid race conditions
                              _currentUser = profileResponse.data!.user;
                updateAuthState(
                  status: AuthStatus.authenticated,
                  userType: profileResponse.data!.user!.type,
                  isLoading: false,
                  error: null
              );
              return true;
            }
          }
        }
        _error = 'Invalid token format';
        updateAuthState(status: AuthStatus.error, error: _error);
        return false;
      } else {
        _error = response.error ?? 'Sign in failed';
        updateAuthState(status: AuthStatus.error, error: _error);
        return false;
      }
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      updateAuthState(status: AuthStatus.error, error: _error);
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.requestPasswordReset(email);

      if (response.success) {
        return true;
      } else {
        _error = response.error ?? 'Password reset request failed';
        return false;
      }
    } catch (e) {
      developer.log('Password reset request error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String password) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.resetPassword(password);
      
      if (response.success) {
        return true;
      } else {
        _error = response.error ?? 'Password reset failed';
        return false;
      }
    } catch (e) {
      developer.log('Password reset error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Sign out
  Future<void> logout() async {
    _isLoading = true;
    try {
      await _authService.signOut();
      _currentUser = null;
      _token = null;
      _role = null;
      updateAuthState(
        status: AuthStatus.unauthenticated,
        userType: null,
        isLoading: false
      );
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Force a state refresh and auth check
  Future<void> refreshAuthState() async {
    await _checkAuthStatus();
  }

  Future<bool> resendOtp() async {
    try {
      // TODO: Implement actual OTP resend API call
        return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required Gender gender,
    required UserType type,
    required String bio,
  }) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _authService.completeProfile(
        fullName: fullName,
        gender: gender,
        type: type,
        image: _tempProfileImage,
        bio: bio,
      );
      
      if (response.success) {
        updateAuthState(status: AuthStatus.requiresProfileCompletion);
        _currentUser = response.data?.user;
        return true;
      } else {
        _error = response.error ?? 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // Add new methods for setting token and role
  Future<void> setToken(String token) async {
    _token = token;
    await _authService.saveToken(token);
    notifyListeners();
  }

  Future<void> setRole(String role) async {
    _role = role;
    notifyListeners();
  }

  // Add a method to force a state refresh
  void refreshState() {
    notifyListeners();
  }

  // Reset error state
  void resetError() {
    updateAuthState(error: null);
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    if (isAuthenticated) {
      try {
        _isLoading = true;
        notifyListeners();

        final profileResponse = await _authService.fetchProfile();
        if (profileResponse.success && profileResponse.data?.user != null) {
          _currentUser = profileResponse.data!.user;
          _userType = profileResponse.data!.user!.type;
          _error = null;
        } else {
          _error = profileResponse.error ?? 'Failed to fetch profile';
        }
      } catch (e) {
        developer.log('Error refreshing profile: $e', name: 'AuthProvider', error: e);
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }
}



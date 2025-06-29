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
  UserType? get userType => _currentUser?.type;
  String? get token => _token;
  String get userRole => _currentUser?.type.toString().split('.').last ?? '';
  String? get pendingEmail => _pendingEmail;  // Add getter for email

  void _updateState({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? isLoading,
  }) {
    bool hasChanges = false;

    if (status != null && status != _status) {
      _status = status;
      hasChanges = true;
    }

    if (user != _currentUser) {
      _currentUser = user;
      hasChanges = true;
    }

    if (error != _error) {
      _error = error;
      hasChanges = true;
    }

    if (isLoading != null && isLoading != _isLoading) {
      _isLoading = isLoading;
      hasChanges = true;
    }

    if (hasChanges) {
      developer.log(
        'Auth state updated - Status: $_status, User Type: ${_currentUser?.type}, IsLoading: $_isLoading',
        name: 'AuthProvider'
      );
      notifyListeners();
    }
  }

  // Check current authentication status
  Future<void> _checkAuthStatus() async {
    try {
      _updateState(isLoading: true);
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        _updateState(status: AuthStatus.authenticating);
        
        // Fetch user profile if authenticated
        final profileResponse = await _authService.fetchProfile();
        
        if (profileResponse.success && profileResponse.data?.user != null) {
          _updateState(
            status: AuthStatus.authenticated,
            user: profileResponse.data!.user,
            isLoading: false
          );
        } else {
          // If profile fetch fails due to invalid token, clear auth state
          if (profileResponse.error?.toLowerCase().contains('invalid') == true ||
              profileResponse.error?.toLowerCase().contains('expired') == true) {
            await _authService.signOut();
            _updateState(
              status: AuthStatus.unauthenticated,
              user: null,
              isLoading: false
            );
          } else {
            _updateState(
              status: AuthStatus.error,
              error: profileResponse.error,
              isLoading: false
            );
          }
        }
      } else {
        _updateState(
          status: AuthStatus.unauthenticated,
          user: null,
          isLoading: false
        );
      }
    } catch (e) {
      developer.log('Error checking auth status: $e', name: 'AuthProvider', error: e);
      _updateState(
        status: AuthStatus.error,
        user: null,
        error: e.toString(),
        isLoading: false
      );
    }
  }

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _updateState(isLoading: true);
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
        _updateState(status: AuthStatus.requiresOtp);
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
      _updateState(isLoading: false);
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    _updateState(isLoading: true);
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
        _updateState(status: AuthStatus.requiresProfileCompletion);
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
      _updateState(isLoading: false);
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
      _updateState(status: AuthStatus.profileIncomplete);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  // Complete profile for trainee with health data
  Future<bool> updateTraineeHealthData(TraineeHealthDataUpdateRequest request) async {
    _updateState(isLoading: true);
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
      );

      if (response.success) {
        _updateState(status: AuthStatus.authenticated);
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
      _updateState(isLoading: false);
    }
  }

  // Complete profile for coach with expertise
  Future<bool> updateCoachExpertise(CoachExpertiseUpdateRequest request) async {
    _updateState(isLoading: true);
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
        _updateState(status: AuthStatus.authenticated);
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
      _updateState(isLoading: false);
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
    _updateState(isLoading: true);
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
        _updateState(status: AuthStatus.profileIncomplete);  // Next step will be health data or expertise
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
      _updateState(isLoading: false);
    }
  }

  // Sign in
  Future<bool> login(String username, String password) async {
    _updateState(isLoading: true);
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
              _currentUser = profileResponse.data!.user;
              _updateState(
                status: AuthStatus.authenticated,
                user: profileResponse.data!.user,
                isLoading: false
              );
              return true;
            }
          }
        }
        _error = 'Invalid token format';
        _updateState(status: AuthStatus.error);
        return false;
      } else {
        _error = response.error ?? 'Sign in failed';
        _updateState(status: AuthStatus.error);
        return false;
      }
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      _updateState(status: AuthStatus.error);
      return false;
    } finally {
      _updateState(isLoading: false);
    }
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    _updateState(isLoading: true);
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
      _updateState(isLoading: false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String password) async {
    _updateState(isLoading: true);
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
      _updateState(isLoading: false);
    }
  }

  // Sign out
  Future<void> logout() async {
    _updateState(isLoading: true);
    try {
      await _authService.signOut();
      _updateState(
        status: AuthStatus.unauthenticated,
        user: null,
        isLoading: false
      );
    } catch (e) {
      developer.log('Logout error: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
    } finally {
      _updateState(isLoading: false);
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
    _updateState(isLoading: true);
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
        _updateState(status: AuthStatus.requiresProfileCompletion);
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
      _updateState(isLoading: false);
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
    _updateState(error: null);
  }

  // Refresh user profile
  Future<void> refreshProfile() async {
    if (isAuthenticated) {
      await refreshAuthState();
    }
  }
}



import 'package:flutter/material.dart';
import 'dart:io';
import '../../data/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/constants/enums.dart';
import 'dart:developer' as developer;
import '../../data/mock/mock_data.dart';
import 'package:provider/provider.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  String? _token;
  String? _error;
  bool _isLoading = false;
  UserProfile? _currentUser;
  UserRole? _userRole;
  bool _isAuthenticated = false;
  String? _currentEmail;

  AuthProvider() {
    _loadStoredAuth();
  }

  AuthStatus get status => _status;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userRole => _userRole;

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      _currentEmail = prefs.getString('email');

      if (_token != null && _currentEmail != null) {
        await _fetchUserProfile();
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      developer.log('Error loading auth: $e', name: 'AuthProvider', error: e);
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _fetchUserProfile() async {
    try {
      if (_currentEmail != null) {
        _currentUser = MockData.getUserByEmail(_currentEmail!);
        if (_currentUser != null) {
          _status = AuthStatus.authenticated;
          _isAuthenticated = true;
          _userRole = _currentUser?.role;
        } else {
          _status = AuthStatus.unauthenticated;
        }
      }
    } catch (e) {
      developer.log('Error fetching profile: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    }
  }

  Future<void> _saveAuthData(String email, [BuildContext? context]) async {
    final prefs = await SharedPreferences.getInstance();
    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('token', mockToken);
    await prefs.setString('email', email);

    _token = mockToken;
    _currentEmail = email;
    _currentUser = MockData.getUserByEmail(email);
    _status = AuthStatus.authenticated;
    _isAuthenticated = true;
    _userRole = _currentUser?.role;

    developer.log('[AUTH] Mock login successful for email: $email', name: 'Auth');
    notifyListeners();
  }

  Future<bool> login(String email, String password, [BuildContext? context]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (MockData.validateCredentials(email, password)) {
        await _saveAuthData(email, context);
        return true;
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      developer.log('[AUTH] Login error: $e', name: 'Auth');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if email already exists
      if (MockData.getUserByEmail(email) != null) {
        throw Exception('Email already registered');
      }

      // Create new user profile
      final newUser = UserProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: username,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add user to mock data
      MockData.users[email] = newUser;
      MockData.passwords[email] = password;

      // Save auth data
      await _saveAuthData(email);
      return true;
    } catch (e) {
      developer.log('[AUTH] Registration error: $e', name: 'Auth');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String bio,
    required String gender,
    required String role,
    String? profileImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentEmail == null || _currentUser == null) {
        throw Exception('No authenticated user');
      }

      final updatedUser = _currentUser!.copyWith(
        name: name,
        gender: gender.toLowerCase() == 'male' ? Gender.male : Gender.female,
        role: role.toLowerCase() == 'coach' ? UserRole.coach : UserRole.trainee,
        profileImage: profileImage ?? _currentUser!.profileImage,
      );

      if (MockData.updateUserProfile(_currentEmail!, updatedUser)) {
        _currentUser = updatedUser;
        _userRole = updatedUser.role;
        notifyListeners();
        return true;
      }

      throw Exception('Failed to update profile');
    } catch (e) {
      developer.log('[PROFILE] Profile update error: $e', name: 'Profile');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTraineeHealthData({
    double? age,
    double? height,
    double? weight,
    double? fatPercentage,
    double? musclePercentage,
    List<String>? goals,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentEmail == null || _currentUser == null) {
        throw Exception('No authenticated user');
      }

      final updatedTraineeData = TraineeData(
        height: height,
        weight: weight,
        fatPercentage: fatPercentage,
        musclePercentage: musclePercentage,
        goals: goals,
      );

      final updatedUser = _currentUser!.copyWith(traineeData: updatedTraineeData);

      if (MockData.updateUserProfile(_currentEmail!, updatedUser)) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }

      throw Exception('Failed to update trainee health data');
    } catch (e) {
      developer.log('Error updating trainee health data: $e', name: 'AuthProvider', error: e);
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _token = null;
    _currentEmail = null;
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _isAuthenticated = false;
    _userRole = null;
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    if (_token != null) {
      _isLoading = true;
      notifyListeners();

      try {
        await _fetchUserProfile();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<bool> updateCoachExpertise({
    required List<String> expertise,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentEmail == null || _currentUser == null) {
        throw Exception('No authenticated user');
      }

      if (_currentUser!.role != UserRole.coach) {
        throw Exception('User is not a coach');
      }

      // In a real app, we would update the coach's expertise in the backend
      // For now, we'll just update the local user object
      final updatedUser = _currentUser!.copyWith(
        // Note: In a real app, you would have a CoachData class similar to TraineeData
        // For now, we'll just store the expertise without actually using it
      );

      if (MockData.updateUserProfile(_currentEmail!, updatedUser)) {
        _currentUser = updatedUser;
        notifyListeners();
        return true;
      }

      throw Exception('Failed to update coach expertise');
    } catch (e) {
      developer.log('[PROFILE] Coach expertise update error: $e', name: 'Profile');
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

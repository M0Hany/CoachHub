import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import 'dart:developer' as developer;

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._authService);

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setProfile(UserModel? profile) {
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String fullName,
    required Gender gender,
    required UserType type,
    required String bio,
    File? image,
    List<String>? experienceIds,
    List<String>? goalIds,
    int? age,
    double? height,
    double? weight,
    double? bodyFat,
    double? bodyMuscle,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.completeProfile(
        fullName: fullName,
        gender: gender,
        type: type,
        bio: bio,
        image: image,
        experienceIds: experienceIds,
        goalIds: goalIds,
        age: age,
        height: height,
        weight: weight,
        bodyFat: bodyFat,
        bodyMuscle: bodyMuscle,
      );

      if (response.success && response.data != null) {
        _profile = response.data!.user;
        notifyListeners();
      } else {
        throw Exception(response.error ?? 'Failed to update profile');
      }
    } catch (e) {
      developer.log('Profile update error: $e', name: 'ProfileProvider', error: e);
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }
}

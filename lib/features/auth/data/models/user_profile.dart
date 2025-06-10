import 'dart:developer' as developer;
import '../../../../core/constants/enums.dart';

class TraineeData {
  final double? height;
  final double? weight;
  final double? fatPercentage;
  final double? musclePercentage;
  final List<String>? goals;

  TraineeData({
    this.height,
    this.weight,
    this.fatPercentage,
    this.musclePercentage,
    this.goals,
  });

  factory TraineeData.fromJson(Map<String, dynamic> json) {
    // Debug log raw trainee data
    developer.log('Parsing trainee data:', name: 'TraineeData');
    developer.log('Raw JSON: $json', name: 'TraineeData');

    final traineeData = TraineeData(
      height:
          json['height'] != null ? (json['height'] as num).toDouble() : null,
      weight:
          json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      fatPercentage: json['fat_percentage'] != null
          ? (json['fat_percentage'] as num).toDouble()
          : null,
      musclePercentage: json['muscle_percentage'] != null
          ? (json['muscle_percentage'] as num).toDouble()
          : null,
      goals: json['goals'] != null ? List<String>.from(json['goals']) : null,
    );

    // Debug log parsed data
    developer.log('Parsed trainee data:', name: 'TraineeData');
    developer.log('Height: ${traineeData.height}', name: 'TraineeData');
    developer.log('Weight: ${traineeData.weight}', name: 'TraineeData');
    developer.log('Fat Percentage: ${traineeData.fatPercentage}', name: 'TraineeData');
    developer.log('Muscle Percentage: ${traineeData.musclePercentage}',
        name: 'TraineeData');
    developer.log('Goals: ${traineeData.goals}', name: 'TraineeData');

    return traineeData;
  }

  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'fat_percentage': fatPercentage,
      'muscle_percentage': musclePercentage,
      'goals': goals,
    };
  }
}

class UserProfile {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? profileImage;
  final Gender? gender;
  final UserRole? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final TraineeData? traineeData;

  UserProfile({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.profileImage,
    this.gender,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.traineeData,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Debug log for raw JSON
    developer.log('Raw JSON from API: $json', name: 'UserProfile');

    // Get trainee data from the trainee_data field
    Map<String, dynamic>? traineeJson =
        json['trainee_data'] as Map<String, dynamic>?;

    // Debug log trainee data
    developer.log('Trainee data from JSON: $traineeJson', name: 'UserProfile');

    final profile = UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phoneNumber: json['phone_number'],
      profileImage: json['profile_picture'],
      gender: _parseGender(json['gender']),
      role: _parseRole(json['role']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      traineeData:
          traineeJson != null ? TraineeData.fromJson(traineeJson) : null,
    );

    // Debug log created profile
    developer.log('Created UserProfile:', name: 'UserProfile');
    developer.log('Profile data: ${profile.toJson()}', name: 'UserProfile');
    developer.log('Trainee data: ${profile.traineeData?.toJson()}',
        name: 'UserProfile');

    return profile;
  }

  static Gender? _parseGender(String? genderStr) {
    switch (genderStr?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return null;
    }
  }

  static UserRole? _parseRole(String? roleStr) {
    if (roleStr == null) return null;

    // Log role parsing
    developer.log('[ROLE] Parsing role string: $roleStr', name: 'Navigation');

    switch (roleStr.toLowerCase().trim()) {
      case 'coach':
        return UserRole.coach;
      case 'trainee':
        return UserRole.trainee;
      default:
        developer.log('[ROLE] Unknown role: $roleStr', name: 'Navigation');
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'email': email,
      'name': name,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'gender': gender?.toString().split('.').last,
      'role': role?.toString().split('.').last,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };

    if (traineeData != null) {
      data['trainee_data'] = traineeData!.toJson();
    }

    return data;
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    String? profileImage,
    Gender? gender,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    TraineeData? traineeData,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      traineeData: traineeData ?? this.traineeData,
    );
  }

  // Convenience getters
  String? get genderString => gender?.toString().split('.').last;
  String? get goalsString => traineeData?.goals?.join(', ');

  // Trainee data getters
  double? get weight => traineeData?.weight;
  double? get height => traineeData?.height;
  double? get fatPercentage => traineeData?.fatPercentage;
  double? get musclePercentage => traineeData?.musclePercentage;
  List<String>? get goals => traineeData?.goals;
}

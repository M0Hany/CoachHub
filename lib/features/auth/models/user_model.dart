import '../../../core/models/models.dart';

enum UserType {
  trainee,
  coach,
}

enum Gender {
  male,
  female,
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? image;
  final String? bio;
  final Gender gender;
  final UserType type;
  final TraineeData? traineeData;
  final CoachData? coachData;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.image,
    this.bio,
    required this.gender,
    required this.type,
    this.traineeData,
    this.coachData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final type = UserType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == json['type'].toString().toLowerCase(),
    );

    return UserModel(
      id: json['id'].toString(),
      name: json['full_name'] as String,
      email: json['email'] as String,
      image: json['image_url'] as String?,
      bio: json['bio'] as String?,
      gender: Gender.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['gender'].toString().toLowerCase(),
      ),
      type: type,
      traineeData: type == UserType.trainee && json['trainee_data'] != null
          ? TraineeData.fromJson(json['trainee_data'])
          : null,
      coachData: type == UserType.coach && json['experiences'] != null
          ? CoachData(
              experienceIds: (json['experiences'] as List<dynamic>)
                  .map((e) => (e['id'] as num).toInt())
                  .toList(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'image': image,
      'bio': bio,
      'gender': gender.toString().split('.').last.toLowerCase(),
      'type': type.toString().split('.').last.toLowerCase(),
      if (traineeData != null) 'trainee_data': traineeData!.toJson(),
      if (coachData != null) 'coach_data': coachData!.toJson(),
    };
  }

  // Create a copy with some fields updated
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? bio,
    Gender? gender,
    UserType? type,
    TraineeData? traineeData,
    CoachData? coachData,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      type: type ?? this.type,
      traineeData: traineeData ?? this.traineeData,
      coachData: coachData ?? this.coachData,
    );
  }
}

class TraineeData {
  final List<int> goalIds;
  final double? weight;
  final double? height;
  final double? bodyFat;
  final double? bodyMuscle;
  final int? age;

  TraineeData({
    required this.goalIds,
    this.weight,
    this.height,
    this.bodyFat,
    this.bodyMuscle,
    this.age,
  });

  factory TraineeData.fromJson(Map<String, dynamic> json) {
    return TraineeData(
      goalIds: (json['goals'] as List<dynamic>).map((e) => int.parse(e.toString())).toList(),
      weight: json['weight']?.toDouble(),
      height: json['height']?.toDouble(),
      bodyFat: json['body_fat']?.toDouble(),
      bodyMuscle: json['body_muscle']?.toDouble(),
      age: json['age'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goals': goalIds.map((id) => id.toString()).toList(),
      'weight': weight,
      'height': height,
      'body_fat': bodyFat,
      'body_muscle': bodyMuscle,
      'age': age,
    };
  }
}

class CoachData {
  final List<int> experienceIds;

  CoachData({
    required this.experienceIds,
  });

  factory CoachData.fromJson(Map<String, dynamic> json) {
    return CoachData(
      experienceIds: (json['expertise'] as List<dynamic>).map((e) => int.parse(e.toString())).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expertise': experienceIds.map((id) => id.toString()).toList(),
    };
  }
} 
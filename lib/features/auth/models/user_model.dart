import '../../../core/models/models.dart';

enum UserType {
  trainee,
  coach,
}

enum Gender {
  male,
  female,
}

class Experience {
  final int id;
  final String name;

  Experience({
    required this.id,
    required this.name,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? imageUrl;
  final String? bio;
  final Gender gender;
  final UserType type;
  final double? rating;
  final List<Experience>? experiences;
  final Map<String, dynamic>? recentPost;
  final Map<String, dynamic>? recentReview;
  final TraineeData? traineeData;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.imageUrl,
    this.bio,
    required this.gender,
    required this.type,
    this.rating,
    this.experiences,
    this.recentPost,
    this.recentReview,
    this.traineeData,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final type = UserType.values.firstWhere(
      (e) => e.toString().split('.').last.toLowerCase() == json['type'].toString().toLowerCase(),
    );

    return UserModel(
      id: json['id'].toString(),
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      imageUrl: json['image_url'] as String?,
      bio: json['bio'] as String?,
      gender: Gender.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == json['gender'].toString().toLowerCase(),
      ),
      type: type,
      rating: (json['rating'] as num?)?.toDouble(),
      experiences: json['experiences'] != null
          ? (json['experiences'] as List<dynamic>)
              .map((e) => Experience.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      recentPost: json['recentPost'] != null ? json['recentPost'] as Map<String, dynamic> : null,
      recentReview: json['recentReview'] != null ? json['recentReview'] as Map<String, dynamic> : null,
      traineeData: type == UserType.trainee && json['trainee_data'] != null
          ? TraineeData.fromJson(json['trainee_data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'image_url': imageUrl,
      'bio': bio,
      'gender': gender.toString().split('.').last.toLowerCase(),
      'type': type.toString().split('.').last.toLowerCase(),
      'rating': rating,
      'experiences': experiences?.map((e) => e.toJson()).toList(),
      'recentPost': recentPost,
      'recentReview': recentReview,
      if (traineeData != null) ...{
        'goals': traineeData!.goals.map((g) => g.toJson()).toList(),
        'weight': traineeData!.weight,
        'height': traineeData!.height,
        'body_fat': traineeData!.bodyFat,
        'body_muscle': traineeData!.bodyMuscle,
        'age': traineeData!.age,
      },
    };
  }

  // Create a copy with some fields updated
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? imageUrl,
    String? bio,
    Gender? gender,
    UserType? type,
    double? rating,
    List<Experience>? experiences,
    Map<String, dynamic>? recentPost,
    Map<String, dynamic>? recentReview,
    TraineeData? traineeData,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      gender: gender ?? this.gender,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      experiences: experiences ?? this.experiences,
      recentPost: recentPost ?? this.recentPost,
      recentReview: recentReview ?? this.recentReview,
      traineeData: traineeData ?? this.traineeData,
    );
  }
}

class TraineeData {
  final List<Goal> goals;
  final double? weight;
  final double? height;
  final double? bodyFat;
  final double? bodyMuscle;
  final int? age;
  final bool? hypertension;
  final bool? diabetes;

  TraineeData({
    required this.goals,
    this.weight,
    this.height,
    this.bodyFat,
    this.bodyMuscle,
    this.age,
    this.hypertension,
    this.diabetes,
  });

  factory TraineeData.fromJson(Map<String, dynamic> json) {
    return TraineeData(
      goals: (json['goals'] as List<dynamic>)
          .map((e) => Goal.fromJson(e as Map<String, dynamic>))
          .toList(),
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      bodyFat: (json['body_fat'] as num?)?.toDouble(),
      bodyMuscle: (json['body_muscle'] as num?)?.toDouble(),
      age: json['age'] as int?,
      hypertension: json['hypertension'] == null ? null : json['hypertension'].toString() == 'true',
      diabetes: json['diabetes'] == null ? null : json['diabetes'].toString() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goals': goals.map((goal) => goal.toJson()).toList(),
      'weight': weight,
      'height': height,
      'body_fat': bodyFat,
      'body_muscle': bodyMuscle,
      'age': age,
      'hypertension': hypertension,
      'diabetes': diabetes,
    };
  }
}

class Goal {
  final int id;
  final String name;

  Goal({
    required this.id,
    required this.name,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
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
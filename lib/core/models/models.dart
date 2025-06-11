// Models for API responses
class Goal {
  final int id;
  final String name;

  Goal({required this.id, required this.name});

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ExperienceField {
  final int id;
  final String name;

  ExperienceField({required this.id, required this.name});

  factory ExperienceField.fromJson(Map<String, dynamic> json) {
    return ExperienceField(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class CoachExpertiseUpdateRequest {
  final List<int> experienceIds;

  CoachExpertiseUpdateRequest({required this.experienceIds});

  Map<String, dynamic> toJson() {
    return {
      'experience_IDs': experienceIds.map((id) => id.toString()).toList(),
    };
  }
}

class TraineeHealthDataUpdateRequest {
  final List<int> goalIds;
  final double? weight;
  final double? height;
  final double? fatPercentage;
  final double? musclePercentage;
  final int? age;

  TraineeHealthDataUpdateRequest({
    required this.goalIds,
    this.weight,
    this.height,
    this.fatPercentage,
    this.musclePercentage,
    this.age,
  });

  Map<String, dynamic> toJson() {
    return {
      'goals_IDs': goalIds.map((id) => id.toString()).toList(),
      'weight': weight,
      'height': height,
      'fatPercentage': fatPercentage,
      'musclePercentage': musclePercentage,
      'age': age,
    };
  }
} 
/// Represents the role of a user in the application
enum UserRole {
  /// A user who receives coaching
  trainee,

  /// A user who provides coaching
  coach,
}

/// Represents the gender of a user
enum Gender {
  /// Male gender
  male,

  /// Female gender
  female,

  /// Other gender
  other,
}

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

enum PlanType {
  workout,
  nutrition,
}

enum ChatMessageType {
  text,
  image,
  video,
  file,
}

enum WorkoutPlanStatus {
  draft,
  active,
  completed,
  archived,
}

enum NutritionPlanStatus {
  draft,
  active,
  completed,
  archived,
}

enum ExerciseType {
  strength,
  cardio,
  flexibility,
  balance,
}

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  legs,
  abs,
  fullBody,
}

enum TrainingGoal {
  weightLoss,
  muscleGain,
  endurance,
  strength,
  flexibility,
  general,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

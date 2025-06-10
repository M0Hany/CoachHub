import 'package:flutter/foundation.dart';

class WorkoutPlan {
  final String title;
  final int duration;
  final List<WorkoutDay> days;

  WorkoutPlan({
    required this.title,
    required this.duration,
    required this.days,
  });
}

class WorkoutDay {
  final int dayNumber;
  final List<MuscleGroup> muscleGroups;

  WorkoutDay({
    required this.dayNumber,
    required this.muscleGroups,
  });
}

class MuscleGroup {
  final String name;
  final List<Exercise> exercises;

  MuscleGroup({
    required this.name,
    required this.exercises,
  });
}

class Exercise {
  final String name;
  final String? animationPath;
  final int sets;
  final int reps;
  final int restTime; // in seconds
  final String? note;
  final String? videoUrl;

  Exercise({
    required this.name,
    this.animationPath,
    this.sets = 3,
    this.reps = 12,
    this.restTime = 60,
    this.note,
    this.videoUrl,
  });
} 
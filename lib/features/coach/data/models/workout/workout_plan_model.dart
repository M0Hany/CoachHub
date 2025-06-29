import 'package:flutter/foundation.dart';

class WorkoutPlan {
  final int? id;
  final String title;
  final int duration;
  final List<WorkoutDay> days;

  WorkoutPlan({
    this.id,
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
  final int? id;
  final String name;
  final String? animationPath;
  final int sets;
  final int reps;
  final int restTime; // in seconds
  final String? note;
  final String? videoUrl;

  Exercise({
    this.id,
    required this.name,
    this.animationPath,
    this.sets = 3,
    this.reps = 12,
    this.restTime = 60,
    this.note,
    this.videoUrl,
  });
} 
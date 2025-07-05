import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'dart:developer' as developer;
import 'package:lottie/lottie.dart';
import '../../../../../core/constants/enums.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final String muscleGroup;
  final List<ExerciseItem> exercises;
  final int dayId;
  final int workoutId;

  const ExerciseDetailsScreen({
    super.key,
    required this.muscleGroup,
    required this.exercises,
    required this.dayId,
    required this.workoutId,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.workout_plans_title,
          style: AppTheme.bodyMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: Text(
                      l10n.noExercisesAvailable,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return GestureDetector(
                        onTap: () {
                          context.push(
                            '/trainee/workout/exercise-instruction',
                            extra: {
                              'exerciseName': exercise.name,
                              'animationPath': exercise.animationPath,
                              'workoutId': workoutId,
                              'dayId': dayId,
                              'exerciseId': exercise.id,
                              'sets': exercise.sets,
                              'reps': exercise.reps,
                              'restTime': exercise.restTime,
                              'notes': exercise.notes,
                              'videoUrl': exercise.videoUrl,
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      color: Colors.grey[50],
                                      child: exercise.animationPath == null
                                        ? Container(
                                            color: Colors.grey[100],
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.fitness_center,
                                                  size: 48,
                                                  color: Colors.grey[400],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  l10n.animationComingSoon,
                                                  style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Lottie.asset(
                                            exercise.animationPath!,
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              developer.log(
                                                'Failed to load exercise animation: ${exercise.animationPath}',
                                                name: 'ExerciseDetailsScreen',
                                                error: error,
                                              );
                                              return Container(
                                                color: Colors.grey[100],
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.fitness_center,
                                                      size: 48,
                                                      color: Colors.grey[400],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      l10n.animationComingSoon,
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        exercise.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0FF789),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ExerciseItem {
  final String name;
  final String? animationPath;
  final int id;
  final int sets;
  final int reps;
  final int restTime;
  final String? notes;
  final String? videoUrl;

  const ExerciseItem({
    required this.name,
    required this.animationPath,
    required this.id,
    required this.sets,
    required this.reps,
    required this.restTime,
    this.notes,
    this.videoUrl,
  });
} 
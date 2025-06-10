import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import 'dart:developer' as developer;
import '../../../../../l10n/app_localizations.dart';

class WorkoutPlanDetailsScreen extends StatefulWidget {
  final String planTitle;
  final int planDuration;

  const WorkoutPlanDetailsScreen({
    super.key,
    required this.planTitle,
    required this.planDuration,
  });

  @override
  State<WorkoutPlanDetailsScreen> createState() => _WorkoutPlanDetailsScreenState();
}

class _WorkoutPlanDetailsScreenState extends State<WorkoutPlanDetailsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plans),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tabs for Workout/Nutrition plans
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 0
                            ? const Color(0xFF0FF789)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        l10n.workoutPlansTab,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTabIndex == 1
                            ? const Color(0xFF0FF789)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        l10n.nutritionPlansTab,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Plan title and duration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${l10n.planTitlePrefix}${widget.planTitle}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${l10n.planDurationPrefix}${widget.planDuration}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Days list
          Expanded(
            child: ListView.builder(
              itemCount: widget.planDuration,
              itemBuilder: (context, index) {
                final day = index + 1;
                final exercises = _getExercisesForDay(day);

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Day number
                      Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Text(
                              l10n.dayLabel,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              day.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Exercises
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: exercises.map((exercise) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0FF789),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  exercise,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),

                      // Show exercise button
                      if (exercises.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            final muscleGroup = exercises[0];
                            final encodedMuscleGroup = Uri.encodeComponent(muscleGroup);
                            
                            developer.log(
                              '[NAVIGATION] Attempting navigation: '
                              'from=WorkoutPlanDetailsScreen, '
                              'original=$muscleGroup, '
                              'encoded=$encodedMuscleGroup',
                              name: 'Navigation',
                            );

                            context.push('/trainee/exercise/$encodedMuscleGroup');
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFF0FF789),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            l10n.showExercise,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getExercisesForDay(int day) {
    // This is mock data - in a real app, this would come from a database or API
    switch (day) {
      case 1:
        return ['Upper Chest', 'Triceps'];
      case 2:
        return ['Biceps', 'Back'];
      case 3:
        return ['Legs', 'Shoulder Sidedelts'];
      case 4:
        return ['Rest'];
      case 5:
        return [];
      default:
        return [];
    }
  }
} 
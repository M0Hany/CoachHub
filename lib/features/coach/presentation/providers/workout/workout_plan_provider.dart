import 'package:flutter/foundation.dart';
import '../../../data/models/workout/workout_plan_model.dart';

class WorkoutPlanProvider extends ChangeNotifier {
  WorkoutPlan? _workoutPlan;
  List<WorkoutPlan> _savedPlans = [];
  int _currentDayPage = 0;
  int? _selectedDayIndex;

  WorkoutPlan? get workoutPlan => _workoutPlan;
  List<WorkoutPlan> get savedPlans => _savedPlans;
  int get currentDayPage => _currentDayPage;
  int? get selectedDayIndex => _selectedDayIndex;

  void initializePlan(String title, int duration) {
    _workoutPlan = WorkoutPlan(
      title: title,
      duration: duration,
      days: List.generate(
        duration,
        (index) => WorkoutDay(
          dayNumber: index + 1,
          muscleGroups: [],
        ),
      ),
    );
    _currentDayPage = 0;
    notifyListeners();
  }

  void setCurrentDayPage(int page) {
    _currentDayPage = page;
    notifyListeners();
  }

  void selectDay(int dayIndex) {
    _selectedDayIndex = dayIndex;
    notifyListeners();
  }

  void savePlan() {
    if (_workoutPlan != null) {
      _savedPlans.add(_workoutPlan!);
      _workoutPlan = null;
      _currentDayPage = 0;
      _selectedDayIndex = null;
      notifyListeners();
    }
  }

  void editPlan(int index) {
    if (index >= 0 && index < _savedPlans.length) {
      _workoutPlan = _savedPlans[index];
      _savedPlans.removeAt(index);
      _currentDayPage = 0;
      notifyListeners();
    }
  }

  void addExerciseToDay(int dayIndex, String muscleGroupName, Exercise exercise) {
    if (_workoutPlan == null) return;

    final day = _workoutPlan!.days[dayIndex];
    var muscleGroup = day.muscleGroups.firstWhere(
      (mg) => mg.name == muscleGroupName,
      orElse: () {
        final newMuscleGroup = MuscleGroup(
          name: muscleGroupName,
          exercises: [],
        );
        day.muscleGroups.add(newMuscleGroup);
        return newMuscleGroup;
      },
    );

    muscleGroup.exercises.add(exercise);
    notifyListeners();
  }

  void updateExercise(
    int dayIndex,
    String muscleGroupName,
    String exerciseName,
    Exercise updatedExercise,
  ) {
    if (_workoutPlan == null) return;

    final day = _workoutPlan!.days[dayIndex];
    final muscleGroup = day.muscleGroups.firstWhere(
      (mg) => mg.name == muscleGroupName,
      orElse: () => MuscleGroup(name: muscleGroupName, exercises: []),
    );

    final exerciseIndex = muscleGroup.exercises.indexWhere(
      (e) => e.name == exerciseName,
    );

    if (exerciseIndex != -1) {
      muscleGroup.exercises[exerciseIndex] = updatedExercise;
      notifyListeners();
    }
  }

  List<Exercise> getExercisesForDay(int dayIndex, String muscleGroupName) {
    if (_workoutPlan == null) return [];

    final day = _workoutPlan!.days[dayIndex];
    final muscleGroup = day.muscleGroups.firstWhere(
      (mg) => mg.name == muscleGroupName,
      orElse: () => MuscleGroup(name: muscleGroupName, exercises: []),
    );

    return muscleGroup.exercises;
  }
} 
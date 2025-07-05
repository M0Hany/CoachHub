import 'package:flutter/foundation.dart';
import '../../../data/models/workout/workout_plan_model.dart';
import '../../../../../../core/network/http_client.dart';

class WorkoutPlanProvider extends ChangeNotifier {
  final _httpClient = HttpClient();
  WorkoutPlan? _workoutPlan;
  List<WorkoutPlan> _savedPlans = [];
  int _currentDayPage = 0;
  int? _selectedDayIndex;
  int? _workoutId;
  bool _isLoading = false;
  String? _error;

  WorkoutPlan? get workoutPlan => _workoutPlan;
  List<WorkoutPlan> get savedPlans => _savedPlans;
  int get currentDayPage => _currentDayPage;
  int? get selectedDayIndex => _selectedDayIndex;
  int? get workoutId => _workoutId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void resetState() {
    _workoutPlan = null;
    _workoutId = null;
    _selectedDayIndex = null;
    _currentDayPage = 0;
    _error = null;
    _isLoading = false;
  }

  void initializePlan(String title, int duration) {
    if (duration <= 0) duration = 1; // Ensure at least one day
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
    _selectedDayIndex = null; // Reset selected day
    notifyListeners();
  }

  void setWorkoutId(int id) {
    print('WorkoutPlanProvider: setWorkoutId called with ID: $id');
    if (_workoutId == id && _workoutPlan != null && _workoutPlan!.id == id) {
      print('WorkoutPlanProvider: Plan already loaded for ID: $id, skipping update');
      return; // Avoid unnecessary updates
    }
    print('WorkoutPlanProvider: Updating workout ID to: $id');
    _workoutId = id;
    // Clear the current plan to force a reload
    _workoutPlan = null;
  }

  Future<void> fetchWorkoutPlans() async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches
    
    setLoading(true); // Use the existing method that handles notification
    _error = null;

    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/plans/workout/my-plans',
      );

      if (response.data?['status'] == 'success') {
        final plansData = response.data?['data']['workout_plans']['plans'] as List<dynamic>;
        _savedPlans = plansData.map((plan) => WorkoutPlan(
          id: plan['id'],
          title: plan['title'],
          duration: plan['duration'],
          days: (plan['days'] as List<dynamic>).map((day) => WorkoutDay(
            dayNumber: day['day_number'],
            muscleGroups: [],
          )).toList(),
        )).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false); // Use the existing method that handles notification
    }
  }

  Future<void> fetchWorkoutPlanDetails(int planId) async {
    print('WorkoutPlanProvider: fetchWorkoutPlanDetails started for plan $planId');
    
    // If we already have this plan loaded and it's the correct plan, don't fetch again
    if (_workoutId == planId && _workoutPlan != null && _workoutPlan!.id == planId) {
      print('WorkoutPlanProvider: Plan already loaded and matches requested ID, skipping fetch');
      return;
    }

    print('WorkoutPlanProvider: Setting loading state and clearing error');
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('WorkoutPlanProvider: Making HTTP request for plan $planId');
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/plans/workout/$planId',
      );
      print('WorkoutPlanProvider: Received API response:');
      print(response.data);

      if (response.data?['status'] == 'success') {
        print('WorkoutPlanProvider: Response status is success');
        final planData = response.data?['data']['workout_plan'];
        print('WorkoutPlanProvider: Plan data:');
        print(planData);
        
        if (planData == null) {
          print('WorkoutPlanProvider: Plan data is null');
          throw Exception('Invalid plan data received');
        }

        final days = planData['days'] as List<dynamic>?;
        print('WorkoutPlanProvider: Days data:');
        print(days);

        if (days == null) {
          throw Exception('No days data received');
        }

        print('WorkoutPlanProvider: Processing days data');
        final processedDays = days.map((day) {
          print('WorkoutPlanProvider: Processing day ${day['day_number']}');
          final exercisesByMuscle = <String, List<Exercise>>{};
          final exercises = day['exercises'] as List<dynamic>;
          
          for (final exerciseData in exercises) {
            final exercise = exerciseData['exercise'];
            final targetMuscle = exercise['target_muscle'] as String;
            
            exercisesByMuscle.putIfAbsent(targetMuscle, () => []);
            exercisesByMuscle[targetMuscle]!.add(Exercise(
              name: exercise['title'],
              animationPath: exercise['animation'],
              sets: exerciseData['sets'],
              reps: exerciseData['reps'],
              restTime: exerciseData['rest_time'],
              note: exerciseData['notes'],
              videoUrl: exerciseData['video_url'],
            ));
          }

          return WorkoutDay(
            dayNumber: day['day_number'],
            muscleGroups: exercisesByMuscle.entries.map((entry) => MuscleGroup(
              name: entry.key,
              exercises: entry.value,
            )).toList(),
          );
        }).toList();

        print('WorkoutPlanProvider: Creating WorkoutPlan object');
        _workoutPlan = WorkoutPlan(
          id: planData['id'],
          title: planData['title'],
          duration: planData['duration'],
          days: processedDays,
        );
        
        print('WorkoutPlanProvider: Verifying created plan matches requested ID');
        if (_workoutPlan!.id != planId) {
          print('WorkoutPlanProvider: WARNING - Created plan ID ${_workoutPlan!.id} does not match requested ID $planId');
          throw Exception('Server returned wrong plan ID');
        }
        
        print('WorkoutPlanProvider: Setting workout ID and clearing error');
        _workoutId = planId;
        _error = null;
        print('WorkoutPlanProvider: Plan processing completed successfully');
      } else {
        print('WorkoutPlanProvider: Response status is not success');
        throw Exception(response.data?['message'] ?? 'Failed to fetch workout plan');
      }
    } catch (e) {
      print('WorkoutPlanProvider: Error in fetchWorkoutPlanDetails:');
      print(e);
      _error = e.toString();
      _workoutPlan = null;
      rethrow;
    } finally {
      print('WorkoutPlanProvider: Setting loading state to false and notifying listeners');
      _isLoading = false;
      notifyListeners(); // Single notification at the end
    }
  }

  void setCurrentDayPage(int page) {
    _currentDayPage = page;
    notifyListeners();
  }

  void selectDay(int dayIndex) {
    print('WorkoutPlanProvider: Selecting day $dayIndex');
    if (_workoutPlan == null) {
      print('WorkoutPlanProvider: Cannot select day: workout plan is null');
      throw Exception('No workout plan selected');
    }

    if (dayIndex < 0 || dayIndex >= _workoutPlan!.duration) {
      print('WorkoutPlanProvider: Cannot select day: invalid day index $dayIndex (max duration: ${_workoutPlan!.duration})');
      throw Exception('Invalid day index');
    }

    _selectedDayIndex = dayIndex;
    print('WorkoutPlanProvider: Selected day $_selectedDayIndex');
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

  Future<void> addExerciseToDay(Exercise exercise, String muscleGroup) async {
    print('WorkoutPlanProvider: Adding exercise to day $_selectedDayIndex');
    if (_workoutPlan == null) {
      print('WorkoutPlanProvider: Cannot add exercise: workout plan is null');
      throw Exception('No workout plan selected');
    }

    if (_selectedDayIndex == null) {
      print('WorkoutPlanProvider: Cannot add exercise: no day selected');
      throw Exception('No day selected');
    }

    if (_workoutId == null) {
      print('WorkoutPlanProvider: Cannot add exercise: no workout ID');
      throw Exception('No workout ID');
    }

    // Ensure we have enough days in the plan
    while (_workoutPlan!.days.length <= _selectedDayIndex!) {
      print('WorkoutPlanProvider: Adding new day ${_workoutPlan!.days.length + 1}');
      _workoutPlan!.days.add(WorkoutDay(
        dayNumber: _workoutPlan!.days.length + 1,
        muscleGroups: [],
      ));
    }

    // Find or create muscle group
    final day = _workoutPlan!.days[_selectedDayIndex!];
    var muscleGroupObj = day.muscleGroups.firstWhere(
      (mg) => mg.name == muscleGroup,
      orElse: () {
        print('WorkoutPlanProvider: Creating new muscle group $muscleGroup');
        final newMuscleGroup = MuscleGroup(name: muscleGroup, exercises: []);
        day.muscleGroups.add(newMuscleGroup);
        return newMuscleGroup;
      },
    );

    print('WorkoutPlanProvider: Adding exercise ${exercise.name} to muscle group ${muscleGroupObj.name}');
    muscleGroupObj.exercises.add(exercise);

    // Update the plan on the server
    try {
      print('WorkoutPlanProvider: Updating plan on server');
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/api/plans/workout/$_workoutId',
        data: {
          'title': _workoutPlan!.title,
          'days': [
            {
              'day_number': _selectedDayIndex! + 1,
              'add_exercises': [
                {
                  'exercise_id': 1, // TODO: Get actual exercise ID from API
                  'sets': exercise.sets,
                  'reps': exercise.reps,
                  'rest_time': exercise.restTime,
                  'notes': exercise.note,
                  'video_url': exercise.videoUrl,
                }
              ],
              'remove_exercise_ids': [],
              'update_exercises': []
            }
          ]
        },
      );

      if (response.data?['status'] != 'success') {
        throw Exception(response.data?['message'] ?? 'Failed to update workout plan');
      }

      print('WorkoutPlanProvider: Successfully updated plan on server');
      notifyListeners();
    } catch (e) {
      print('WorkoutPlanProvider: Failed to update plan on server: $e');
      throw Exception('Failed to update workout plan: $e');
    }
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

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> deletePlan(int planId) async {
    print('WorkoutPlanProvider: deletePlan started for plan $planId');
    
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('WorkoutPlanProvider: Making HTTP request to delete plan $planId');
      final response = await _httpClient.delete<Map<String, dynamic>>(
        '/api/plans/workout/$planId',
      );
      print('WorkoutPlanProvider: Received API response:');
      print(response.data);

      if (response.data?['status'] == 'success') {
        print('WorkoutPlanProvider: Plan deleted successfully');
        // Remove the plan from saved plans if it exists
        _savedPlans.removeWhere((plan) => plan.id == planId);
        // Clear current plan if it was the deleted one
        if (_workoutPlan?.id == planId) {
          _workoutPlan = null;
          _workoutId = null;
          _selectedDayIndex = null;
          _currentDayPage = 0;
        }
      } else {
        print('WorkoutPlanProvider: Response status is not success');
        throw Exception(response.data?['message'] ?? 'Failed to delete workout plan');
      }
    } catch (e) {
      print('WorkoutPlanProvider: Error in deletePlan:');
      print(e);
      _error = e.toString();
      rethrow;
    } finally {
      print('WorkoutPlanProvider: Setting loading state to false and notifying listeners');
      _isLoading = false;
      notifyListeners();
    }
  }
} 
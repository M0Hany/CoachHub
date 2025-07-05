import 'package:flutter/foundation.dart';
import '../../../data/models/nutrition/nutrition_plan_model.dart';
import '../../../../../../core/network/http_client.dart';

class NutritionPlanProvider extends ChangeNotifier {
  NutritionPlan? _nutritionPlan;
  List<NutritionPlan> _savedPlans = [];
  int _currentDayPage = 0;
  int? _selectedDayIndex;
  bool _isLoading = false;
  String? _error;
  HttpClient _httpClient = HttpClient();

  NutritionPlan? get nutritionPlan => _nutritionPlan;
  List<NutritionPlan> get savedPlans => _savedPlans;
  int get currentDayPage => _currentDayPage;
  int? get selectedDayIndex => _selectedDayIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchNutritionPlans() async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches
    
    setLoading(true); // Use a single notification
    _error = null;

    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/plans/nutrition/my-plans',
      );

      if (response.data?['status'] == 'success') {
        final plansData = response.data?['data']['nutrition_plans']['plans'] as List<dynamic>;
        _savedPlans = plansData.map((plan) => NutritionPlan(
          id: plan['id'],
          title: plan['title'],
          duration: plan['duration'],
          days: (plan['days'] as List<dynamic>).map((day) => NutritionDay(
            dayNumber: day['day_number'],
            meals: [],
            breakfast: day['breakfast'] ?? '',
            lunch: day['lunch'] ?? '',
            dinner: day['dinner'] ?? '',
            snacks: day['snack'] ?? '',
            note: day['notes'],
          )).toList(),
        )).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setLoading(false); // Use a single notification
    }
  }

  Future<void> fetchNutritionPlanDetails(int planId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/plans/nutrition/$planId',
      );

      if (response.data?['status'] == 'success') {
        final planData = response.data?['data']['nutrition_plan'];
        _nutritionPlan = NutritionPlan(
          id: planData['id'],
          title: planData['title'],
          duration: planData['duration'],
          days: (planData['days'] as List<dynamic>).map((day) => NutritionDay(
            dayNumber: day['day_number'],
            meals: [],
            breakfast: day['breakfast'] ?? '',
            lunch: day['lunch'] ?? '',
            dinner: day['dinner'] ?? '',
            snacks: day['snack'] ?? '',
            note: day['notes'],
          )).toList(),
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void initializePlan(String title, int duration) {
    _nutritionPlan = NutritionPlan(
      title: title,
      duration: duration,
      days: List.generate(
        duration,
        (index) => NutritionDay(
          dayNumber: index + 1,
          meals: [],
          breakfast: '',
          lunch: '',
          dinner: '',
          snacks: '',
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
    if (_nutritionPlan != null) {
      _savedPlans.add(_nutritionPlan!);
      _nutritionPlan = null;
      _currentDayPage = 0;
      _selectedDayIndex = null;
      notifyListeners();
    }
  }

  void editPlan(int index) {
    if (index >= 0 && index < _savedPlans.length) {
      _nutritionPlan = _savedPlans[index];
      _savedPlans.removeAt(index);
      _currentDayPage = 0;
      notifyListeners();
    }
  }

  void updateDayMeals({
    required int dayIndex,
    String? breakfast,
    String? lunch,
    String? dinner,
    String? snacks,
    String? note,
  }) {
    if (_nutritionPlan == null) return;

    final day = _nutritionPlan!.days[dayIndex];
    
    if (breakfast != null) day.breakfast = breakfast;
    if (lunch != null) day.lunch = lunch;
    if (dinner != null) day.dinner = dinner;
    if (snacks != null) day.snacks = snacks;
    if (note != null) day.note = note;

    notifyListeners();
  }

  NutritionDay? getDayMeals(int dayIndex) {
    if (_nutritionPlan == null) return null;
    return _nutritionPlan!.days[dayIndex];
  }

  void setNutritionPlanId(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _httpClient.get<Map<String, dynamic>>(
        '/api/plans/nutrition/$id',
      );

      if (response.data?['status'] == 'success') {
        final planData = response.data?['data']['nutrition_plan'];
        _nutritionPlan = NutritionPlan(
          id: planData['id'],
          title: planData['title'],
          duration: planData['duration'],
          days: (planData['days'] as List<dynamic>).map((day) => NutritionDay(
            dayNumber: day['day_number'],
            meals: [],
            breakfast: day['breakfast'] ?? '',
            lunch: day['lunch'] ?? '',
            dinner: day['dinner'] ?? '',
            snacks: day['snack'] ?? '',
            note: day['notes'],
          )).toList(),
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNutritionPlan() async {
    if (_nutritionPlan == null || _nutritionPlan!.id == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _httpClient.put<Map<String, dynamic>>(
        '/api/plans/nutrition/${_nutritionPlan!.id}',
        data: {
          'title': _nutritionPlan!.title,
          'days': _nutritionPlan!.days.map((day) => {
            'day_number': day.dayNumber,
            'breakfast': day.breakfast,
            'lunch': day.lunch,
            'dinner': day.dinner,
            'snack': day.snacks,
            'notes': day.note,
          }).toList(),
        },
      );

      if (response.data?['status'] == 'success') {
        // Plan updated successfully
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePlan(int planId) async {
    print('NutritionPlanProvider: deletePlan started for plan $planId');
    
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      print('NutritionPlanProvider: Making HTTP request to delete plan $planId');
      final response = await _httpClient.delete<Map<String, dynamic>>(
        '/api/plans/nutrition/$planId',
      );
      print('NutritionPlanProvider: Received API response:');
      print(response.data);

      if (response.data?['status'] == 'success') {
        print('NutritionPlanProvider: Plan deleted successfully');
        // Remove the plan from saved plans if it exists
        _savedPlans.removeWhere((plan) => plan.id == planId);
        // Clear current plan if it was the deleted one
        if (_nutritionPlan?.id == planId) {
          _nutritionPlan = null;
          _selectedDayIndex = null;
          _currentDayPage = 0;
        }
      } else {
        print('NutritionPlanProvider: Response status is not success');
        throw Exception(response.data?['message'] ?? 'Failed to delete nutrition plan');
      }
    } catch (e) {
      print('NutritionPlanProvider: Error in deletePlan:');
      print(e);
      _error = e.toString();
      rethrow;
    } finally {
      print('NutritionPlanProvider: Setting loading state to false and notifying listeners');
      _isLoading = false;
      notifyListeners();
    }
  }
} 
import 'package:flutter/foundation.dart';
import '../../../data/models/nutrition/nutrition_plan_model.dart';

class NutritionPlanProvider extends ChangeNotifier {
  NutritionPlan? _nutritionPlan;
  List<NutritionPlan> _savedPlans = [];
  int _currentDayPage = 0;
  int? _selectedDayIndex;

  NutritionPlan? get nutritionPlan => _nutritionPlan;
  List<NutritionPlan> get savedPlans => _savedPlans;
  int get currentDayPage => _currentDayPage;
  int? get selectedDayIndex => _selectedDayIndex;

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
} 
import 'package:flutter/foundation.dart';

class NutritionPlan {
  final int? id;
  final String title;
  final int duration;
  final List<NutritionDay> days;

  NutritionPlan({
    this.id,
    required this.title,
    required this.duration,
    required this.days,
  });
}

class NutritionDay {
  final int dayNumber;
  String breakfast;
  String lunch;
  String dinner;
  String snacks;
  String? note;
  final List<Meal> meals;

  NutritionDay({
    required this.dayNumber,
    required this.meals,
    this.breakfast = '',
    this.lunch = '',
    this.dinner = '',
    this.snacks = '',
    this.note,
  });
}

class Meal {
  final String name;
  final String type; // breakfast, lunch, dinner, snack
  final List<String> ingredients;
  final String? recipe;
  final int calories;
  final Map<String, double> macros; // protein, carbs, fats in grams
  final String? note;

  Meal({
    required this.name,
    required this.type,
    required this.ingredients,
    this.recipe,
    required this.calories,
    required this.macros,
    this.note,
  });
} 
import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String baseUrl = 'https://coachhub-production.up.railway.app';
  
  // API Endpoints
  static String get authEndpoint => '$baseUrl/api/auth';
  static String get postEndpoint => '$baseUrl/api/post';
  static String get subscriptionEndpoint => '$baseUrl/api/subscription';
  static String get workoutPlansEndpoint => '$baseUrl/api/plans/workout';
  static String get nutritionPlansEndpoint => '$baseUrl/api/plans/nutrition';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
} 
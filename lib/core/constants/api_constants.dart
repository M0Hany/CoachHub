class ApiConstants {
  static const String baseUrl =
      'http://10.0.2.2:3000'; // Android emulator localhost

  // Add other API-related constants here
  static const String apiPath = '/api';
  static const String uploadsPath = '/uploads';

  // Full paths
  static const String apiBaseUrl = '$baseUrl$apiPath';
  static const String uploadsBaseUrl = '$baseUrl$uploadsPath';
}

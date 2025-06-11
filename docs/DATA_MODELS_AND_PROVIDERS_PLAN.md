# Data Models and Providers Implementation Plan

## 1. Authentication & User Management

### Data Models
```dart
// lib/features/auth/data/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  // Add fromJson, toJson methods
}

// lib/features/auth/data/models/auth_response_model.dart
class AuthResponseModel {
  final String token;
  final UserModel user;
  // Add fromJson, toJson methods
}
```

### Providers
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String name, UserRole role);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> updateProfile(Map<String, dynamic> data);
}
```

## 2. Trainee Flow

### Profile & Health Data Models
```dart
// lib/features/trainee/data/models/trainee_profile_model.dart
class TraineeProfileModel {
  final String userId;
  final int age;
  final double height;
  final double weight;
  final String fitnessGoal;
  final FitnessLevel fitnessLevel;
  final List<String> preferences;
  // Add fromJson, toJson methods
}

// lib/features/trainee/data/models/health_data_model.dart
class HealthDataModel {
  final String userId;
  final List<HealthMetric> metrics;
  final DateTime recordedAt;
  // Add fromJson, toJson methods
}
```

### Search & Coach Discovery Models
```dart
// lib/features/trainee/data/models/coach_search_model.dart
class CoachSearchModel {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int reviewCount;
  final String profileImage;
  final List<String> certifications;
  final double pricePerSession;
  // Add fromJson, toJson methods
}

// lib/features/trainee/data/models/search_filters_model.dart
class SearchFiltersModel {
  final List<String> specializations;
  final PriceRange priceRange;
  final double? minRating;
  final List<String>? availability;
  // Add fromJson, toJson methods
}
```

### Trainee Providers
```dart
// lib/features/trainee/presentation/providers/trainee_profile_provider.dart
class TraineeProfileProvider extends ChangeNotifier {
  TraineeProfileModel? _profile;
  bool _isLoading = false;

  Future<void> fetchProfile();
  Future<void> updateProfile(TraineeProfileModel profile);
  Future<void> updateHealthData(HealthDataModel data);
}

// lib/features/trainee/presentation/providers/coach_search_provider.dart
class CoachSearchProvider extends ChangeNotifier {
  List<CoachSearchModel> _searchResults = [];
  SearchFiltersModel _filters = SearchFiltersModel();
  bool _isLoading = false;

  Future<void> searchCoaches(String query);
  Future<void> applyFilters(SearchFiltersModel filters);
  Future<void> fetchRecommendedCoaches();
}
```

## 3. Coach Flow

### Coach Profile Models
```dart
// lib/features/coach/data/models/coach_profile_model.dart
class CoachProfileModel {
  final String userId;
  final String bio;
  final List<String> specializations;
  final List<Certification> certifications;
  final List<TimeSlot> availability;
  final PricingModel pricing;
  final double rating;
  // Add fromJson, toJson methods
}

// lib/features/coach/data/models/certification_model.dart
class CertificationModel {
  final String name;
  final String issuingBody;
  final DateTime issueDate;
  final DateTime? expiryDate;
  final String? certificateUrl;
  // Add fromJson, toJson methods
}
```

### Coach Providers
```dart
// lib/features/coach/presentation/providers/coach_profile_provider.dart
class CoachProfileProvider extends ChangeNotifier {
  CoachProfileModel? _profile;
  bool _isLoading = false;

  Future<void> fetchProfile();
  Future<void> updateProfile(CoachProfileModel profile);
  Future<void> updateAvailability(List<TimeSlot> slots);
  Future<void> updatePricing(PricingModel pricing);
}
```

## 4. Chat & Messaging

### Chat Models
```dart
// lib/core/models/chat_message_model.dart
class ChatMessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  // Add fromJson, toJson methods
}

// lib/core/models/chat_room_model.dart
class ChatRoomModel {
  final String id;
  final String traineeId;
  final String coachId;
  final ChatMessageModel? lastMessage;
  final DateTime lastActivity;
  // Add fromJson, toJson methods
}
```

### Chat Providers
```dart
// lib/core/providers/chat_provider.dart
class ChatProvider extends ChangeNotifier {
  List<ChatRoomModel> _chatRooms = [];
  Map<String, List<ChatMessageModel>> _messages = {};
  bool _isLoading = false;

  Future<void> fetchChatRooms();
  Future<void> fetchMessages(String chatRoomId);
  Future<void> sendMessage(String chatRoomId, String content, MessageType type);
  Future<void> markAsRead(String chatRoomId);
  void handleNewMessage(ChatMessageModel message);
}
```

## 5. Training Plans

### Plan Models
```dart
// lib/features/plans/data/models/workout_plan_model.dart
class WorkoutPlanModel {
  final String id;
  final String coachId;
  final String traineeId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final List<WorkoutDayModel> days;
  // Add fromJson, toJson methods
}

// lib/features/plans/data/models/workout_day_model.dart
class WorkoutDayModel {
  final int dayNumber;
  final List<ExerciseModel> exercises;
  final String? notes;
  // Add fromJson, toJson methods
}

// lib/features/plans/data/models/exercise_model.dart
class ExerciseModel {
  final String name;
  final String muscleGroup;
  final int sets;
  final int reps;
  final double? weight;
  final String? notes;
  final String? videoUrl;
  // Add fromJson, toJson methods
}
```

### Plan Providers
```dart
// lib/features/plans/presentation/providers/workout_plan_provider.dart
class WorkoutPlanProvider extends ChangeNotifier {
  List<WorkoutPlanModel> _plans = [];
  WorkoutPlanModel? _currentPlan;
  bool _isLoading = false;

  Future<void> fetchPlans();
  Future<void> createPlan(WorkoutPlanModel plan);
  Future<void> updatePlan(String planId, WorkoutPlanModel plan);
  Future<void> deletePlan(String planId);
  Future<void> assignPlanToTrainee(String planId, String traineeId);
}
```

## 6. Notifications

### Notification Models
```dart
// lib/core/models/notification_model.dart
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  // Add fromJson, toJson methods
}
```

### Notification Providers
```dart
// lib/core/providers/notification_provider.dart
class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  Future<void> fetchNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  void handleNewNotification(NotificationModel notification);
}
```

## Implementation Order

1. Authentication & User Management
   - Implement user models and auth provider
   - Set up token management and secure storage
   - Implement login/register flows

2. Trainee Profile & Search
   - Implement trainee profile models and provider
   - Build coach search models and provider
   - Set up health data tracking

3. Coach Profile & Management
   - Implement coach profile models and provider
   - Build certification and availability management
   - Set up pricing and schedule management

4. Chat System
   - Implement chat models
   - Set up real-time messaging provider
   - Integrate with Socket.IO

5. Training Plans
   - Implement plan models
   - Build plan management provider
   - Set up progress tracking

6. Notifications
   - Implement notification models
   - Set up notification provider
   - Integrate with push notifications

## Notes

1. All models should implement:
   - `fromJson` and `toJson` methods
   - `copyWith` method for immutability
   - Proper equality comparisons

2. All providers should:
   - Handle loading states
   - Implement error handling
   - Cache data appropriately
   - Clean up resources in dispose

3. Testing:
   - Write unit tests for models
   - Write unit tests for providers
   - Implement integration tests for key flows

4. Documentation:
   - Document all public APIs
   - Include usage examples
   - Document state management patterns 
import '../../../../core/constants/enums.dart';
import '../models/user_profile.dart';

class MockData {
  static final Map<String, UserProfile> users = {
    'trainee@test.com': UserProfile(
      id: '1',
      email: 'trainee@test.com',
      name: 'John Doe',
      phoneNumber: '+201234567890',
      profileImage: 'F:/Programming/CoachHub/frontend/assets/images/default_profile.png',
      gender: Gender.male,
      role: UserRole.trainee,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      traineeData: TraineeData(
        height: 175.0,
        weight: 75.0,
        fatPercentage: 15.0,
        musclePercentage: 40.0,
        goals: ['Weight Loss', 'Muscle Gain', 'Better Health'],
      ),
    ),
    'coach@test.com': UserProfile(
      id: '2',
      email: 'coach@test.com',
      name: 'Jane Smith',
      phoneNumber: '+201234567891',
      profileImage: 'F:/Programming/CoachHub/frontend/assets/images/default_profile.png',
      gender: Gender.female,
      role: UserRole.coach,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  };

  static final Map<String, String> passwords = {
    'trainee@test.com': 'password123',
    'coach@test.com': 'password123',
  };

  static bool validateCredentials(String email, String password) {
    return passwords.containsKey(email) && passwords[email] == password;
  }

  static UserProfile? getUserByEmail(String email) {
    return users[email];
  }

  static bool updateUserProfile(String email, UserProfile updatedProfile) {
    if (users.containsKey(email)) {
      users[email] = updatedProfile;
      return true;
    }
    return false;
  }
} 
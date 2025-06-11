enum UserRole {
  coach,
  trainee,
}

enum Gender {
  male,
  female,
  other,
}

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  unverified,
  profileIncomplete,
  requiresOtp,
  requiresProfileCompletion,
  error,
} 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Auth screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Coach screens
import '../../features/coach/presentation/screens/chat/coach_chat_room_screen.dart';
import '../../features/coach/presentation/screens/chat/coach_chats_screen.dart';
import '../../features/coach/presentation/screens/coach_notifications_screen.dart';
import '../../features/coach/presentation/screens/home/coach_home_screen.dart';
import '../../features/coach/presentation/screens/profile/coach_profile_screen.dart';
import '../../features/coach/presentation/screens/settings/coach_settings_screen.dart';
import '../../features/coach/presentation/screens/plans/coach_plans_screen.dart';
import '../../features/coach/presentation/screens/plans/create_plan_screen.dart';
import '../../features/coach/presentation/screens/plans/workout/calendar/workout_plan_calendar_screen.dart';
import '../../features/coach/presentation/screens/plans/workout/muscle/muscle_selection_screen.dart';
import '../../features/coach/presentation/screens/plans/workout/exercise/exercise_selection_screen.dart';
import '../../features/coach/presentation/screens/plans/workout/exercise/exercise_details_form_screen.dart';
import '../../features/coach/presentation/screens/plans/nutrition/calendar/nutrition_plan_calendar_screen.dart';
import '../../features/coach/presentation/screens/plans/nutrition/day/nutrition_day_details_screen.dart';
import '../../features/trainee/presentation/screens/search/view_coach_profile_screen.dart';
import '../../features/coach/presentation/screens/coach_expertise_screen.dart';

// Trainee screens
import '../../features/trainee/presentation/screens/chat/trainee_chats_screen.dart' as trainee;
import '../../features/trainee/presentation/screens/chat/trainee_chat_room_screen.dart' as trainee;
import '../../features/trainee/presentation/screens/notifications/trainee_notifications_screen.dart';
import '../../features/trainee/presentation/screens/search/trainee_search_screen.dart';
import '../../features/trainee/presentation/screens/home/trainee_home_screen.dart';
import '../../features/trainee/presentation/screens/profile/trainee_profile_screen.dart';
import '../../features/trainee/presentation/screens/settings/trainee_settings_screen.dart';
import '../../features/trainee/presentation/screens/workout/workout_plan_details_screen.dart';
import '../../features/trainee/presentation/screens/workout/exercise_details_screen.dart';
import '../../features/trainee/presentation/screens/workout/exercise_instruction_screen.dart';
import '../../features/trainee/presentation/screens/health/trainee_health_data_screen.dart';

import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import 'dart:developer' as developer;
import '../../features/auth/presentation/screens/onboarding/onboarding_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/onboarding',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) {
    developer.log(
      '[ROUTER] Error building route: ${state.matchedLocation}',
      name: 'Navigation',
      error: 'No route found',
    );
    return const LoginScreen();
  },
  redirect: (BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isAuthenticated;
    final userRole = authProvider.userRole;
    final currentLocation = state.matchedLocation;

    // Public routes that don't require authentication
    final isPublicRoute = currentLocation == '/login' ||
        currentLocation == '/register' ||
        currentLocation == '/complete-profile' ||
        currentLocation == '/onboarding';

    // If not logged in, only allow public routes
    if (!isLoggedIn) {
      if (isPublicRoute) return null;
      return '/login';
    }

    // If logged in and trying to access auth routes, redirect to home
    if (isLoggedIn && (currentLocation == '/login' || currentLocation == '/register')) {
      return userRole == UserRole.coach ? '/coach/home' : '/trainee/home';
    }

    return null;
  },
  routes: [
    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: '/trainee-health-data',
      builder: (context, state) => const TraineeHealthDataScreen(),
    ),

    // Trainee routes
    GoRoute(
      path: '/trainee',
      builder: (context, state) => const TraineeHomeScreen(),
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, state) => const TraineeHomeScreen(),
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) => const TraineeSearchScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const TraineeProfileScreen(),
        ),
        GoRoute(
          path: 'chats',
          builder: (context, state) => const trainee.TraineeChatsScreen(),
        ),
        GoRoute(
          path: 'chat/:id',
          builder: (context, state) {
            final chatId = state.pathParameters['id']!;
            return trainee.ChatScreen(
              name: chatId,
              imageUrl: 'assets/images/default_profile.png',
              lastSeen: 'Online',
            );
          },
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const TraineeNotificationsScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const TraineeSettingsScreen(),
        ),
        GoRoute(
          path: 'health-data',
          builder: (context, state) => const TraineeHealthDataScreen(),
        ),
        GoRoute(
          path: 'workout-plan/:planTitle',
          builder: (context, state) {
            final planTitle = state.pathParameters['planTitle'] ?? '';
            return WorkoutPlanDetailsScreen(
              planTitle: planTitle,
              planDuration: 7, // Default duration
            );
          },
        ),
        GoRoute(
          path: 'exercise/:muscleGroup',
          builder: (context, state) {
            final muscleGroup = state.pathParameters['muscleGroup'] ?? '';
            return ExerciseDetailsScreen(
              muscleGroup: muscleGroup,
              exercises: _getExercisesForMuscleGroup(muscleGroup),
            );
          },
        ),
        GoRoute(
          path: 'exercise-instruction/:exerciseName',
          builder: (context, state) {
            final exerciseName = state.pathParameters['exerciseName'] ?? '';
            final animationPath = state.extra as String;
            return ExerciseInstructionScreen(
              exerciseName: exerciseName,
              animationPath: animationPath,
            );
          },
        ),
      ],
    ),

    // Coach routes
    GoRoute(
      path: '/coach',
      builder: (context, state) => const CoachHomeScreen(),
      routes: [
        GoRoute(
          path: 'home',
          builder: (context, state) => const CoachHomeScreen(),
        ),
        GoRoute(
          path: 'plans',
          builder: (context, state) => const CoachPlansScreen(),
        ),
        GoRoute(
          path: 'plans/create-workout',
          builder: (context, state) => const CreatePlanScreen(),
        ),
        GoRoute(
          path: 'plans/create-nutrition',
          builder: (context, state) => const CreatePlanScreen(),
        ),
        GoRoute(
          path: 'plans/workout/calendar',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return WorkoutPlanCalendarScreen(
              title: extra?['title'] ?? 'New Workout Plan',
              duration: extra?['duration'] ?? 7,
            );
          },
        ),
        GoRoute(
          path: 'plans/workout/muscles',
          builder: (context, state) => const MuscleSelectionScreen(
            dayNumber: 1,
          ),
        ),
        GoRoute(
          path: 'plans/workout/exercises',
          builder: (context, state) {
            final muscleGroup = state.extra as String;
            return ExerciseSelectionScreen(
              dayNumber: 1,
              muscleGroup: muscleGroup,
            );
          },
        ),
        GoRoute(
          path: 'plans/workout/exercise-details',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>;
            return ExerciseDetailsFormScreen(
              dayNumber: 1,
              muscleGroup: args['muscleGroup'] as String,
              exerciseData: args['exerciseData'] as ExerciseData,
            );
          },
        ),
        GoRoute(
          path: 'plans/nutrition/calendar',
          builder: (context, state) => const NutritionPlanCalendarScreen(),
        ),
        GoRoute(
          path: 'plans/nutrition/day-details',
          builder: (context, state) => const NutritionDayDetailsScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const CoachProfileScreen(),
        ),
        GoRoute(
          path: 'chats',
          builder: (context, state) => const CoachChatsScreen(),
        ),
        GoRoute(
          path: 'chat/:id',
          builder: (context, state) {
            final chatId = state.pathParameters['id']!;
            // Using mock data for chat details
            return CoachChatRoomScreen(
              traineeId: chatId,
            );
          },
        ),
        GoRoute(
          path: 'notifications',
          builder: (context, state) => const CoachNotificationsScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const CoachSettingsScreen(),
        ),
        GoRoute(
          path: 'coach/:id',
          builder: (context, state) {
            final coachId = state.pathParameters['id']!;
            // Using mock data for now
            return ViewCoachProfileScreen(
              coachId: coachId,
              name: 'Coach Name',
              email: 'coach@example.com',
              imageUrl: 'assets/images/default_profile.png',
              rating: 4.5,
              expertiseFields: ['Weight Training', 'Cardio', 'Nutrition'],
            );
          },
        ),
        GoRoute(
          path: 'expertise',
          builder: (context, state) => const CoachExpertiseScreen(),
        ),
      ],
    ),

    // Workout Plan Routes
    GoRoute(
      path: '/workout-plan-calendar',
      name: 'workout-plan-calendar',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return WorkoutPlanCalendarScreen(
          title: args['title'] as String,
          duration: args['duration'] as int,
        );
      },
    ),
    GoRoute(
      path: '/muscle-selection/:dayNumber',
      name: 'muscle-selection',
      builder: (context, state) {
        final dayNumber = int.parse(state.pathParameters['dayNumber'] ?? '1');
        return MuscleSelectionScreen(dayNumber: dayNumber);
      },
    ),
    GoRoute(
      path: '/exercise-selection/:dayNumber/:muscleGroup',
      name: 'exercise-selection',
      builder: (context, state) {
        final dayNumber = int.parse(state.pathParameters['dayNumber'] ?? '1');
        final muscleGroup = state.pathParameters['muscleGroup'] ?? '';
        return ExerciseSelectionScreen(
          dayNumber: dayNumber,
          muscleGroup: muscleGroup,
        );
      },
    ),
    GoRoute(
      path: '/exercise-details/:dayNumber',
      name: 'exercise-details',
      builder: (context, state) {
        final dayNumber = int.parse(state.pathParameters['dayNumber'] ?? '1');
        final args = state.extra as Map<String, dynamic>;
        return ExerciseDetailsFormScreen(
          dayNumber: dayNumber,
          muscleGroup: args['muscleGroup'] as String,
          exerciseData: args['exerciseData'] as ExerciseData,
        );
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
  ],
);

List<ExerciseItem> _getExercisesForMuscleGroup(String muscleGroup) {
  // This is mock data - in a real app, this would come from a database or API
  switch (muscleGroup) {
    case 'Upper Chest':
      return [
        ExerciseItem(
          name: 'Incline Bench Press',
          animationPath: 'assets/animations/incline_bench_press.json',
        ),
        ExerciseItem(
          name: 'Incline Dumbbell Press',
          animationPath: 'assets/animations/incline_dumbbell_press.json',
        ),
      ];
    case 'Triceps':
      return [
        ExerciseItem(
          name: 'Tricep Pushdown',
          animationPath: 'assets/animations/tricep_pushdown.json',
        ),
        ExerciseItem(
          name: 'Overhead Tricep Extension',
          animationPath: 'assets/animations/overhead_tricep_extension.json',
        ),
      ];
    default:
      return [];
  }
}


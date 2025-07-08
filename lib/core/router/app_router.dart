import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart' hide AuthStatus;

// Auth screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/models/user_model.dart';  // Import for UserType
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../core/services/token_service.dart';
import '../../features/auth/presentation/screens/reset/enter_email_reset_screen.dart';
import '../../features/auth/presentation/screens/reset/otp_reset_screen.dart';
import '../../features/auth/presentation/screens/reset/new_password_screen.dart';

// Coach screens
import '../../features/chat/chat_room_screen.dart';
import '../../features/chat/chats_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/coach/presentation/screens/home/coach_home_screen.dart';
import '../../features/coach/presentation/screens/profile/coach_profile_screen.dart';
import '../../features/coach/presentation/screens/posts/coach_posts_screen.dart';
import '../../features/coach/presentation/screens/posts/coach_post_focus_screen.dart';
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
import '../../features/coach/presentation/screens/coach_subscription_requests_screen.dart';
import '../../features/coach/presentation/screens/view_trainee_profile_screen.dart';
import '../../features/coach/presentation/screens/reviews/coach_reviews_screen.dart';

// Trainee screens
import '../../features/trainee/presentation/screens/search/trainee_search_screen.dart';
import '../../features/trainee/presentation/screens/home/trainee_home_screen.dart';
import '../../features/trainee/presentation/screens/profile/trainee_profile_screen.dart';
import '../../features/trainee/presentation/screens/settings/trainee_settings_screen.dart';
import '../../features/trainee/presentation/screens/workout/workout_plan_details_screen.dart';
import '../../features/trainee/presentation/screens/workout/exercise_details_screen.dart';
import '../../features/trainee/presentation/screens/workout/exercise_instruction_screen.dart';
import '../../features/trainee/presentation/screens/health/trainee_health_data_screen.dart';
import '../../features/trainee/presentation/screens/nutrition/nutrition_plan_details_screen.dart';
import '../../features/trainee/presentation/screens/nutrition/meal_details_screen.dart';
import '../../features/trainee/presentation/screens/search/trainee_coach_posts_screen.dart';
import '../../features/trainee/presentation/screens/search/trainee_coach_post_focus_screen.dart';
import '../../features/trainee/presentation/screens/search/trainee_coach_reviews_screen.dart';

import 'dart:developer' as developer;
import '../../features/auth/presentation/screens/onboarding/onboarding_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) {
    developer.log(
      '[ROUTER] Error building route: ${state.matchedLocation}',
      name: 'Navigation',
      error: 'No route found',
    );
    return const LoginScreen();
  },
  redirect: (BuildContext context, GoRouterState state) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tokenService = TokenService();
    final currentLocation = state.matchedLocation;
    final authStatus = authProvider.status;
    final userType = authProvider.userType; // Use the getter instead of direct access

    developer.log(
      'Redirecting: Status=$authStatus, Location=$currentLocation, UserType=$userType, IsLoading=${authProvider.isLoading}',
      name: 'Router',
    );

    // If we're on the splash screen, let it handle its own redirections
    if (currentLocation == '/splash') {
      return null;
    }

    // If we're still in initial state or authenticating, redirect to splash
    if (authStatus == AuthStatus.initial || 
        authStatus == AuthStatus.authenticating) {
      developer.log('Redirecting to splash: still in $authStatus state', name: 'Router');
      return '/splash';
    }

    // Public routes that don't require authentication
    final isResetRoute = currentLocation.startsWith('/reset/');
    final isPublicRoute = currentLocation == '/login' ||
        currentLocation == '/register' ||
        currentLocation == '/onboarding' ||
        isResetRoute; // Include reset routes as public routes

    // Auth flow routes
    final isAuthFlowRoute = currentLocation == '/verify-otp' ||
        currentLocation == '/complete-profile' ||
        currentLocation == '/trainee-health-data' ||
        currentLocation == '/coach/expertise';

    // Check onboarding status
    final hasSeenOnboarding = await tokenService.hasOnboardingBeenShown();

    // Handle different auth states
    switch (authStatus) {
      case AuthStatus.authenticated:
        // If we're on onboarding and haven't seen it yet, allow staying there
        if (currentLocation == '/onboarding' && !hasSeenOnboarding) {
          return null;
        }

        // If userType is null, redirect to login to re-authenticate
        if (userType == null) {
          developer.log('User type is null while authenticated, redirecting to login', name: 'Router');
          return '/login';
        }

        // If we're on a public route or auth flow route (but not a reset route), redirect to home
        if ((isPublicRoute || isAuthFlowRoute) && !isResetRoute) {
          // If we haven't seen onboarding, go there first
          if (!hasSeenOnboarding) {
            return '/onboarding';
          }
          return userType == UserType.coach ? '/coach/home' : '/trainee/home';
        }

        // If authenticated user is on a reset route, redirect to home
        if (isResetRoute) {
          return userType == UserType.coach ? '/coach/home' : '/trainee/home';
        }

        // Ensure coach users stay in coach routes and trainee users stay in trainee routes
        // Allow both user types to access the unified /chat route
        if (currentLocation == '/chat' || currentLocation.startsWith('/chat/room') || currentLocation == '/notifications') {
          return null; // Allow access to unified chat routes
        } else if (userType == UserType.coach && currentLocation.startsWith('/trainee')) {
          return '/coach/home';
        } else if (userType == UserType.trainee && currentLocation.startsWith('/coach')) {
          return '/trainee/home';
        }
        
        return null;

      case AuthStatus.requiresOtp:
        if (currentLocation != '/verify-otp') {
          return '/verify-otp';
        }
        return null;

      case AuthStatus.requiresProfileCompletion:
        if (currentLocation != '/complete-profile') {
          return '/complete-profile';
        }
        return null;

      case AuthStatus.profileIncomplete:
        // Allow access to expertise and health data screens during profile completion
        // Also allow access to unified chat route
        if (currentLocation == '/coach/expertise' || 
            currentLocation == '/trainee-health-data' ||
            currentLocation == '/chat' ||
            currentLocation.startsWith('/chat/room') ||
            currentLocation == '/notifications') {
          return null;
        }
        if (userType == UserType.trainee) {
          return '/trainee-health-data';
        } else if (userType == UserType.coach) {
          return '/coach/expertise';
        }
        return '/complete-profile';

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        // For unauthenticated users, only allow access to public routes
        if (!isPublicRoute && !isAuthFlowRoute) {
          developer.log('Unauthenticated user trying to access protected route, redirecting to login', name: 'Router');
          return '/login';
        }
        // If they're already on a public route, let them stay
        return null;
        
      default:
        // For any other status (like initial), redirect to splash
        return '/splash';
    }
  },
  routes: [
    // Auth routes
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) => const OtpVerificationScreen(),
    ),
    GoRoute(
      path: '/complete-profile',
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: '/trainee-health-data',
      builder: (context, state) => const TraineeHealthDataScreen(),
    ),
    GoRoute(
      path: '/coach/expertise',
      builder: (context, state) => const CoachExpertiseScreen(),
    ),
    GoRoute(
      path: '/reset/email',
      builder: (context, state) => const EnterEmailResetScreen(),
    ),
    GoRoute(
      path: '/reset/otp_reset_screen',
      builder: (context, state) => const OtpResetScreen(),
    ),
    GoRoute(
      path: '/reset/new_password_screen',
      builder: (context, state) => const NewPasswordScreen(),
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
          path: 'settings',
          builder: (context, state) => const TraineeSettingsScreen(),
        ),
        GoRoute(
          path: 'health-data',
          builder: (context, state) => const TraineeHealthDataScreen(),
        ),
        GoRoute(
          path: 'workout-plan-details',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final planId = extra?['planId'] as int? ?? -1;
            final duration = extra?['duration'] as int? ?? 7;
            return WorkoutPlanDetailsScreen(
              planId: planId,
              duration: duration,
            );
          },
        ),
        GoRoute(
          path: 'workout-plan/:planId',
          builder: (context, state) {
            final planId = int.tryParse(state.pathParameters['planId'] ?? '') ?? -1;
            return WorkoutPlanDetailsScreen(
              planId: planId,
              duration: 7, // Default duration
            );
          },
        ),
        GoRoute(
          path: 'workout/exercise-details',
          builder: (context, state) {
            final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
            return ExerciseDetailsScreen(
              muscleGroup: extra['muscleGroup'] as String,
              exercises: extra['exercises'] as List<ExerciseItem>,
              dayId: extra['dayId'] as int,
              workoutId: extra['workoutId'] as int,
            );
          },
        ),
        GoRoute(
          path: 'workout/exercise-instruction',
          builder: (context, state) {
            final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
            return ExerciseInstructionScreen(
              exerciseName: extra['exerciseName'] as String,
              animationPath: extra['animationPath'] as String?,
              workoutId: extra['workoutId'] as int,
              dayId: extra['dayId'] as int,
              exerciseId: extra['exerciseId'] as int,
              sets: extra['sets'] as int,
              reps: extra['reps'] as int,
              restTime: extra['restTime'] as int,
              notes: extra['notes'] as String?,
              videoUrl: extra['videoUrl'] as String?,
            );
          },
        ),
        GoRoute(
          path: 'coach/:id',
          builder: (context, state) {
            final coachId = state.pathParameters['id']!;
            return ViewCoachProfileScreen(coachId: coachId);
          },
        ),
        GoRoute(
          path: 'nutrition-plan-details',
          builder: (context, state) => const NutritionPlanDetailsScreen(),
        ),
        GoRoute(
          path: 'meal-details',
          builder: (context, state) => const MealDetailsScreen(),
        ),
        GoRoute(
          path: 'coach/:coachId/posts',
          builder: (context, state) {
            final coachId = state.pathParameters['coachId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return TraineeCoachPostsScreen(
              coachId: coachId,
              coachImageUrl: extra?['coachImageUrl'],
              coachFullName: extra?['coachFullName'],
            );
          },
        ),
        GoRoute(
          path: 'coach/:coachId/posts/focus',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return TraineeCoachPostFocusScreen(
              post: extra['post'],
              coachImageUrl: extra['coachImageUrl'],
              coachFullName: extra['coachFullName'],
            );
          },
        ),
        GoRoute(
          path: 'coach/:coachId/reviews',
          builder: (context, state) {
            final coachId = state.pathParameters['coachId']!;
            final extra = state.extra as Map<String, dynamic>?;
            return TraineeCoachReviewsScreen(
              coachId: coachId,
              coachImageUrl: extra?['coachImageUrl'],
              coachFullName: extra?['coachFullName'],
            );
          },
        ),
        GoRoute(
          path: 'chats',
          builder: (context, state) => const ChatsScreen(userRole: UserRole.trainee),
        ),
        GoRoute(
          path: 'chat',
          builder: (context, state) => Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final userType = authProvider.userType;
              final userRole = userType == UserType.coach ? UserRole.coach : UserRole.trainee;
              return ChatsScreen(userRole: userRole);
            },
          ),
        ),
        GoRoute(
          path: 'chat/room/:id',
          builder: (context, state) {
            final recipientId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, dynamic>?;
            return ChatRoomScreen(
              recipientId: recipientId,
              recipientName: extra?['recipientName'] ?? 'User',
              chatId: extra?['chatId'],
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
            print('Router: Building workout plan calendar screen with extra: ${state.extra}');
            final Map<String, dynamic> extra = state.extra as Map<String, dynamic>? ?? {};
            
            // Parse planId as int with default value
            final planId = extra['planId'] != null ? int.parse(extra['planId'].toString()) : -1;
            final duration = extra['duration'] as int? ?? 7;
            
            print('Router: Parsed parameters - planId: $planId, duration: $duration');
            return WorkoutPlanCalendarScreen(
              planId: planId,
              duration: duration,
            );
          },
        ),
        GoRoute(
          path: 'plans/workout/muscles',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            final dayNumber = extra['day_number'] as int? ?? 1;
            final selectedMuscles = extra['selected_muscles'] as List<String>?;
            print('Router: Building muscle selection screen with dayNumber: $dayNumber, selectedMuscles: $selectedMuscles');
            return MuscleSelectionScreen(
              dayNumber: dayNumber,
              selectedMuscles: selectedMuscles,
            );
          },
        ),
        GoRoute(
          path: 'plans/workout/exercises',
          builder: (context, state) {
            print('Router: Building exercise selection screen with extra: ${state.extra}');
            final extra = state.extra as Map<String, dynamic>;
            final dayNumber = extra['day_number'] as int;
            final muscleGroup = extra['muscle_group'] as String;
            print('Router: Parsed parameters - dayNumber: $dayNumber, muscleGroup: $muscleGroup');
            return ExerciseSelectionScreen(
              dayNumber: dayNumber,
              muscleGroup: muscleGroup,
            );
          },
        ),
        GoRoute(
          path: 'plans/workout/exercise-details',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return ExerciseDetailsFormScreen(
              dayNumber: extra['day_number'] as int,
              muscleGroup: extra['muscle_group'] as String,
              exerciseData: extra['exercise_data'] as ExerciseData,
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
          path: 'posts',
          builder: (context, state) => const CoachPostsScreen(),
        ),
        GoRoute(
          path: 'posts/focus',
          builder: (context, state) {
            final post = state.extra as Map<String, dynamic>;
            return CoachPostFocusScreen(post: post['post']);
          },
        ),
        GoRoute(
          path: 'chats',
          builder: (context, state) => const ChatsScreen(userRole: UserRole.coach),
        ),
        GoRoute(
          path: 'chat',
          builder: (context, state) => Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final userType = authProvider.userType;
              final userRole = userType == UserType.coach ? UserRole.coach : UserRole.trainee;
              return ChatsScreen(userRole: userRole);
            },
          ),
        ),
        GoRoute(
          path: 'chat/room/:id',
          builder: (context, state) {
            final recipientId = state.pathParameters['id'] ?? '';
            final extra = state.extra as Map<String, dynamic>?;
            return ChatRoomScreen(
              recipientId: recipientId,
              recipientName: extra?['recipientName'] ?? 'User',
              chatId: extra?['chatId'],
            );
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const CoachSettingsScreen(),
        ),
        GoRoute(
          path: 'coach/:id',
          builder: (context, state) {
            final coachId = state.pathParameters['id']!;
            return ViewCoachProfileScreen(coachId: coachId);
          },
        ),
        GoRoute(
          path: 'expertise',
          builder: (context, state) => const CoachExpertiseScreen(),
        ),
        GoRoute(
          path: 'subscription-requests',
          builder: (context, state) => const CoachSubscriptionRequestsScreen(),
        ),
        GoRoute(
          path: 'view-trainee/:id',
          builder: (context, state) {
            final traineeId = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
            return ViewTraineeProfileScreen(traineeId: traineeId);
          },
        ),
        GoRoute(
          path: 'reviews',
          builder: (context, state) => const CoachReviewsScreen(),
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
          planId: args['planId'] as int,
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
        return ExerciseDetailsScreen(
          muscleGroup: args['muscleGroup'] as String? ?? 'Default',
          exercises: args['exercises'] as List<ExerciseItem>? ?? _getExercisesForMuscleGroup('Upper Chest'),
          dayId: args['dayId'] as int? ?? dayNumber,
          workoutId: args['workoutId'] as int? ?? 1,
        );
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final userType = authProvider.userType;
          final userRole = userType == UserType.coach ? UserRole.coach : UserRole.trainee;
          return ChatsScreen(userRole: userRole);
        },
      ),
    ),
    GoRoute(
      path: '/chat/room/:id',
      builder: (context, state) {
        final recipientId = state.pathParameters['id'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        return ChatRoomScreen(
          recipientId: recipientId,
          recipientName: extra?['recipientName'] ?? 'User',
          chatId: extra?['chatId'],
        );
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final userType = authProvider.userType;
          final userRole = userType == UserType.coach ? UserRole.coach : UserRole.trainee;
          return NotificationsScreen(userRole: userRole);
        },
      ),
    ),
    GoRoute(
      path: '/coach/view-trainee/:id',
      builder: (context, state) {
        final traineeId = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
        return ViewTraineeProfileScreen(traineeId: traineeId);
      },
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
          id: 1,
          sets: 3,
          reps: 12,
          restTime: 60,
          notes: 'Keep your core tight',
          videoUrl: 'https://example.com/incline-bench-press',
        ),
        ExerciseItem(
          name: 'Incline Dumbbell Press',
          animationPath: 'assets/animations/incline_dumbbell_press.json',
          id: 2,
          sets: 3,
          reps: 10,
          restTime: 90,
          notes: 'Full range of motion',
          videoUrl: 'https://example.com/incline-dumbbell-press',
        ),
      ];
    case 'Shoulder Front Delts':
      return [
        ExerciseItem(
          name: 'Military Press',
          animationPath: 'assets/animations/military_press.json',
          id: 3,
          sets: 4,
          reps: 8,
          restTime: 120,
          notes: 'Keep your core engaged',
          videoUrl: 'https://example.com/military-press',
        ),
        ExerciseItem(
          name: 'Front Raises',
          animationPath: 'assets/animations/front_raises.json',
          id: 4,
          sets: 3,
          reps: 15,
          restTime: 60,
          notes: 'Control the movement',
          videoUrl: 'https://example.com/front-raises',
        ),
      ];
    default:
      return [];
  }
}


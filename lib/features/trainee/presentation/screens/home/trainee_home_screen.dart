import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'dart:math';

// Language-specific layout values
class NutritionPlanLayoutValues {
  // English (LTR) values
  static const ltrBreakfastFlex = 5;
  static const ltrLunchFlex = 3;
  static const ltrDinnerFlex = 4;
  static const ltrSnackFlex = 4;

  static const ltrBreakfastMargin = EdgeInsetsDirectional.symmetric(horizontal: 18);
  static const ltrLunchMargin = EdgeInsetsDirectional.symmetric(horizontal: 5);
  static const ltrDinnerMargin = EdgeInsetsDirectional.only(start: 25);
  static const ltrSnackMargin = EdgeInsetsDirectional.only(start: 30);

  // Arabic (RTL) values - starting with same values as English, adjust as needed
  static const rtlBreakfastFlex = 5;
  static const rtlLunchFlex = 5;
  static const rtlDinnerFlex = 5;
  static const rtlSnackFlex = 5;

  static const rtlBreakfastMargin = EdgeInsetsDirectional.only(start: 20);
  static const rtlLunchMargin = EdgeInsetsDirectional.only(start: 30);
  static const rtlDinnerMargin = EdgeInsetsDirectional.only(start: 34);
  static const rtlSnackMargin = EdgeInsetsDirectional.only(start: 34);

  // Get values based on text direction
  static int getBreakfastFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrBreakfastFlex : rtlBreakfastFlex;
  static int getLunchFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrLunchFlex : rtlLunchFlex;
  static int getDinnerFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrDinnerFlex : rtlDinnerFlex;
  static int getSnackFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrSnackFlex : rtlSnackFlex;

  static EdgeInsetsDirectional getBreakfastMargin(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrBreakfastMargin : rtlBreakfastMargin;
  static EdgeInsetsDirectional getLunchMargin(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrLunchMargin : rtlLunchMargin;
  static EdgeInsetsDirectional getDinnerMargin(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrDinnerMargin : rtlDinnerMargin;
  static EdgeInsetsDirectional getSnackMargin(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrSnackMargin : rtlSnackMargin;
}

class TraineeHomeScreen extends StatefulWidget {
  const TraineeHomeScreen({super.key});

  @override
  State<TraineeHomeScreen> createState() => _TraineeHomeScreenState();
}

class _TraineeHomeScreenState extends State<TraineeHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _traineeProfile;
  Map<String, dynamic>? _workoutPlan;
  Map<String, dynamic>? _nutritionPlan;
  Map<String, dynamic>? _coachProfile;
  int _currentWorkoutDay = 1;
  int _currentNutritionDay = 1;
  List<Map<String, dynamic>> _healthHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final httpClient = HttpClient();

      // Get trainee profile
      final profileResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/profile/',
      );

      if (profileResponse.data?['status'] == 'success') {
        _traineeProfile = profileResponse.data!['data']['profile'];
      }

      // Get health history data
      try {
        final healthResponse = await httpClient.get<Map<String, dynamic>>(
          '/api/trainee/health',
        );

        if (healthResponse.data?['status'] == 'success') {
          final healthData = healthResponse.data!['data'] as List<dynamic>;
          _healthHistory = healthData
              .map((item) => item as Map<String, dynamic>)
              .toList();
          
          // Sort by ID (or created_at if ID is not available)
          _healthHistory.sort((a, b) {
            if (a['id'] != null && b['id'] != null) {
              return (a['id'] as int).compareTo(b['id'] as int);
            } else if (a['created_at'] != null && b['created_at'] != null) {
              return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
            }
            return 0;
          });
        }
      } catch (e) {
        print('Failed to fetch health history: $e');
        _healthHistory = [];
      }

      // Get assigned workout plan
      final workoutResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/plans/workout/assigned',
      );

      if (workoutResponse.data?['status'] == 'success') {
        final workoutData = workoutResponse.data!['data']['assigned_workout'];
        if (workoutData != null) {
          _workoutPlan = workoutData;
          final startDate = DateTime.parse(workoutData['start_date']);
          final now = DateTime.now();
          
          // Calculate days since start by comparing dates only (ignoring time)
          final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
          final nowDateOnly = DateTime(now.year, now.month, now.day);
          final daysSinceStart = nowDateOnly.difference(startDateOnly).inDays;
          
          // If it's the same day as start date, show day 1
          // If it's the next day, show day 2, etc.
          if (daysSinceStart < 0) {
            // If start date is in the future, show day 1
            _currentWorkoutDay = 1;
          } else {
            // Calculate current day (1-based)
            _currentWorkoutDay = daysSinceStart + 1;
            
            // If we've exceeded the plan duration, cycle back
            final duration = workoutData['workout']['duration'];
            if (_currentWorkoutDay > duration) {
              _currentWorkoutDay = ((_currentWorkoutDay - 1) % duration + 1).toInt();
            }
          }
         
        }
      }

      // Get assigned nutrition plan
      final nutritionResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/plans/nutrition/assigned',
      );

      if (nutritionResponse.data?['status'] == 'success') {
        final nutritionData = nutritionResponse.data!['data']['assigned_plan'];
        if (nutritionData != null) {
          _nutritionPlan = nutritionData;
          final startDate = DateTime.parse(nutritionData['start_date']);
          final now = DateTime.now();
          
          // Calculate days since start by comparing dates only (ignoring time)
          final startDateOnly = DateTime(startDate.year, startDate.month, startDate.day);
          final nowDateOnly = DateTime(now.year, now.month, now.day);
          final daysSinceStart = nowDateOnly.difference(startDateOnly).inDays;
          
          // If it's the same day as start date, show day 1
          // If it's the next day, show day 2, etc.
          if (daysSinceStart < 0) {
            // If start date is in the future, show day 1
            _currentNutritionDay = 1;
          } else {
            // Calculate current day (1-based)
            _currentNutritionDay = daysSinceStart + 1;
            
            // If we've exceeded the plan duration, cycle back
            final duration = nutritionData['nutrition']['duration'];
            if (_currentNutritionDay > duration) {
              _currentNutritionDay = ((_currentNutritionDay - 1) % duration + 1).toInt();
            }
          }
        }
      }

      // Get subscribed coach
      try {
        final coachResponse = await httpClient.get<Map<String, dynamic>>(
          '/api/subscription/my-coach',
        );

        if (coachResponse.data?['status'] == 'success') {
          final coachId = coachResponse.data!['data']['coach_id'];
          if (coachId != null) {
            final coachProfileResponse = await httpClient.get<Map<String, dynamic>>(
              '/api/profile/$coachId',
            );

            if (coachProfileResponse.data?['status'] == 'success') {
              _coachProfile = coachProfileResponse.data!['data']['profile'];
            }
          } else {
            _coachProfile = null;
          }
        } else {
          _coachProfile = null;
        }
      } catch (e) {
        // Coach data is optional, so we don't set error state
        print('Failed to fetch coach data: $e');
        _coachProfile = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Alternative method to refresh coach data specifically
  Future<void> _refreshCoachData() async {
    try {
      final httpClient = HttpClient();
      final coachResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/subscription/my-coach',
      );

      if (mounted) {
        setState(() {
          if (coachResponse.data?['status'] == 'success') {
            final coachId = coachResponse.data!['data']['coach_id'];
            if (coachId != null) {
              // We'll fetch the coach profile in a separate call
              _fetchCoachProfile(coachId);
            } else {
              _coachProfile = null;
            }
          } else {
            _coachProfile = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _coachProfile = null;
        });
      }
    }
  }

  Future<void> _fetchCoachProfile(int coachId) async {
    try {
      final httpClient = HttpClient();
      final coachProfileResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/profile/$coachId',
      );

      if (mounted) {
        setState(() {
          if (coachProfileResponse.data?['status'] == 'success') {
            _coachProfile = coachProfileResponse.data!['data']['profile'];
          } else {
            _coachProfile = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _coachProfile = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.mainBackgroundColor,
        statusBarIconBrightness: Brightness.dark, // adjust if needed
      ),
    );
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    // Find current day's exercises
    final currentDayExercises = _workoutPlan?['workout']?['days']
        ?.firstWhere(
          (day) => day['day_number'] == _currentWorkoutDay,
          orElse: () => null,
        )?['exercises'] as List<dynamic>?;

    // Find current day's nutrition
    final currentDayNutrition = _nutritionPlan?['nutrition']?['days']
        ?.firstWhere(
          (day) => day['day_number'] == _currentNutritionDay,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      extendBody: true,
      body: SafeArea(
        bottom: false, // allow content under nav bar
        child: Column(
          children: [
            // Header with profile (keep at full width)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildProfileImage(_traineeProfile),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.goodMorning,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _traineeProfile?['full_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      context.push('/notifications');
                    },
                    icon: Image.asset(
                      'assets/icons/navigation/Notifications.png',
                      width: 28,
                      height: 28,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 120), // allow scrolling above nav bar
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tabs
                      Container(
                        height: 40,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: const UnderlineTabIndicator(
                            borderSide: BorderSide(width: 3.0, color: AppColors.accent),
                            insets: EdgeInsets.symmetric(horizontal: -24),
                          ),
                          indicatorColor: Colors.transparent,
                          labelColor: AppColors.textDark,
                          unselectedLabelColor: AppColors.textDark.withOpacity(0.6),
                          tabs: [
                            Tab(text: l10n.workoutPlans),
                            Tab(text: l10n.nutritionPlans),
                          ],
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          dividerColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tab content
                      Container(
                        height: 80,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Workout plans tab
                            if (_workoutPlan != null && currentDayExercises != null)
                              Row(
                                children: [
                                  // Day cell
                                  Container(
                                    width: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.workout_plans_day,
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: AppTheme.labelColor,
                                          ),
                                        ),
                                        Text(
                                          _currentWorkoutDay.toString(),
                                          style: AppTheme.headerLarge.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Exercises cell
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            spreadRadius: 1,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: currentDayExercises.isNotEmpty
                                                  ? SingleChildScrollView(
                                                      physics: const BouncingScrollPhysics(),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: currentDayExercises.map((exercise) {
                                                          return Padding(
                                                            padding: const EdgeInsets.only(bottom: 4.0),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 8,
                                                                  height: 8,
                                                                  margin: const EdgeInsetsDirectional.only(end: 8),
                                                                  decoration: const BoxDecoration(
                                                                    color: AppColors.accent,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    exercise['exercise']['target_muscle'],
                                                                    style: AppTheme.headerMedium.copyWith(
                                                                      fontSize: 14,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 16.0),
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const BoxDecoration(
                                                color: AppColors.accent,
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  context.push('/trainee/workout-plan-details', extra: {
                                                    'planId': _workoutPlan!['workout']['id'],
                                                    'duration': _workoutPlan!['workout']['duration'],
                                                  });
                                                },
                                                icon: const Icon(
                                                  Icons.arrow_forward,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Center(child: Text(l10n.noWorkoutPlans)),
                            // Nutrition plans tab
                            _nutritionPlan != null
                                ? Row(
                                    children: [
                                      // Day cell
                                      Container(
                                        width: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              l10n.workout_plans_day,
                                              style: AppTheme.bodyMedium.copyWith(
                                                color: AppTheme.labelColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _currentNutritionDay.toString(),
                                              style: AppTheme.headerLarge.copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Meals grid
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            context.push('/trainee/nutrition-plan-details', extra: {
                                              'planId': _nutritionPlan!['nutrition']['id'],
                                              'duration': _nutritionPlan!['nutrition']['duration'],
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  spreadRadius: 1,
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                // Meal content row
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: NutritionPlanLayoutValues.getBreakfastFlex(Directionality.of(context)),
                                                        child: _buildMealCell(
                                                          currentDayNutrition?['breakfast'] ?? '',
                                                          false,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: NutritionPlanLayoutValues.getLunchFlex(Directionality.of(context)),
                                                        child: _buildMealCell(
                                                          currentDayNutrition?['lunch'] ?? '',
                                                          false,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: NutritionPlanLayoutValues.getDinnerFlex(Directionality.of(context)),
                                                        child: _buildMealCell(
                                                          currentDayNutrition?['dinner'] ?? '',
                                                          false,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: NutritionPlanLayoutValues.getSnackFlex(Directionality.of(context)),
                                                        child: _buildMealCell(
                                                          currentDayNutrition?['snacks'] ?? '',
                                                          true,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(child: Text(l10n.noNutritionPlans)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Coach section
                      if (_coachProfile != null) ...[
                        Text(
                          l10n.coach,
                          style: AppTheme.headerSmall,
                        ),
                        const SizedBox(height: 16),
                        // Coach box with badge
                        GestureDetector(
                          onTap: () {
                            if (_coachProfile != null && _coachProfile!['id'] != null) {
                              context.push('/trainee/coach/${_coachProfile!['id']}');
                            }
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    _buildProfileImage(_coachProfile, radius: 25),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        _coachProfile!['full_name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    // Chats icon
                                    GestureDetector(
                                      onTap: () {
                                        context.push(
                                          '/chat/room/${_coachProfile?['id']}',
                                          extra: {
                                            'recipientId': _coachProfile?['id'],
                                            'recipientName': _coachProfile?['full_name'] ?? 'Coach',
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Image.asset(
                                          'assets/icons/navigation/Chats Inactive.png',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                    // Review icon
                                    GestureDetector(
                                      onTap: () {
                                        _showRatingDialog(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Image.asset(
                                          'assets/icons/navigation/Rating.png',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Red X icon (top right badge)
                              Positioned(
                                top: -8,
                                right: -8,
                                child: GestureDetector(
                                  onTap: () {
                                    _showUnsubscribeDialog(context);
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Dashboard title
                      Text(
                        l10n.dashboard,
                        style: AppTheme.headerSmall,
                      ),
                      const SizedBox(height: 16),

                      // Metrics row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMetricItem(
                            iconAsset: 'assets/icons/Weight.png',
                            label: l10n.weightLabel,
                            value: _traineeProfile?['weight']?.toString() ?? '0',
                            unit: l10n.kg,
                          ),
                          _buildMetricItem(
                            iconAsset: 'assets/icons/Height.png',
                            label: l10n.heightLabel,
                            value: _traineeProfile?['height']?.toString() ?? '0',
                            unit: l10n.cm,
                          ),
                          _buildMetricItem(
                            iconAsset: 'assets/icons/Fats.png',
                            label: l10n.fatsLabel,
                            value: _traineeProfile?['body_fat']?.toString() ?? '0',
                            unit: l10n.percentSymbol,
                          ),
                          _buildMetricItem(
                            iconAsset: 'assets/icons/Muscle.png',
                            label: l10n.muscleLabel,
                            value: _traineeProfile?['body_muscle']?.toString() ?? '0',
                            unit: l10n.percentSymbol,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Health Graph Section
                      _HealthGraphSection(
                        currentFat: double.tryParse(_traineeProfile?['body_fat']?.toString() ?? '0') ?? 0,
                        currentWeight: double.tryParse(_traineeProfile?['weight']?.toString() ?? '0') ?? 0,
                        currentMuscle: double.tryParse(_traineeProfile?['body_muscle']?.toString() ?? '0') ?? 0,
                        healthHistory: _healthHistory,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 2, // Home tab
      ),
    );
  }

  Widget _buildMetricItem({
    String? iconAsset,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: iconAsset != null
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(iconAsset, fit: BoxFit.contain),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTheme.bodySmall,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCell(String meal, bool isLast) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: meal.isEmpty
                ? const SizedBox()
                : Text(
                    meal,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
            ),
          ),
          if (!isLast) Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 1,
            color: AppColors.background,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(Map<String, dynamic>? profile, {double radius = 30}) {
    String? imageUrl = profile?['image_url'] as String?;
    String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
        : null;
    return CircleAvatar(
      radius: radius,
      backgroundImage: fullUrl != null
          ? NetworkImage(fullUrl)
          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
    );
  }

  void _showUnsubscribeDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsubscribeTitle),
        content: Text(l10n.unsubscribeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _unsubscribeFromCoach(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _unsubscribeFromCoach(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final httpClient = HttpClient();
      final response = await httpClient.patch<Map<String, dynamic>>(
        '/api/subscription/unsubscribe',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      
      if (response.data?['status'] == 'success') {
        // Immediately clear the coach data and update UI
        if (mounted) {
          setState(() {
            _coachProfile = null;
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unsubscribeSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 16,
              right: 16,
            ),
          ),
        );
        
        // Optionally refresh all data in the background
        _refreshCoachData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?['message'] ?? l10n.unsubscribeError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unsubscribeError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
            left: 16,
            right: 16,
          ),
        ),
      );
    }
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _RatingDialog(
        coachName: _coachProfile?['full_name'] ?? '',
        coachId: _coachProfile?['id'],
        onRatingSubmitted: (rating, review) async {
          await _submitReview(context, rating, review);
        },
      ),
    );
  }

  Future<void> _submitReview(BuildContext context, int rating, String review) async {
    final l10n = AppLocalizations.of(context)!;
    final coachId = _coachProfile?['id'];
    
    if (coachId == null) {
      _showFeedbackDialog(context, l10n.reviewError, false);
      return;
    }

    try {
      final httpClient = HttpClient();
      final response = await httpClient.post<Map<String, dynamic>>(
        '/api/review/create',
        data: {
          'rating': rating.toString(),
          'comment': review,
          'coach_id': coachId.toString(),
        },
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      if (response.data?['status'] == 'success') {
        _showFeedbackDialog(context, l10n.reviewSuccess, true);
      } else {
        // Check for specific error message about already reviewed
        final errorMessage = response.data?['message'] ?? '';
        String displayMessage;
        
        if (errorMessage.contains('already made a review') || 
            errorMessage.contains('already reviewed')) {
          displayMessage = l10n.reviewAlreadySubmitted;
        } else {
          displayMessage = errorMessage.isNotEmpty ? errorMessage : l10n.reviewError;
        }
        
        _showFeedbackDialog(context, displayMessage, false);
      }
    } catch (e) {
      _showFeedbackDialog(context, l10n.reviewError, false);
    }
  }

  void _showFeedbackDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mainBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? 'Success' : 'Error',
              style: AppTheme.headerSmall.copyWith(
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: AppTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _HealthGraphSection extends StatefulWidget {
  final double currentFat;
  final double currentWeight;
  final double currentMuscle;
  final List<Map<String, dynamic>> healthHistory;

  const _HealthGraphSection({
    required this.currentFat,
    required this.currentWeight,
    required this.currentMuscle,
    required this.healthHistory,
  });

  @override
  State<_HealthGraphSection> createState() => _HealthGraphSectionState();
}

class _HealthGraphSectionState extends State<_HealthGraphSection> {
  int selectedMetric = 0; // 0: Fats, 1: Weight, 2: Muscle
  int selectedBar = 0; // Default to first bar

  static const double _graphHeight = 130; // increased to fit chip

  List<double> getHealthData(int metric) {
    List<double> data = [];
    
    // Add historical data
    for (var healthRecord in widget.healthHistory) {
      switch (metric) {
        case 0: // Fats
          data.add(double.tryParse(healthRecord['body_fat']?.toString() ?? '0') ?? 0);
          break;
        case 1: // Weight
          data.add(double.tryParse(healthRecord['weight']?.toString() ?? '0') ?? 0);
          break;
        case 2: // Muscle
          data.add(double.tryParse(healthRecord['body_muscle']?.toString() ?? '0') ?? 0);
          break;
      }
    }
    
    // Add current data
    switch (metric) {
      case 0:
        data.add(widget.currentFat);
        break;
      case 1:
        data.add(widget.currentWeight);
        break;
      case 2:
        data.add(widget.currentMuscle);
        break;
    }
    
    // If no data, return current value only
    if (data.isEmpty) {
      switch (metric) {
        case 0:
          return [widget.currentFat];
        case 1:
          return [widget.currentWeight];
        case 2:
          return [widget.currentMuscle];
        default:
          return [0];
      }
    }
    
    return data;
  }

  List<String> getMonthLabels() {
    List<String> labels = [];
    
    // Add historical month labels
    for (var healthRecord in widget.healthHistory) {
      try {
        final date = DateTime.parse(healthRecord['created_at']);
        labels.add(_getMonthAbbreviation(date.month));
      } catch (e) {
        labels.add('N/A');
      }
    }
    
    // Add current month label
    final now = DateTime.now();
    labels.add(_getMonthAbbreviation(now.month));
    
    return labels;
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return 'N/A';
    }
  }

  String getMetricLabel(int metric, AppLocalizations l10n) {
    switch (metric) {
      case 0:
        return l10n.currentFatPercentage;
      case 1:
        return l10n.bodyWeight;
      case 2:
        return l10n.bodyMuscle;
      default:
        return '';
    }
  }

  String getMetricUnit(int metric, AppLocalizations l10n) {
    switch (metric) {
      case 0:
        return l10n.percentSymbol;
      case 1:
        return l10n.kg;
      case 2:
        return l10n.percentSymbol;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = getHealthData(selectedMetric);
    final currentValue = data.isNotEmpty ? data.last : 0;
    final metricLabel = getMetricLabel(selectedMetric, l10n);
    final metricUnit = getMetricUnit(selectedMetric, l10n);
    final metricNames = [l10n.fatsLabel, l10n.weightLabel, l10n.muscleLabel];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D122A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metric selector buttons
          Row(
            children: List.generate(3, (i) {
              final isSelected = selectedMetric == i;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMetric = i;
                      selectedBar = data.length - 1; // Reset to last bar (current value)
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accent : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      metricNames[i],
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected ? Colors.black : AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // Top left label (localized)
          Text(
            metricLabel,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 4),
          // Current value (always last bar)
          Text(
            '$currentValue$metricUnit',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),
          // Graph
          Column(
            children: [
              SizedBox(
                height: _graphHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (index) {
                    final isSelected = selectedBar == index;
                    final max = data.reduce((a, b) => a > b ? a : b);
                    final min = data.reduce((a, b) => a < b ? a : b);
                    
                    // Improved height calculation with better normalization
                    double barHeight;
                    if (max == min) {
                      barHeight = 0.7; // Default height when all values are the same
                    } else {
                      // Calculate normalized value (0 to 1)
                      final normalizedValue = (data[index] - min) / (max - min);
                      
                      // Apply a power function to amplify small differences
                      // Using power of 0.7 to make differences more visible
                      final amplifiedValue = pow(normalizedValue, 0.7);
                      
                      // Map to height range (0.3 to 1.0)
                      barHeight = 0.3 + (0.7 * amplifiedValue);
                    }
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBar = index;
                        });
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 30,
                            height: (_graphHeight - 30) * barHeight,
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accent : const Color(0xFF434E81),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: -38,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  '${data[index]}$metricUnit',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              // Month labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: getMonthLabels().map((month) {
                  return SizedBox(
                    width: 30,
                    child: Text(
                      month,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingDialog extends StatefulWidget {
  final String coachName;
  final int coachId;
  final Function(int rating, String review) onRatingSubmitted;

  const _RatingDialog({
    required this.coachName,
    required this.coachId,
    required this.onRatingSubmitted,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppTheme.mainBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            // Header with title and close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.rateCoach,
                    style: AppTheme.headerSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            
            // Coach name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.coachName,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Star rating
            Directionality(
              textDirection: TextDirection.ltr, // Keep stars LTR even in Arabic
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: index < _rating ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Review text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.writeReview,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            
            const Spacer(),
            
            // Save button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_rating > 0) {
                        Navigator.of(context).pop(); // Close dialog first
                        widget.onRatingSubmitted(_rating, _reviewController.text);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _rating > 0 ? AppTheme.primary : Colors.grey,
                      foregroundColor: _rating > 0 ? AppTheme.textLight : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      l10n.save,
                      style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textLight),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
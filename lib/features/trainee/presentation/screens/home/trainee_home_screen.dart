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
  int _currentWorkoutDay = 1;
  int _currentNutritionDay = 1;

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
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                      context.push('/trainee/notifications');
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
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  for (var exercise in currentDayExercises)
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 8,
                                                          height: 8,
                                                          margin: const EdgeInsets.only(right: 8),
                                                          decoration: const BoxDecoration(
                                                            color: AppColors.accent,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                        Text(
                                                          exercise['exercise']['target_muscle'],
                                                          style: AppTheme.headerMedium.copyWith(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
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
          decoration: BoxDecoration(
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
}

class _HealthGraphSection extends StatefulWidget {
  final double currentFat;
  final double currentWeight;
  final double currentMuscle;
  const _HealthGraphSection({
    required this.currentFat,
    required this.currentWeight,
    required this.currentMuscle,
  });

  @override
  State<_HealthGraphSection> createState() => _HealthGraphSectionState();
}

class _HealthGraphSectionState extends State<_HealthGraphSection> {
  int selectedMetric = 0; // 0: Fats, 1: Weight, 2: Muscle
  int selectedBar = 6; // Last bar is current value

  static const double _graphHeight = 130; // increased to fit chip

  List<double> getMockData(int metric) {
    // 6 mock values + 1 real value
    switch (metric) {
      case 0:
        return [19.2, 18.9, 18.7, 18.5, 18.4, 18.3, widget.currentFat];
      case 1:
        return [72.0, 71.8, 71.5, 71.2, 71.0, 70.8, widget.currentWeight];
      case 2:
        return [28.0, 28.2, 28.4, 28.6, 28.8, 29.0, widget.currentMuscle];
      default:
        return [0, 0, 0, 0, 0, 0, 0];
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
    final data = getMockData(selectedMetric);
    final currentValue = data.last;
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
                      selectedBar = 6; // Reset to last bar (current value)
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
          SizedBox(
            height: _graphHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isSelected = selectedBar == index;
                final max = data.reduce((a, b) => a > b ? a : b);
                final min = data.reduce((a, b) => a < b ? a : b);
                final barHeight = max == min ? 0.7 : 0.3 + 0.7 * ((data[index] - min) / (max - min));
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
        ],
      ),
    );
  }
}
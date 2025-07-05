import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'dart:math';
import './exercise_details_screen.dart';

class WorkoutPlanDetailsScreen extends StatefulWidget {
  final int planId;
  final int duration;

  const WorkoutPlanDetailsScreen({
    super.key,
    required this.planId,
    required this.duration,
  });

  @override
  State<WorkoutPlanDetailsScreen> createState() => _WorkoutPlanDetailsScreenState();
}

class _WorkoutPlanDetailsScreenState extends State<WorkoutPlanDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final int _totalPages;
  Map<String, dynamic>? _workoutPlan;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _totalPages = (widget.duration / 5).ceil();
    _loadWorkoutPlan();
  }

  Future<void> _loadWorkoutPlan() async {
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get<Map<String, dynamic>>(
        '/api/plans/workout/assigned',
      );

      if (response.data?['status'] == 'success') {
        setState(() {
          _workoutPlan = response.data!['data']['assigned_workout']['workout'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.data?['message'] ?? 'Failed to load workout plan';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ExerciseItem> _getExercisesForDay(List<dynamic> exercises) {
    return exercises.map((exercise) {
      final exerciseData = exercise['exercise'];
      return ExerciseItem(
        name: exerciseData['title'],
        animationPath: exerciseData['animation'],
        id: exerciseData['id'],
        sets: exercise['sets'],
        reps: exercise['reps'],
        restTime: exercise['rest_time'],
        notes: exercise['notes'],
        videoUrl: exercise['video_url'],
      );
    }).toList();
  }

  void _handleDayTap(Map<String, dynamic> dayData) {
    if (dayData['exercises']?.isEmpty ?? true) return;

    final exercises = _getExercisesForDay(dayData['exercises']);
    final dayNumber = dayData['day_number'];
    final dayId = dayData['id'];
    
    context.go('/trainee/workout/exercise-details', extra: {
      'dayNumber': dayNumber,
      'dayId': dayId,
      'workoutId': widget.planId,
      'exercises': exercises,
      'muscleGroup': 'Day $dayNumber',
    });
  }

  // Helper method to get unique target muscles for a day
  List<String> _getUniqueMusclesForDay(List<dynamic> exercises) {
    final muscles = exercises
        .map((exercise) => exercise['exercise']['target_muscle'] as String)
        .toSet()
        .toList();
    return muscles;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate cell height based on screen size
    final availableHeight = screenHeight - 
        kToolbarHeight -  // AppBar
        140 -            // Title section (including padding)
        kBottomNavigationBarHeight - 
        100 -           // Page indicator section
        32;            // Extra padding
    
    final cellHeight = (availableHeight / 5).clamp(80.0, 100.0);  // Min 80, max 100

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.mainBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Colors.grey,
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadWorkoutPlan,
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (_workoutPlan == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Plan Not Found'),
        ),
        body: const Center(
          child: Text('Could not find the workout plan'),
        ),
      );
    }

    final totalHeight = min(widget.duration, 5) * cellHeight;

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.plansTitle,
          style: AppTheme.bodyMedium,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _workoutPlan!['title'],
                              style: AppTheme.headerLarge.copyWith(
                                color: AppTheme.textDark
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.visible,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.planDurationPrefix,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.labelColor,
                            ),
                          ),
                          Text(
                            '${widget.duration} ${l10n.workout_plans_days}',
                            style: AppTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: PageView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (page) => setState(() => _currentPage = page),
                      itemCount: _totalPages,
                      itemBuilder: (context, pageIndex) {
                        return GestureDetector(
                          onHorizontalDragEnd: (details) {
                            final isRTL = Directionality.of(context) == TextDirection.rtl;
                            final velocity = isRTL ? -details.primaryVelocity! : details.primaryVelocity!;
                            
                            if (velocity > 0 && _currentPage > 0) {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else if (velocity < 0 && _currentPage < _totalPages - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            children: [
                              // Days Column
                              Container(
                                width: 80,
                                height: totalHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.zero,
                                  itemCount: 5,
                                  itemBuilder: (context, i) {
                                    final dayNumber = pageIndex * 5 + i + 1;
                                    if (dayNumber > widget.duration) return const SizedBox.shrink();
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: cellHeight,
                                          child: Center(
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
                                                  dayNumber.toString(),
                                                  style: AppTheme.headerLarge.copyWith(
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (i < 4 && dayNumber < widget.duration)
                                          const Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: AppColors.background,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Exercises Column
                              Expanded(
                                child: Container(
                                  height: totalHeight,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.zero,
                                    itemCount: 5,
                                    itemBuilder: (context, i) {
                                      final dayNumber = pageIndex * 5 + i + 1;
                                      if (dayNumber > widget.duration) return const SizedBox.shrink();
                                      
                                      final dayData = _workoutPlan!['days'].firstWhere(
                                        (day) => day['day_number'] == dayNumber,
                                        orElse: () => {'exercises': []},
                                      );
                                      
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => _handleDayTap(dayData),
                                            child: SizedBox(
                                              height: cellHeight,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          if (dayData['exercises']?.isNotEmpty ?? false)
                                                            ..._getUniqueMusclesForDay(dayData['exercises']).map((muscle) {
                                                              return Row(
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
                                                                    muscle,
                                                                    style: AppTheme.headerMedium.copyWith(
                                                                      fontSize: 14,
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            }).toList(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (dayData['exercises']?.isNotEmpty ?? false)
                                                    const Padding(
                                                      padding: EdgeInsets.only(right: 16.0),
                                                      child: Icon(
                                                        Icons.chevron_right,
                                                        color: AppColors.primary,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (i < 4)
                                            const Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: AppColors.background,
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _currentPage > 0
                            ? () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                            : null,
                        icon: const Icon(Icons.chevron_left),
                        color: _currentPage > 0 && _totalPages > 1 ? AppColors.primary : Colors.grey,
                      ),
                      Text(
                        '${_currentPage + 1}/$_totalPages',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        onPressed: _currentPage < _totalPages - 1
                            ? () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                            : null,
                        icon: const Icon(Icons.chevron_right),
                        color: _currentPage < _totalPages - 1 && _totalPages > 1 ? AppColors.primary : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
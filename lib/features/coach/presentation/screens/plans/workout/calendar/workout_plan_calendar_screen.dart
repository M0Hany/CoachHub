import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../providers/workout/workout_plan_provider.dart';
import '../../../../../data/models/workout/workout_plan_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../muscle/muscle_selection_screen.dart';
import '../../../../../../../l10n/app_localizations.dart';

class WorkoutPlanCalendarScreen extends StatefulWidget {
  final int planId;
  final int duration;

  const WorkoutPlanCalendarScreen({
    super.key,
    required this.planId,
    required this.duration,
  });

  @override
  State<WorkoutPlanCalendarScreen> createState() => _WorkoutPlanCalendarScreenState();
}

class _WorkoutPlanCalendarScreenState extends State<WorkoutPlanCalendarScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final int _totalPages;
  late final WorkoutPlanProvider _workoutProvider;

  @override
  void initState() {
    super.initState();
    print('WorkoutPlanCalendarScreen: initState called with planId: ${widget.planId}');
    _totalPages = (widget.duration / 5).ceil();
    print('WorkoutPlanCalendarScreen: Total pages calculated: $_totalPages');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _workoutProvider = context.read<WorkoutPlanProvider>();
    _initializeWorkoutPlan();
  }

  Future<void> _initializeWorkoutPlan() async {
    print('WorkoutPlanCalendarScreen: _initializeWorkoutPlan started for planId: ${widget.planId}');
    try {
      print('WorkoutPlanCalendarScreen: Calling fetchWorkoutPlanDetails with planId: ${widget.planId}');
      _workoutProvider.setWorkoutId(widget.planId);
      await _workoutProvider.fetchWorkoutPlanDetails(widget.planId);
      print('WorkoutPlanCalendarScreen: Successfully fetched plan details');
      
      // Log the fetched plan details
      final plan = _workoutProvider.workoutPlan;
      print('WorkoutPlanCalendarScreen: Fetched plan details:');
      print('  - Plan ID: ${plan?.id}');
      print('  - Title: ${plan?.title}');
      print('  - Duration: ${plan?.duration}');
      print('  - Number of days: ${plan?.days.length}');
      if (plan?.days != null) {
        for (var day in plan!.days) {
          print('  - Day ${day.dayNumber}: ${day.muscleGroups.map((g) => g.name).join(', ')}');
        }
      }
    } catch (e) {
      print('WorkoutPlanCalendarScreen: Error fetching plan details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workout plan: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _initializeWorkoutPlan,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    print('WorkoutPlanCalendarScreen: dispose called');
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<WorkoutPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('Loading Plan...'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: const Text('Error'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      _initializeWorkoutPlan();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final workoutPlan = provider.workoutPlan;
        if (workoutPlan == null) {
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
                bottom: false,
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
                                  workoutPlan.title,
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
                                    height: min(widget.duration, 5) * 100.0,
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
                                              height: 100,
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
                                      height: min(widget.duration, 5) * 100.0,
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
                                          
                                          final dayData = workoutPlan.days.firstWhere(
                                            (day) => day.dayNumber == dayNumber,
                                            orElse: () => WorkoutDay(dayNumber: dayNumber, muscleGroups: []),
                                          );
                                          
                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onTap: () {
                                                  provider.selectDay(dayNumber - 1);
                                                  context.push('/coach/plans/workout/muscles', extra: {
                                                    'day_number': dayNumber,
                                                  });
                                                },
                                                child: SizedBox(
                                                  height: 100,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              if (dayData.muscleGroups.isNotEmpty)
                                                                ...dayData.muscleGroups.map((group) {
                                                                  return Row(
                                                                    children: [
                                                                      Container(
                                                                        width: 8,
                                                                        height: 8,
                                                                        margin: const EdgeInsets.only(right: 8),
                                                                        decoration: BoxDecoration(
                                                                          color: AppColors.accent,
                                                                          shape: BoxShape.circle,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        group.name,
                                                                        style: AppTheme.headerMedium.copyWith(
                                                                          fontSize: 14,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  );
                                                                })
                                                            ],
                                                          ),
                                                        ),
                                                      ),
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
                      padding: const EdgeInsets.only(bottom: 100),
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
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: const BottomNavBar(role: UserRole.coach, currentIndex: 0),
              ),
            ],
          ),
        );
      },
    );
  }
} 
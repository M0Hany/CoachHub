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
import '../../../../../../../core/network/http_client.dart';

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
  WorkoutPlanProvider? _workoutProvider;
  bool _isInitialized = false;
  bool _isDisposed = false;

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
    
    // Check if we need to reinitialize (e.g., plan ID changed)
    final currentPlanId = _workoutProvider?.workoutId;
    if (currentPlanId != widget.planId) {
      _isInitialized = false;
    }
    
    // Use WidgetsBinding.instance.addPostFrameCallback to avoid calling during build
    if (!_isInitialized && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          _initializeWorkoutPlan();
        }
      });
    }
  }

  Future<void> _initializeWorkoutPlan() async {
    if (_isInitialized || _isDisposed || _workoutProvider == null) {
      print('WorkoutPlanCalendarScreen: Already initialized, disposed, or provider is null, skipping');
      return;
    }
    
    print('WorkoutPlanCalendarScreen: _initializeWorkoutPlan started for planId: ${widget.planId}');
    try {
      print('WorkoutPlanCalendarScreen: Calling fetchWorkoutPlanDetails with planId: ${widget.planId}');
      _workoutProvider!.setWorkoutId(widget.planId);
      await _workoutProvider!.fetchWorkoutPlanDetails(widget.planId);
      print('WorkoutPlanCalendarScreen: Successfully fetched plan details');
      
      // Log the fetched plan details
      final plan = _workoutProvider!.workoutPlan;
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
      
      _isInitialized = true;
    } catch (e) {
      print('WorkoutPlanCalendarScreen: Error fetching plan details: $e');
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load workout plan: ${e.toString()}'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                if (!_isDisposed) {
                  _isInitialized = false;
                  _initializeWorkoutPlan();
                }
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmationDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.deletePlan),
          content: Text(l10n.deletePlanConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancel),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: Text(
                l10n.delete,
                style: const TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                try {
                  Navigator.of(dialogContext).pop();
                  await context.read<WorkoutPlanProvider>().deletePlan(widget.planId);
                  if (mounted) {
                    context.go('/coach/plans');
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    print('WorkoutPlanCalendarScreen: dispose called');
    _isDisposed = true;
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate cell height based on screen size
    // We subtract the appBar height, title section height, bottom nav height, and some padding
    final availableHeight = screenHeight - 
        kToolbarHeight -  // AppBar
        140 -            // Title section (including padding)
        kBottomNavigationBarHeight - 
        100 -           // Page indicator section
        32;            // Extra padding
    
    final cellHeight = (availableHeight / 5).clamp(80.0, 100.0);  // Min 80, max 100
    final totalHeight = min(widget.duration, 5) * cellHeight;

    return Consumer<WorkoutPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
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

        if (provider.error != null) {
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
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: _showDeleteConfirmationDialog,
              ),
            ],
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
                                                  // Extract muscle group names from the day data
                                                  final selectedMuscles = dayData.muscleGroups.map((group) => group.name).toList();
                                                  print('WorkoutPlanCalendarScreen: Selected muscles passed: ${selectedMuscles}');
                                                  context.push('/coach/plans/workout/muscles', extra: {
                                                    'day_number': dayNumber,
                                                    'selected_muscles': selectedMuscles,
                                                  });
                                                },
                                                child: SizedBox(
                                                  height: cellHeight,
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: dayData.muscleGroups.isNotEmpty
                                                              ? SingleChildScrollView(
                                                                  physics: const BouncingScrollPhysics(),
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: dayData.muscleGroups.map((group) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets.only(bottom: 4.0),
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            _showExercisesDialog(context, group, dayNumber);
                                                                          },
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
                                                                                  group.name,
                                                                                  style: AppTheme.headerMedium.copyWith(
                                                                                    fontSize: 14,
                                                                                  ),
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }).toList(),
                                                                  ),
                                                                )
                                                              : const SizedBox.shrink(),
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
                child: const BottomNavBar(role: UserRole.coach),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showExercisesDialog(BuildContext context, MuscleGroup muscleGroup, int dayNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day $dayNumber - ${muscleGroup.name}',
                              style: AppTheme.headerLarge.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${muscleGroup.exercises.length} exercises',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // Exercises List
                Expanded(
                  child: muscleGroup.exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: Colors.grey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No exercises added yet',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
                            ),
                            child: Stack(
                              children: [
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    scrollbarTheme: ScrollbarThemeData(
                                      thumbColor: MaterialStateProperty.all(AppColors.accent),
                                    ),
                                  ),
                                  child: Scrollbar(
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                                      itemCount: muscleGroup.exercises.length,
                                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final exercise = muscleGroup.exercises[index];
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 4,
                                            ),
                                            leading: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: const  BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.accent,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.fitness_center,
                                                  color: AppColors.primary,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              exercise.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${exercise.sets} sets × ${exercise.reps} reps',
                                                  style: AppTheme.bodySmall.copyWith(
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                if (exercise.restTime > 0)
                                                  Text(
                                                    'Rest: ${exercise.restTime}s',
                                                    style: AppTheme.bodySmall.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                if (exercise.note != null && exercise.note!.isNotEmpty)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      'Note: ${exercise.note}',
                                                      style: AppTheme.bodySmall.copyWith(
                                                        color: Colors.grey[600],
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            subtitleTextStyle: AppTheme.bodySmall,
                                            isThreeLine: exercise.note != null && exercise.note!.isNotEmpty,
                                            trailing: IconButton(
                                              onPressed: () => _showDeleteExerciseConfirmation(
                                                context,
                                                exercise,
                                                muscleGroup,
                                                dayNumber,
                                              ),
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Gradient overlays
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  height: 24,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteExerciseConfirmation(
    BuildContext context,
    Exercise exercise,
    MuscleGroup muscleGroup,
    int dayNumber,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text('Delete Exercise'),
            ],
          ),
          content: Text(
            'Are you sure you want to delete "${exercise.name}" from Day $dayNumber - ${muscleGroup.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteExercise(exercise, muscleGroup, dayNumber);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteExercise(
    Exercise exercise,
    MuscleGroup muscleGroup,
    int dayNumber,
  ) async {
    if (_isDisposed) {
      print('WorkoutPlanCalendarScreen: Cannot delete exercise - widget is disposed');
      return;
    }
    
    try {
      final provider = context.read<WorkoutPlanProvider>();
      final workoutId = provider.workoutId;
      
      if (workoutId == null) {
        throw Exception('No workout ID available');
      }

      // Call the API to delete the exercise
      final httpClient = HttpClient();
      final response = await httpClient.put<Map<String, dynamic>>(
        '/api/plans/workout/$workoutId',
        data: {
          'title': provider.workoutPlan?.title ?? 'Workout Plan',
          'days': [
            {
              'day_number': dayNumber,
              'add_exercises': [],
              'remove_exercise_ids': [exercise.id ?? 0],
              'update_exercises': [],
            }
          ]
        },
      );

      if (response.data?['status'] == 'success') {
        // Update local state immediately
        provider.removeExerciseFromDay(dayNumber - 1, muscleGroup.name, exercise.name);
        
        // Close the exercises dialog if it's open
        if (mounted && !_isDisposed && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        
        // Show success message
        if (mounted && !_isDisposed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Exercise "${exercise.name}" deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to delete exercise');
      }
    } catch (e) {
      print('Error deleting exercise: $e');
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting exercise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 
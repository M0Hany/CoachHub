import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../providers/workout/workout_plan_provider.dart';
import '../../providers/nutrition/nutrition_plan_provider.dart';
import 'workout/calendar/workout_plan_calendar_screen.dart';

class CoachPlansScreen extends StatefulWidget {
  const CoachPlansScreen({super.key});

  @override
  State<CoachPlansScreen> createState() => _CoachPlansScreenState();
}

class _CoachPlansScreenState extends State<CoachPlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _fetchPlans();
    }
  }

  Future<void> _fetchPlans() async {
    final workoutProvider = context.read<WorkoutPlanProvider>();
    final nutritionProvider = context.read<NutritionPlanProvider>();
    await workoutProvider.fetchWorkoutPlans();
    await nutritionProvider.fetchNutritionPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer<WorkoutPlanProvider>(
      builder: (context, workoutProvider, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: AppTheme.mainBackgroundColor,
            body: Stack(
              children: [
                Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Text(
                        l10n.plansTitle,
                        style: AppTheme.bodyMedium,
                      ),
                      centerTitle: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                      child: Container(
                        height: 45,
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
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildWorkoutPlansTab(),
                          _buildNutritionPlansTab(),
                        ],
                      ),
                    ),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BottomNavBar(
                    role: UserRole.coach,
                    currentIndex: 0, // Plans tab
                  ),
                ),
              ],
            ),
            floatingActionButton: Padding(
              padding: EdgeInsets.only(bottom: kBottomNavigationBarHeight - bottomPadding + 40),
              child: FloatingActionButton(
                onPressed: () {
                  if (_tabController.index == 0) {
                    context.push('/coach/plans/create-workout');
                  } else {
                    context.push('/coach/plans/create-nutrition');
                  }
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: AppColors.textLight),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutPlansTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<WorkoutPlanProvider>(
      builder: (context, workoutProvider, child) {
        if (workoutProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (workoutProvider.error != null) {
          return Center(
            child: Text(
              workoutProvider.error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          );
        }

        final plans = workoutProvider.savedPlans;
        if (plans.isEmpty) {
          return Center(
            child: Text(
              l10n.noWorkoutPlans,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: kBottomNavigationBarHeight + 32, // Add extra padding at bottom
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListTile(
                title: Text(plan.title),
                subtitle: Text('${plan.duration} days'),
                onTap: () async {
                  final planId = plan.id;
                  if (planId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid plan ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  workoutProvider.setWorkoutId(planId);
                  await context.push(
                    '/coach/plans/workout/calendar',
                    extra: {
                      'planId': planId,
                      'duration': plan.duration,
                    },
                  );
                  // Refresh plans list when returning from calendar screen
                  _fetchPlans();
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNutritionPlansTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<NutritionPlanProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Text(
              provider.error!,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          );
        }

        final plans = provider.savedPlans;
        if (plans.isEmpty) {
          return Center(
            child: Text(
              l10n.noNutritionPlans,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: kBottomNavigationBarHeight + 32, // Add extra padding at bottom
          ),
          itemCount: plans.length,
          itemBuilder: (context, index) {
            final plan = plans[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListTile(
                title: Text(plan.title),
                subtitle: Text('${plan.duration} days'),
                onTap: () async {
                  final planId = plan.id;
                  if (planId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invalid plan ID'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  provider.setNutritionPlanId(planId);
                  context.push(
                    '/coach/plans/nutrition/calendar',
                    extra: {
                      'planId': planId,
                      'duration': plan.duration,
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
} 
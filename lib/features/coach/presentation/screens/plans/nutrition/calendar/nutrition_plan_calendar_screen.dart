import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../providers/nutrition/nutrition_plan_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../l10n/app_localizations.dart';

// Language-specific layout values
class NutritionPlanLayoutValues {
  // English (LTR) values
  static const ltrBreakfastFlex = 5;
  static const ltrLunchFlex = 4;
  static const ltrDinnerFlex = 4;
  static const ltrSnackFlex = 4;


  // Arabic (RTL) values - starting with same values as English, adjust as needed
  static const rtlBreakfastFlex = 5;
  static const rtlLunchFlex = 5;
  static const rtlDinnerFlex = 5;
  static const rtlSnackFlex = 5;


  // Get values based on text direction
  static int getBreakfastFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrBreakfastFlex : rtlBreakfastFlex;
  static int getLunchFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrLunchFlex : rtlLunchFlex;
  static int getDinnerFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrDinnerFlex : rtlDinnerFlex;
  static int getSnackFlex(TextDirection direction) =>
      direction == TextDirection.ltr ? ltrSnackFlex : rtlSnackFlex;
}

class NutritionPlanCalendarScreen extends StatefulWidget {
  const NutritionPlanCalendarScreen({super.key});

  @override
  State<NutritionPlanCalendarScreen> createState() => _NutritionPlanCalendarScreenState();
}

class _NutritionPlanCalendarScreenState extends State<NutritionPlanCalendarScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  static const int daysPerPage = 5;
  int? _planId;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) {
        final planId = extra['planId'] as int?;
        if (planId != null) {
          _planId = planId;
          final provider = context.read<NutritionPlanProvider>();
          provider.setNutritionPlanId(planId);
        }
      }
    });
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
                Navigator.of(dialogContext).pop();
                try {
                  if (_planId != null) {
                    await context.read<NutritionPlanProvider>().deletePlan(_planId!);
                    if (mounted) {
                      context.go('/coach/plans'); // Go back to plans list
                    }
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

    return Consumer<NutritionPlanProvider>(
      builder: (context, provider, child) {
        final plan = provider.nutritionPlan;
        if (plan == null) {
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
            body: Center(child: Text(l10n.noPlanData)),
          );
        }

        final totalHeight = min(daysPerPage, plan.duration - (_currentPage * daysPerPage)) * cellHeight;
        final totalPages = (plan.duration / daysPerPage).ceil();

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
                                  plan.title,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.headerLarge.copyWith(
                                    color: AppTheme.textDark,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                                '${plan.duration} ${l10n.workout_plans_days}',
                                style: AppTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _pageController,
                        onPageChanged: (page) {
                          setState(() => _currentPage = page);
                          provider.setCurrentDayPage(page);
                        },
                        itemCount: totalPages,
                        itemBuilder: (context, pageIndex) {
                          return GestureDetector(
                            onHorizontalDragEnd: (details) {
                              final isRTL = Directionality.of(context) == TextDirection.rtl;
                              // For RTL: positive velocity means swipe left, negative means swipe right
                              // For LTR: positive velocity means swipe right, negative means swipe left
                              final velocity = isRTL ? -details.primaryVelocity! : details.primaryVelocity!;
                              
                              if (velocity > 0 && _currentPage > 0) {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else if (velocity < 0 && _currentPage < totalPages - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Column(
                                children: [
                                  // Headers and Calendar grid in a Column
                                  Column(
                                    children: [
                                      // Headers row with container to ensure alignment
                                      Container(
                                        height: 32,  // Fixed height for header
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 60),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  // Breakfast
                                                  Expanded(
                                                    flex: NutritionPlanLayoutValues.getBreakfastFlex(Directionality.of(context)),
                                                    child: Center(
                                                      child: Text(
                                                        l10n.breakfast,
                                                        style: AppTheme.bodySmall,
                                                      ),
                                                    ),
                                                  ),
                                                  // Lunch
                                                  Expanded(
                                                    flex: NutritionPlanLayoutValues.getLunchFlex(Directionality.of(context)),
                                                    child: Center(
                                                      child: Text(
                                                        l10n.lunch,
                                                        style: AppTheme.bodySmall,
                                                      ),
                                                    ),
                                                  ),
                                                  // Dinner
                                                  Expanded(
                                                    flex: NutritionPlanLayoutValues.getDinnerFlex(Directionality.of(context)),
                                                    child: Center(
                                                      child: Text(
                                                        l10n.dinner,
                                                        style: AppTheme.bodySmall,
                                                      ),
                                                    ),
                                                  ),
                                                  // Snack
                                                  Expanded(
                                                    flex: NutritionPlanLayoutValues.getSnackFlex(Directionality.of(context)),
                                                    child: Center(
                                                      child: Text(
                                                        l10n.snack,
                                                        style: AppTheme.bodySmall,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Calendar grid
                                      Row(
                                        children: [
                                          // Days column
                                          Container(
                                            width: 60,
                                            height: totalHeight,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: ListView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemCount: daysPerPage,
                                              itemBuilder: (context, i) {
                                                final dayNumber = pageIndex * daysPerPage + i + 1;
                                                if (dayNumber > plan.duration) return const SizedBox.shrink();
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
                                                    if (i < daysPerPage - 1 && dayNumber < plan.duration)
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
                                          // Meals grid
                                          Expanded(
                                            child: Container(
                                              height: totalHeight,
                                              margin: const EdgeInsets.symmetric(horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: ListView.builder(
                                                physics: const NeverScrollableScrollPhysics(),
                                                padding: EdgeInsets.zero,
                                                itemCount: daysPerPage,
                                                itemBuilder: (context, i) {
                                                  final dayNumber = pageIndex * daysPerPage + i + 1;
                                                  if (dayNumber > plan.duration) return const SizedBox.shrink();
                                                  final day = plan.days[dayNumber - 1];
                                                  return Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        behavior: HitTestBehavior.opaque,
                                                        onTap: () {
                                                          provider.selectDay(dayNumber - 1);
                                                          context.push('/coach/plans/nutrition/day-details');
                                                        },
                                                        child: SizedBox(
                                                          height: cellHeight,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: NutritionPlanLayoutValues.getBreakfastFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.breakfast, false),
                                                              ),
                                                              Expanded(
                                                                flex: NutritionPlanLayoutValues.getLunchFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.lunch, false),
                                                              ),
                                                              Expanded(
                                                                flex: NutritionPlanLayoutValues.getDinnerFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.dinner, false),
                                                              ),
                                                              Expanded(
                                                                flex: NutritionPlanLayoutValues.getSnackFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.snacks, true),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      if (i < daysPerPage - 1)
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
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (totalPages > 1)
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
                              color: _currentPage > 0 ? AppColors.primary : Colors.grey,
                            ),
                            Text(
                              '${_currentPage + 1}/$totalPages',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              onPressed: _currentPage < totalPages - 1
                                  ? () => _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    )
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              color: _currentPage < totalPages - 1 ? AppColors.primary : Colors.grey,
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
} 
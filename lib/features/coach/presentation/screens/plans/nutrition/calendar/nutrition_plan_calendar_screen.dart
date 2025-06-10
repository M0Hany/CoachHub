import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../providers/nutrition/nutrition_plan_provider.dart';
import '../../../../../data/models/nutrition/nutrition_plan_model.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../l10n/app_localizations.dart';

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

class NutritionPlanCalendarScreen extends StatefulWidget {
  const NutritionPlanCalendarScreen({super.key});

  @override
  State<NutritionPlanCalendarScreen> createState() => _NutritionPlanCalendarScreenState();
}

class _NutritionPlanCalendarScreenState extends State<NutritionPlanCalendarScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  static const int daysPerPage = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<NutritionPlanProvider>(
      builder: (context, provider, child) {
        final plan = provider.nutritionPlan;
        if (plan == null) {
          return Scaffold(
            body: Center(child: Text(l10n.noPlanData)),
          );
        }

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
                              Text(
                                plan.title,
                                style: AppTheme.headerLarge.copyWith(
                                  color: AppTheme.textDark
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
                                      // Headers row
                                      Row(
                  children: [
                                          const SizedBox(width: 60),
                    Expanded(
                      child: Row(
                        children: [
                                                // Breakfast (longest)
                                                Flexible(
                                                  flex: NutritionPlanLayoutValues.getBreakfastFlex(Directionality.of(context)),
                                                  child: Container(
                                                    margin: NutritionPlanLayoutValues.getBreakfastMargin(Directionality.of(context)),
                                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(8),
                                                        topRight: Radius.circular(8),
                                                      ),
                                                    ),
                            child: Text(
                              l10n.breakfast,
                                                      style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                                                ),
                                                // Lunch
                                                Flexible(
                                                  flex: NutritionPlanLayoutValues.getLunchFlex(Directionality.of(context)),
                                                  child: Container(
                                                    margin: NutritionPlanLayoutValues.getLunchMargin(Directionality.of(context)),
                                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(8),
                                                        topRight: Radius.circular(8),
                                                      ),
                                                    ),
                            child: Text(
                              l10n.lunch,
                                                      style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                                                ),
                                                // Dinner
                                                Flexible(
                                                  flex: NutritionPlanLayoutValues.getDinnerFlex(Directionality.of(context)),
                                                  child: Container(
                                                    margin: NutritionPlanLayoutValues.getDinnerMargin(Directionality.of(context)),
                                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(8),
                                                        topRight: Radius.circular(8),
                                                      ),
                                                    ),
                            child: Text(
                              l10n.dinner,
                                                      style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                                                ),
                                                // Snack
                                                Flexible(
                                                  flex: NutritionPlanLayoutValues.getSnackFlex(Directionality.of(context)),
                                                  child: Container(
                                                    margin: NutritionPlanLayoutValues.getSnackMargin(Directionality.of(context)),
                                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary,
                                                      borderRadius: const BorderRadius.only(
                                                        topLeft: Radius.circular(8),
                                                        topRight: Radius.circular(8),
                                                      ),
                                                    ),
                            child: Text(
                              l10n.snack,
                                                      style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                                      ), // Calendar grid
                                      Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: min(daysPerPage, plan.duration - (pageIndex * daysPerPage)) * 100.0,
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
              Expanded(
                                            child: Container(
                                              height: min(daysPerPage, plan.duration - (pageIndex * daysPerPage)) * 100.0,
                                              margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
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
                                                          height: 100,
                              child: Row(
                                children: [
                                                              // Match flex values with headers
                                                              Flexible(
                                                                flex: NutritionPlanLayoutValues.getBreakfastFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.breakfast, false),
                                                              ),
                                                              Flexible(
                                                                flex: NutritionPlanLayoutValues.getLunchFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.lunch, false),
                                                              ),
                                                              Flexible(
                                                                flex: NutritionPlanLayoutValues.getDinnerFlex(Directionality.of(context)),
                                                                child: _buildMealCell(day.dinner, false),
                                                              ),
                                                              Flexible(
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
                child: const BottomNavBar(role: UserRole.coach, currentIndex: 0),
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
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
  final String title;
  final int duration;

  const WorkoutPlanCalendarScreen({
    super.key,
    required this.title,
    required this.duration,
  });

  @override
  State<WorkoutPlanCalendarScreen> createState() => _WorkoutPlanCalendarScreenState();
}

class _WorkoutPlanCalendarScreenState extends State<WorkoutPlanCalendarScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final int _totalPages;

  @override
  void initState() {
    super.initState();
    _totalPages = (widget.duration / 5).ceil();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
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
                            widget.title,
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
                                height: min(widget.duration, 5) * 100.0, // Dynamic height based on days
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
                                  height: min(widget.duration, 5) * 100.0, // Dynamic height based on days
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
                                          GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => MuscleSelectionScreen(
                                                  dayNumber: dayNumber,
                                                ),
                                              ),
                                            ),
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
                                                        children: const [
                                                          // This will be populated with exercises later
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
  }
} 
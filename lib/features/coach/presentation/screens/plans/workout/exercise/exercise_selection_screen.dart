import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../providers/workout/workout_plan_provider.dart';
import '../../../../../data/models/workout/workout_plan_model.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'dart:developer' as developer;
import '../../../../../../../core/theme/app_colors.dart';
import 'exercise_details_form_screen.dart';
import '../../../../../../../l10n/app_localizations.dart';

class ExerciseData {
  final String name;
  final String animationPath;

  ExerciseData({required this.name, required this.animationPath});
}

class ExerciseSelectionScreen extends StatefulWidget {
  final int dayNumber;
  final String muscleGroup;

  const ExerciseSelectionScreen({
    super.key,
    required this.dayNumber,
    required this.muscleGroup,
  });

  @override
  State<ExerciseSelectionScreen> createState() => _ExerciseSelectionScreenState();
}

class _ExerciseSelectionScreenState extends State<ExerciseSelectionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final int _totalPages;

  // Mock data repeated 4 times to get 12 exercises
  final exercises = List.generate(4, (index) => [
    {
      'name': 'Upper cable crossover',
      'animation': 'assets/animations/workout1.json',
    },
    {
      'name': 'Middle cable crossover',
      'animation': 'assets/animations/workout2.json',
    },
    {
      'name': 'Lower cable crossover',
      'animation': 'assets/animations/workout3.json',
    },
  ]).expand((x) => x).toList();

  @override
  void initState() {
    super.initState();
    _totalPages = (exercises.length / 6).ceil();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildExerciseCard(Map<String, String> exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExerciseDetailsFormScreen(
              dayNumber: widget.dayNumber,
              muscleGroup: widget.muscleGroup,
              exerciseData: ExerciseData(
                name: exercise['name']!,
                animationPath: exercise['animation']!,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Lottie.asset(
                  exercise['animation']!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      exercise['name']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 12,
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          l10n.workout_plans_title,
          style: AppTheme.bodyMedium,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    widget.muscleGroup,
                    style: AppTheme.headerLarge.copyWith(
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    itemCount: _totalPages,
                    itemBuilder: (context, pageIndex) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: 180, // Fixed height for each grid item
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            final exerciseIndex = pageIndex * 6 + index;
                            if (exerciseIndex >= exercises.length) {
                              return const SizedBox.shrink();
                            }
                            return _buildExerciseCard(exercises[exerciseIndex]);
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (_totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100), // Add padding for nav bar
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
                          color: _currentPage < _totalPages - 1 ? AppColors.primary : Colors.grey,
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
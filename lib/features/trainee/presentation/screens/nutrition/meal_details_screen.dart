import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../coach/presentation/providers/nutrition/nutrition_plan_provider.dart';
import '../../../../coach/data/models/nutrition/nutrition_plan_model.dart';
import '../../../../../l10n/app_localizations.dart';

class MealDetailsScreen extends StatefulWidget {
  const MealDetailsScreen({super.key});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<NutritionPlanProvider>(
      builder: (context, provider, child) {
        final plan = provider?.nutritionPlan;
        if (plan == null || provider?.selectedDayIndex == null) {
          return Scaffold(
            body: Center(child: Text(l10n.noPlanData)),
          );
        }

        final dayNumber = provider!.selectedDayIndex! + 1;
        final day = provider.getDayMeals(provider.selectedDayIndex!);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(
              l10n.nutritionPlans,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        plan.title,
                        textAlign: TextAlign.center,
                        style: AppTheme.headerLarge.copyWith(
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildMealSection(l10n.breakfast, day?.breakfast ?? ''),
                      const SizedBox(height: 24),
                      _buildMealSection(l10n.lunch, day?.lunch ?? ''),
                      const SizedBox(height: 24),
                      _buildMealSection(l10n.dinner, day?.dinner ?? ''),
                      const SizedBox(height: 24),
                      _buildMealSection(l10n.snack, day?.snacks ?? ''),
                      if (day?.note != null && day!.note!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildMealSection(l10n.note, day.note!),
                      ],
                      const SizedBox(height: 130), // Space for bottom nav bar
                    ],
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomNavBar(role: UserRole.trainee), // Home tab
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Text(
            content.isEmpty ? 'No meal planned' : content,
            style: AppTheme.bodyMedium.copyWith(
              color: content.isEmpty ? Colors.grey : AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
} 
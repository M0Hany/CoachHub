import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../providers/nutrition/nutrition_plan_provider.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../../../core/widgets/primary_button.dart';

class NutritionDayDetailsScreen extends StatefulWidget {
  const NutritionDayDetailsScreen({super.key});

  @override
  State<NutritionDayDetailsScreen> createState() => _NutritionDayDetailsScreenState();
}

class _NutritionDayDetailsScreenState extends State<NutritionDayDetailsScreen> {
  final _breakfastController = TextEditingController();
  final _lunchController = TextEditingController();
  final _dinnerController = TextEditingController();
  final _snacksController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NutritionPlanProvider>();
      if (provider.selectedDayIndex != null) {
        final day = provider.getDayMeals(provider.selectedDayIndex!);
        if (day != null) {
          _breakfastController.text = day.breakfast;
          _lunchController.text = day.lunch;
          _dinnerController.text = day.dinner;
          _snacksController.text = day.snacks;
          _noteController.text = day.note ?? '';
        }
      }
    });
  }

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _snacksController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Consumer<NutritionPlanProvider>(
      builder: (context, provider, child) {
        final plan = provider.nutritionPlan;
        if (plan == null || provider.selectedDayIndex == null) {
          return Scaffold(
            body: Center(child: Text(l10n.noPlanData)),
          );
        }

        final dayNumber = provider.selectedDayIndex! + 1;

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
                        style: AppTheme.headerLarge.copyWith(
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: _breakfastController,
                        hintText: l10n.breakfast,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _lunchController,
                        hintText: l10n.lunch,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _dinnerController,
                        hintText: l10n.dinner,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _snacksController,
                        hintText: l10n.snack,
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: _noteController,
                        hintText: l10n.note,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton(
                        onPressed: () async {
                          if (provider.selectedDayIndex != null) {
                            provider.updateDayMeals(
                              dayIndex: provider.selectedDayIndex!,
                              breakfast: _breakfastController.text,
                              lunch: _lunchController.text,
                              dinner: _dinnerController.text,
                              snacks: _snacksController.text,
                              note: _noteController.text.isEmpty ? null : _noteController.text,
                            );
                            
                            try {
                              await provider.updateNutritionPlan();
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error updating plan: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.selectDayFirst),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        text: l10n.apply,
                      ),
                      const SizedBox(height: 100), // Space for bottom nav bar
                    ],
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomNavBar(role: UserRole.coach),
              ),
            ],
          ),
        );
      },
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../../core/widgets/primary_button.dart';
import 'workout/calendar/workout_plan_calendar_screen.dart';
import 'nutrition/calendar/nutrition_plan_calendar_screen.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'package:coachhub/features/coach/presentation/providers/nutrition/nutrition_plan_provider.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  int _duration = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _durationController.text = _duration.toString();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    final initialIndex = location.contains('create-workout') ? 0 : 1;
    _tabController.index = initialIndex;
  }

  void _updateDuration(String value) {
    if (value.isEmpty) {
      setState(() => _duration = 1);
      _durationController.text = '1';
      return;
    }
    
    final newDuration = int.tryParse(value);
    if (newDuration != null && newDuration > 0) {
      setState(() => _duration = newDuration);
    } else {
      _durationController.text = _duration.toString();
    }
    // Ensure cursor stays at the end
    _durationController.selection = TextSelection.fromPosition(
      TextPosition(offset: _durationController.text.length),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.plansTitle,
            style: AppTheme.bodyMedium,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
              const SizedBox(height: 37),
              Text(
                _tabController.index == 0 
                  ? l10n.workout_plans_create_plan 
                  : l10n.nutrition_plans_create_plan,
                style: AppTheme.headerMedium,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _titleController,
                hintText: _tabController.index == 0
                  ? l10n.workout_plans_plan_title
                  : l10n.planTitle,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _tabController.index == 0
                      ? l10n.workout_plans_plan_duration
                      : l10n.planDuration,
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(width: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              right: Directionality.of(context) == TextDirection.ltr
                                  ? const BorderSide(color: Colors.grey)
                                  : BorderSide.none,
                              left: Directionality.of(context) == TextDirection.rtl
                                  ? const BorderSide(color: Colors.grey)
                                  : BorderSide.none,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.remove, size: 20, color: Colors.grey),
                            onPressed: () {
                              if (_duration > 1) {
                                setState(() {
                                  _duration--;
                                  _durationController.text = _duration.toString();
                                });
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: _durationController,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: _updateDuration,
                            onSubmitted: (value) {
                              if (value.isEmpty || _duration == 0) {
                                setState(() {
                                  _duration = 1;
                                  _durationController.text = '1';
                                });
                              }
                            },
                            onTapOutside: (_) {
                              FocusScope.of(context).unfocus();
                              if (_durationController.text.isEmpty || _duration == 0) {
                                setState(() {
                                  _duration = 1;
                                  _durationController.text = '1';
                                });
                              }
                            },
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: Directionality.of(context) == TextDirection.ltr
                                  ? const BorderSide(color: Colors.grey)
                                  : BorderSide.none,
                              right: Directionality.of(context) == TextDirection.rtl
                                  ? const BorderSide(color: Colors.grey)
                                  : BorderSide.none,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, size: 20, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _duration = (_duration == 0 ? 1 : _duration) + 1;
                                _durationController.text = _duration.toString();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              PrimaryButton(
                onPressed: () {
                  if (_titleController.text.trim().isNotEmpty) {
                    if (_tabController.index == 0) {
                      context.push('/coach/plans/workout/calendar', extra: {
                        'title': _titleController.text.trim(),
                        'duration': _duration,
                      });
                    } else {
                      final provider = context.read<NutritionPlanProvider>();
                      provider.initializePlan(_titleController.text.trim(), _duration);
                      context.push('/coach/plans/nutrition/calendar');
                    }
                  }
                },
                text: l10n.workout_plans_next,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
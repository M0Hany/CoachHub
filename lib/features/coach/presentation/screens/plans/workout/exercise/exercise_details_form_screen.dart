import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../providers/workout/workout_plan_provider.dart';
import '../../../../../data/models/workout/workout_plan_model.dart';
import 'package:go_router/go_router.dart';
import 'exercise_selection_screen.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/widgets/custom_text_field.dart';
import '../../../../../../../core/widgets/primary_button.dart';
import '../../../../../../../l10n/app_localizations.dart';

class ExerciseDetailsFormScreen extends StatefulWidget {
  final int dayNumber;
  final String muscleGroup;
  final ExerciseData exerciseData;

  const ExerciseDetailsFormScreen({
    super.key,
    required this.dayNumber,
    required this.muscleGroup,
    required this.exerciseData,
  });

  @override
  State<ExerciseDetailsFormScreen> createState() => _ExerciseDetailsFormScreenState();
}

class _ExerciseDetailsFormScreenState extends State<ExerciseDetailsFormScreen> {
  int _sets = 1;
  int _reps = 1;
  int _restTime = 15;
  final _noteController = TextEditingController();
  final _urlController = TextEditingController();
  final _setsController = TextEditingController(text: '1');
  final _repsController = TextEditingController(text: '1');
  final _restTimeController = TextEditingController(text: '15');

  @override
  void dispose() {
    _noteController.dispose();
    _urlController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  void _updateValue(String value, TextEditingController controller, void Function(int) setter, {int minValue = 1}) {
    if (value.isEmpty) {
      setState(() => setter(0));
      return;
    }
    
    final newValue = int.tryParse(value);
    if (newValue != null && newValue >= 0) {
      setState(() => setter(newValue));
    }
    // Ensure cursor stays at the end
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }

  Widget _buildCounter({
    required String label,
    required TextEditingController controller,
    required int value,
    required Function(int) onChanged,
    int step = 1,
    int minValue = 1,
  }) {
    return Row(
      children: [
        Text(
          label,
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
                    if (value > minValue) {
                      onChanged(value - step);
                      controller.text = (value - step).toString();
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: controller,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateValue(value, controller, onChanged, minValue: minValue),
                  onSubmitted: (value) {
                    if (value.isEmpty || int.tryParse(value) == 0) {
                      setState(() {
                        onChanged(minValue);
                        controller.text = minValue.toString();
                      });
                    }
                  },
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                    if (controller.text.isEmpty || int.tryParse(controller.text) == 0) {
                      setState(() {
                        onChanged(minValue);
                        controller.text = minValue.toString();
                      });
                    }
                  },
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                    onChanged(value + step);
                    controller.text = (value + step).toString();
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
          onPressed: () => context.pop(),
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
                    widget.exerciseData.name,
                    style: AppTheme.headerLarge.copyWith(
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildCounter(
                    label: l10n.workout_plans_exercise_details_sets,
                    controller: _setsController,
                    value: _sets,
                    onChanged: (value) => setState(() => _sets = value),
                  ),
                  const SizedBox(height: 24),
                  _buildCounter(
                    label: l10n.workout_plans_exercise_details_reps,
                    controller: _repsController,
                    value: _reps,
                    onChanged: (value) => setState(() => _reps = value),
                  ),
                  const SizedBox(height: 24),
                  _buildCounter(
                    label: '${l10n.workout_plans_exercise_details_rest_time} (${l10n.workout_plans_exercise_details_seconds})',
                    controller: _restTimeController,
                    value: _restTime,
                    onChanged: (value) => setState(() => _restTime = value),
                    step: 5,
                    minValue: 0,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _noteController,
                    hintText: l10n.workout_plans_exercise_details_note,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _urlController,
                    hintText: l10n.workout_plans_exercise_details_video_url,
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    onPressed: () {
                      final provider = context.read<WorkoutPlanProvider>();
                      final exercise = Exercise(
                        id: widget.exerciseData.id,
                        name: widget.exerciseData.name,
                        animationPath: widget.exerciseData.animationPath ?? '',
                        sets: _sets,
                        reps: _reps,
                        restTime: _restTime,
                        note: _noteController.text.isEmpty ? null : _noteController.text,
                        videoUrl: _urlController.text.isEmpty ? null : _urlController.text,
                      );

                      try {
                        print('Adding exercise to day ${provider.selectedDayIndex} with muscle group ${widget.muscleGroup}');
                        provider.addExerciseToDay(exercise, widget.muscleGroup);
                        print('Successfully added exercise');
                        
                        // Navigate back to calendar
                        if (mounted) {
                          context.go('/coach/plans/workout/calendar', extra: {
                            'planId': provider.workoutId,
                            'duration': provider.workoutPlan?.duration ?? 7,
                          });
                        }
                      } catch (e) {
                        print('Error adding exercise: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error adding exercise: $e')),
                          );
                        }
                      }
                    },
                    text: l10n.workout_plans_apply,
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
  }
} 
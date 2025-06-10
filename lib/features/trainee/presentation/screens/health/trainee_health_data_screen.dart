import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';

class TraineeHealthDataScreen extends StatefulWidget {
  const TraineeHealthDataScreen({super.key});

  @override
  State<TraineeHealthDataScreen> createState() => _TraineeHealthDataScreenState();
}

class _TraineeHealthDataScreenState extends State<TraineeHealthDataScreen> {
  final _formKey = GlobalKey<FormState>();
  double _age = 0.0;
  double _height = 0.0;
  double _weight = 0.0;
  double _fatPercentage = 0.0;
  double _musclePercentage = 0.0;
  final List<String> _selectedGoals = [];
  List<(String key, String value)>? _goalOptions;

  String? _validateNumber(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (double.tryParse(value) == null) {
      return AppLocalizations.of(context)!.enterValidNumber;
    }
    return null;
  }

  void _initializeGoalOptions() {
    final l10n = AppLocalizations.of(context)!;
    _goalOptions = [
      ('rehabilitation', l10n.rehabilitation),
      ('muscleGain', l10n.muscleGain),
      ('overallHealth', l10n.overallHealth),
      ('competitionPreparation', l10n.competitionPreparation),
      ('boostAthleticAgility', l10n.boostAthleticAgility),
      ('boostImmuneSystem', l10n.boostImmuneSystem),
      ('increaseExplosiveness', l10n.increaseExplosiveness)
    ];
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeGoalOptions();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthInformation),
        backgroundColor: AppTheme.primaryButtonColor,
      ),
      body: _goalOptions == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.age),
                      keyboardType: TextInputType.number,
                      validator: (value) => _validateNumber(value, l10n.enterAge),
                      onSaved: (value) => _age = double.parse(value ?? '0'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.height),
                      keyboardType: TextInputType.number,
                      validator: (value) => _validateNumber(value, l10n.enterHeight),
                      onSaved: (value) => _height = double.parse(value ?? '0'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.weight),
                      keyboardType: TextInputType.number,
                      validator: (value) => _validateNumber(value, l10n.enterWeight),
                      onSaved: (value) => _weight = double.parse(value ?? '0'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.fatsPercentage),
                      keyboardType: TextInputType.number,
                      validator: (value) => _validateNumber(value, l10n.enterFatPercentage),
                      onSaved: (value) => _fatPercentage = double.parse(value ?? '0'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: l10n.bodyMuscle),
                      keyboardType: TextInputType.number,
                      validator: (value) => _validateNumber(value, l10n.enterMusclePercentage),
                      onSaved: (value) => _musclePercentage = double.parse(value ?? '0'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.fitnessGoals,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _goalOptions!.map((goal) {
                        final isSelected = _selectedGoals.contains(goal.$1);
                        return FilterChip(
                          label: Text(goal.$2),
                          selected: isSelected,
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                _selectedGoals.add(goal.$1);
                              } else {
                                _selectedGoals.remove(goal.$1);
                              }
                            });
                          },
                          backgroundColor: Colors.grey[200],
                          selectedColor: AppTheme.secondaryButtonColor,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              _selectedGoals.isNotEmpty) {
                            _formKey.currentState!.save();
                            final authProvider = context.read<AuthProvider>();
                            final success = await authProvider.updateTraineeHealthData(
                              age: _age,
                              height: _height,
                              weight: _weight,
                              fatPercentage: _fatPercentage,
                              musclePercentage: _musclePercentage,
                              goals: _selectedGoals,
                            );
                            if (success && context.mounted) {
                              context.go('/trainee/profile');
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(l10n.saveHealthData),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

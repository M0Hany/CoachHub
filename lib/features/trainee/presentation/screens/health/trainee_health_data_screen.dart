import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/models/models.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'dart:developer' as developer;

class TraineeHealthDataScreen extends StatefulWidget {
  const TraineeHealthDataScreen({super.key});

  @override
  State<TraineeHealthDataScreen> createState() => _TraineeHealthDataScreenState();
}

class _TraineeHealthDataScreenState extends State<TraineeHealthDataScreen> {
  final _formKey = GlobalKey<FormState>();
  int _age = 0;
  double _height = 0.0;
  double _weight = 0.0;
  double _fatPercentage = 0.0;
  double _musclePercentage = 0.0;
  final List<int> _selectedGoalIds = [];
  bool _isFetchingData = true;
  List<Goal> _goals = [];
  String? _error;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
  }

  Future<void> _fetchGoals() async {
    try {
      final response = await HttpClient().get<Map<String, dynamic>>('/api/goals/');
      
      if (response.data?['success'] == true) {
        final goals = (response.data?['data']['goals'] as List)
            .map((goal) => Goal.fromJson(goal))
            .toList();
        
        setState(() {
          _goals = goals;
          _isFetchingData = false;
        });
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch goals');
      }
    } catch (e) {
      developer.log('Error fetching goals: $e', name: 'TraineeHealthDataScreen');
      setState(() {
        _error = e.toString();
        _isFetchingData = false;
      });
    }
  }

  String? _validateNumber(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (double.tryParse(value) == null) {
      return AppLocalizations.of(context)!.enterValidNumber;
    }
    return null;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isFetchingData) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.healthInformation),
          backgroundColor: AppTheme.primaryButtonColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.healthInformation),
          backgroundColor: AppTheme.primaryButtonColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isFetchingData = true;
                  });
                  _fetchGoals();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthInformation),
        backgroundColor: AppTheme.primaryButtonColor,
      ),
      body: SingleChildScrollView(
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
                onSaved: (value) => _age = int.parse(value ?? '0'),
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
                children: _goals.map((goal) {
                  final isSelected = _selectedGoalIds.contains(goal.id);
                  return FilterChip(
                    label: Text(goal.name),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedGoalIds.add(goal.id);
                        } else {
                          _selectedGoalIds.remove(goal.id);
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
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                    if (_formKey.currentState!.validate() &&
                              _selectedGoalIds.isNotEmpty) {
                            setState(() => _isSubmitting = true);
                            try {
                      _formKey.currentState!.save();
                      final authProvider = context.read<AuthProvider>();
                      final request = TraineeHealthDataUpdateRequest(
                                goalIds: _selectedGoalIds,
                                weight: _weight,
                                height: _height,
                                fatPercentage: _fatPercentage,
                                musclePercentage: _musclePercentage,
                        age: _age,
                      );
                              final success = await authProvider.updateTraineeHealthData(request);
                      if (success && context.mounted) {
                        context.go('/trainee/profile');
                              } else if (context.mounted) {
                                _showErrorSnackBar(authProvider.error ?? 'Failed to update health data');
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isSubmitting = false);
                              }
                            }
                          } else if (_selectedGoalIds.isEmpty) {
                            _showErrorSnackBar('Please select at least one goal');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.saveHealthData),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

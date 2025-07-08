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
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();
  double _fatPercentage = 10.0;
  double _musclePercentage = 10.0;
  final List<int> _selectedGoalIds = [];
  static const int requiredGoalCount = 3;
  bool _isFetchingData = true;
  List<Goal> _goals = [];
  String? _error;
  bool _isSubmitting = false;
  bool _hasHypertension = false;
  bool _hasDiabetes = false;

  @override
  void initState() {
    super.initState();
    _fetchGoals();
    _ageFocusNode.addListener(_onFocusChange);
    _heightFocusNode.addListener(_onFocusChange);
    _weightFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageFocusNode.dispose();
    _heightFocusNode.dispose();
    _weightFocusNode.dispose();
    super.dispose();
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

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    String? suffix,
  }) {
    final hasText = controller.text.isNotEmpty;
    final isFocused = focusNode.hasFocus;
    return SizedBox(
      width: 100,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Color(0xFF0D122A)),
        decoration: InputDecoration(
          filled: true,
          fillColor: isFocused || hasText ? Colors.white : const Color(0xFFB5B7BE),
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 10,
            color: isFocused || hasText ? AppTheme.accent : Colors.grey[600],
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isFocused || hasText ? AppTheme.accent : Colors.transparent,
              width: isFocused || hasText ? 2 : 0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppTheme.accent,
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isFocused || hasText ? AppTheme.accent : Colors.transparent,
              width: isFocused || hasText ? 2 : 0,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixText: suffix,
        ),
        validator: (v) => _validateNumber(v, hint),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.bodySmall),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFB5B7BE),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                inactiveTrackColor: AppTheme.primaryButtonColor,
                activeTrackColor: AppTheme.accent,
                thumbColor: AppTheme.accent,
                overlayColor: AppTheme.accent.withValues(alpha: 0.2),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                overlayShape: SliderComponentShape.noOverlay,
                valueIndicatorShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: onChanged,
              ),
            ),
            Positioned(
              left: (value / 100) * (MediaQuery.of(context).size.width - 48 - 28), // 48 for padding, 28 for thumb
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryButtonColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toInt()}%',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isFetchingData) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D122A)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.healthInformation,
            style: AppTheme.headerMedium,
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF0D122A)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.healthInformation,
            style: AppTheme.headerMedium,
          ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D122A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.healthInformation,
          style: AppTheme.headerMedium,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTextField(
                    controller: _ageController,
                    focusNode: _ageFocusNode,
                    hint: l10n.age,
                  ),
                  _buildTextField(
                    controller: _heightController,
                    focusNode: _heightFocusNode,
                    hint: l10n.height,
                    suffix: '(cm)',
                  ),
                  _buildTextField(
                    controller: _weightController,
                    focusNode: _weightFocusNode,
                    hint: l10n.weight,
                    suffix: '(kg)',
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildSlider(
                label: l10n.fatsPercentage,
                value: _fatPercentage,
                onChanged: (v) => setState(() => _fatPercentage = v),
              ),
              const SizedBox(height: 32),
              _buildSlider(
                label: l10n.bodyMuscle,
                value: _musclePercentage,
                onChanged: (v) => setState(() => _musclePercentage = v),
              ),
              const SizedBox(height: 32),
              Text(l10n.healthConditionsTitle, style: AppTheme.bodySmall),
              const SizedBox(height: 12),
              Column(
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _hasHypertension,
                        onChanged: (val) => setState(() => _hasHypertension = val ?? false),
                        activeColor: AppTheme.accent,
                        checkColor: AppTheme.primaryButtonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        side: const BorderSide(color: AppTheme.accent, width: 2),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _hasHypertension = !_hasHypertension),
                        child: Text(l10n.hypertension, style: AppTheme.bodySmall),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _hasDiabetes,
                        onChanged: (val) => setState(() => _hasDiabetes = val ?? false),
                        activeColor: AppTheme.accent,
                        checkColor: AppTheme.primaryButtonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        side: const BorderSide(color: AppTheme.accent, width: 2),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _hasDiabetes = !_hasDiabetes),
                        child: Text(l10n.diabetes, style: AppTheme.bodySmall),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(l10n.fitnessGoals, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                l10n.selectThreeGoals,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _goals.map((goal) {
                  final isSelected = _selectedGoalIds.contains(goal.id);
                  return ChoiceChip(
                    label: Text(
                      goal.name,
                      style: isSelected
                          ? AppTheme.bodySmall.copyWith(color: AppTheme.textLight)
                          : AppTheme.bodySmall.copyWith(color: AppTheme.primaryButtonColor),
                    ),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          if (_selectedGoalIds.length < requiredGoalCount) {
                            _selectedGoalIds.add(goal.id);
                          } else {
                            _showErrorSnackBar('You can only select 3 fitness goals');
                          }
                        } else {
                          _selectedGoalIds.remove(goal.id);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryButtonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: AppTheme.primaryButtonColor, width: 1.5),
                    ),
                    showCheckmark: false,
                    elevation: 0,
                    pressElevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                          if (_formKey.currentState!.validate() && _selectedGoalIds.length == requiredGoalCount) {
                            setState(() => _isSubmitting = true);
                            try {
                      final authProvider = context.read<AuthProvider>();
                      final request = TraineeHealthDataUpdateRequest(
                                goalIds: _selectedGoalIds,
                                weight: (double.tryParse(_weightController.text) ?? 0.0).roundToDouble(),
                                height: (double.tryParse(_heightController.text) ?? 0.0).roundToDouble(),
                                fatPercentage: double.parse(_fatPercentage.toStringAsFixed(2)),
                                musclePercentage: double.parse(_musclePercentage.toStringAsFixed(2)),
                                age: int.tryParse(_ageController.text) ?? 0,
                                hypertension: _hasHypertension,
                                diabetes: _hasDiabetes,
                      );
                              developer.log('Submitting trainee health data: \n	${request.toJson()}', name: 'TraineeHealthDataScreen');
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
                          } else if (_selectedGoalIds.length != requiredGoalCount) {
                            _showErrorSnackBar(l10n.selectThreeGoals);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryButtonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/http_client.dart';
import 'dart:developer' as developer;

class CoachExpertiseScreen extends StatefulWidget {
  const CoachExpertiseScreen({super.key});

  @override
  State<CoachExpertiseScreen> createState() => _CoachExpertiseScreenState();
}

class _CoachExpertiseScreenState extends State<CoachExpertiseScreen> {
  final List<int> selectedExpertiseIds = [];
  static const int requiredExpertiseCount = 3;
  bool _isLoading = false;
  bool _isFetchingData = true;
  List<ExperienceField> experienceFields = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExperienceFields();
  }

  Future<void> _fetchExperienceFields() async {
    try {
      final response = await HttpClient().get<Map<String, dynamic>>('/api/experience-field/');
      
      if (response.data?['success'] == true) {
        final fields = (response.data?['data']['experience_fields'] as List)
            .map((field) => ExperienceField.fromJson(field))
            .toList();
        
        setState(() {
          experienceFields = fields;
          _isFetchingData = false;
        });
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to fetch experience fields');
      }
    } catch (e) {
      developer.log('Error fetching experience fields: $e', name: 'CoachExpertiseScreen');
      setState(() {
        _error = e.toString();
        _isFetchingData = false;
      });
    }
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
          title: Text(l10n.yourExpertise),
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
          title: Text(l10n.yourExpertise),
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
                  _fetchExperienceFields();
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
        title: Text(l10n.yourExpertise),
        backgroundColor: AppTheme.primaryButtonColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectExpertiseAreas,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select exactly 3 areas of expertise',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: experienceFields.map((field) {
                final isSelected = selectedExpertiseIds.contains(field.id);
                return FilterChip(
                  label: Text(field.name),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        if (selectedExpertiseIds.length < requiredExpertiseCount) {
                          selectedExpertiseIds.add(field.id);
                        } else {
                          _showErrorSnackBar('You can only select 3 areas of expertise');
                        }
                      } else {
                        selectedExpertiseIds.remove(field.id);
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
                onPressed: _isLoading || selectedExpertiseIds.length != requiredExpertiseCount
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        try {
                        final authProvider = context.read<AuthProvider>();
                        final request = CoachExpertiseUpdateRequest(
                            experienceIds: selectedExpertiseIds,
                        );
                          final success = await authProvider.updateCoachExpertise(request);
                        if (success && context.mounted) {
                          context.go('/coach/profile');
                          } else if (context.mounted) {
                            _showErrorSnackBar(authProvider.error ?? 'Failed to update expertise');
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        selectedExpertiseIds.length == requiredExpertiseCount
                            ? l10n.continueAction
                            : '${selectedExpertiseIds.length}/3 Selected',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

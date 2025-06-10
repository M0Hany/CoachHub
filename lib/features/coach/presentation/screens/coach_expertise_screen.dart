import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class CoachExpertiseScreen extends StatefulWidget {
  const CoachExpertiseScreen({super.key});

  @override
  State<CoachExpertiseScreen> createState() => _CoachExpertiseScreenState();
}

class _CoachExpertiseScreenState extends State<CoachExpertiseScreen> {
  final List<String> selectedExpertise = [];
  final List<String> expertiseKeys = [
    'weightTraining',
    'cardio',
    'yoga',
    'pilates',
    'crossfit',
    'nutrition',
    'sportsPerformance',
    'rehabilitation'
  ];

  String getLocalizedExpertise(AppLocalizations l10n, String key) {
    switch (key) {
      case 'weightTraining':
        return l10n.weightTraining;
      case 'cardio':
        return l10n.cardio;
      case 'yoga':
        return l10n.yoga;
      case 'pilates':
        return l10n.pilates;
      case 'crossfit':
        return l10n.crossfit;
      case 'nutrition':
        return l10n.nutrition;
      case 'sportsPerformance':
        return l10n.sportsPerformance;
      case 'rehabilitation':
        return l10n.rehabilitation;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: expertiseKeys.map((expertiseKey) {
                final isSelected = selectedExpertise.contains(expertiseKey);
                return FilterChip(
                  label: Text(getLocalizedExpertise(l10n, expertiseKey)),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedExpertise.add(expertiseKey);
                      } else {
                        selectedExpertise.remove(expertiseKey);
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
                onPressed: selectedExpertise.isEmpty
                    ? null
                    : () async {
                        final authProvider = context.read<AuthProvider>();
                        final success = await authProvider.updateCoachExpertise(
                          expertise: selectedExpertise.map(
                            (key) => getLocalizedExpertise(l10n, key)
                          ).toList(),
                        );
                        if (success && context.mounted) {
                          context.go('/coach/profile');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.continueAction),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../core/constants/enums.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/providers/language_provider.dart';
import '../../../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class TraineeSettingsScreen extends StatelessWidget {
  const TraineeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.mainBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D122A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: Color(0xFF0D122A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsButton(
              text: l10n.resetPassword,
              onTap: () {
                context.go('/reset/email');
              },
            ),
            const SizedBox(height: 16),
            _SettingsButton(
              text: l10n.logout,
              onTap: () async {
                // Restore the original logout logic
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.logout),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(l10n.logout),
                      ),
                    ],
                  ),
                );
                if (shouldLogout == true && context.mounted) {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      context.go('/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.logoutError),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              isLogout: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 3,
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLogout;
  const _SettingsButton({
    required this.text,
    required this.onTap,
    this.isLogout = false,
  });
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Text(
            text,
            style: AppTheme.bodyMedium,
          ),
        ),
      ),
    );
  }
} 
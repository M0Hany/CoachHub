import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: AppTheme.secondaryButtonColor,
            ),
            const SizedBox(height: 24),
            Text(
              'CoachHub',
              style: AppTheme.headerLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your Personal Fitness Journey',
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.primaryButtonColor,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final authStatus = authProvider.status;

    switch (authStatus) {
      case AuthStatus.initial:
      case AuthStatus.authenticating:
        // Stay on splash screen with loading indicator
        break;
      case AuthStatus.authenticated:
        context.go('/dashboard');
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        context.go('/login');
        break;
      case AuthStatus.unverified:
      case AuthStatus.requiresOtp:
        context.go('/verify');
        break;
      case AuthStatus.profileIncomplete:
      case AuthStatus.requiresProfileCompletion:
        context.go('/complete-profile');
        break;
    }
  }
}

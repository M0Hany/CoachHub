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
    // Wait for the auth provider to initialize
    final authProvider = context.read<AuthProvider>();
    if (authProvider.status == AuthStatus.initial) {
      // Wait for status to change from initial
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return authProvider.status == AuthStatus.initial && mounted;
      });
    }

    if (!mounted) return;

    // Add a minimum splash screen duration
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authStatus = authProvider.status;
    switch (authStatus) {
      case AuthStatus.authenticated:
        context.go('/dashboard');
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.initial: // Fallback to login if still initial somehow
        context.go('/login');
        break;
    }
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTheme.headerMedium,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to CoachHub!',
              style: AppTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: AppTheme.primaryButtonStyle,
              child: const Text('Go to Login'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/register'),
              style: AppTheme.secondaryButtonStyle.copyWith(
                backgroundColor:
                    MaterialStateProperty.all(AppTheme.secondaryButtonColor),
              ),
              child: const Text('Go to Register'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/services/token_service.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Match the animation duration
    );
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _initializeApp();
      }
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;
    
    // Get the auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Force a refresh of the auth state
    await authProvider.refreshAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Listen to auth status changes
        authProvider.addListener(() {
          if (!mounted) return;

          final status = authProvider.status;
          final userType = authProvider.userType;

          developer.log(
            'Splash Screen - Auth Status: $status, User Type: $userType',
            name: 'SplashScreen'
          );

          if (status == AuthStatus.authenticated && userType != null) {
            // Navigate based on user type
            switch (userType) {
              case UserType.coach:
                context.go('/coach/home');
                break;
              case UserType.trainee:
                context.go('/trainee/home');
                break;
            }
          } else if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
            // If authentication fails or there's an error, go to login
            context.go('/login');
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Lottie.asset(
                'assets/images/logo/splash_logo_animation.json',
                controller: _controller,
                fit: BoxFit.cover,
              ),
              if (authProvider.isLoading)
                const Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (authProvider.error != null)
                Positioned(
                  bottom: 50,
                  left: 16,
                  right: 16,
                  child: Text(
                    authProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

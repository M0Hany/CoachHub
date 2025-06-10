import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'first_onboarding_screen.dart';
import 'second_onboarding_screen.dart';
import 'third_onboarding_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _onNext() {
    if (_pageController.page! < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  void _onSkip() {
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const ClampingScrollPhysics(),
      children: [
        FirstOnboardingScreen(
          onNext: _onNext,
          onSkip: _onSkip,
        ),
        SecondOnboardingScreen(
          onNext: _onNext,
          onSkip: _onSkip,
        ),
        ThirdOnboardingScreen(
          onNext: _onNext,
          onSkip: _onSkip,
        ),
      ],
    );
  }
} 
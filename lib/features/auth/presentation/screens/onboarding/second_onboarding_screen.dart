import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../widgets/language_dialog.dart';

class SecondOnboardingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const SecondOnboardingScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language,
              color: AppColors.primary,
            ),
            onPressed: () => showLanguageDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background shapes
          Transform.scale(
            scaleX: -1,
            child: SvgPicture.asset(
              'assets/images/onboarding/third_page_shapes.svg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
          const SizedBox(height: 16),
                // Logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/logo/coachhub_logo_navy.svg',
                          height: 32,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "CoachHub",
                          style: AppTheme.logoText.copyWith(
                            color: AppColors.primary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Center(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate responsive height based on screen size
                              final screenHeight = MediaQuery.of(context).size.height;
                              final imageHeight = (screenHeight * 0.4).clamp(250.0, 400.0); // 40% of screen height, min 250, max 400
                              
                              return Image.asset(
                                'assets/images/onboarding/phone_illustration.png',
                                height: imageHeight,
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              l10n.onboardingLevelUpTitle,
                              textAlign: TextAlign.center,
                              style: AppTheme.onBoardingTitle.copyWith(
                                fontSize: 20,
                                height: 1.2,
                              ),
                              maxLines: 3,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            // Features section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildFeatureBox(
                                  'assets/icons/features/progress_tracking.png',
                                  l10n.realTimeTracking,
                                ),
                                _buildFeatureBox(
                                  'assets/icons/features/seamless_training.png',
                                  l10n.seamlessTraining,
                                ),
                                _buildFeatureBox(
                                  'assets/icons/features/nutrition_plan.png',
                                  l10n.workoutNutritionPlans,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                width: index == 1 ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: onSkip,
                            child: Text(
                              l10n.skip,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Alexandria',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: onNext,
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBox(String iconPath, String label) {
    return Container(
      height: 100,
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
        color: const Color(0XFF141B3A),
        borderRadius: BorderRadius.circular(10),
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            height: 30,
            width: 30,
            color: AppColors.accent,
        ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTheme.bodySmall.copyWith(
              fontSize: 9,
              color: Colors.white,
            ),
            maxLines: 3,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
} 
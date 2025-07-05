import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../widgets/language_dialog.dart';

class FirstOnboardingScreen extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const FirstOnboardingScreen({
    super.key,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

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
              color: AppColors.accent,
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
            scaleX: isArabic ? -1 : 1,
            child:
            SvgPicture.asset(
              'assets/images/onboarding/first_page_shapes.svg',
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
                          'assets/images/logo/coachhub_logo_green.svg',
                          height: 32,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "CoachHub",
                          style: AppTheme.logoText.copyWith(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    l10n.onboardingWelcomeTitle,
                                    style: AppTheme.onBoardingTitle
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.onboardingWelcomeDesc,
                              style: AppTheme.onBoardingDescription
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
                                width: index == 0 ? 24 : 8,
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
} 
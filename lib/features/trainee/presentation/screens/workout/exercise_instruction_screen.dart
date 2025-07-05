import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import 'dart:developer' as developer;
import 'package:lottie/lottie.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseInstructionScreen extends StatelessWidget {
  final String exerciseName;
  final String? animationPath;
  final int workoutId;
  final int dayId;
  final int exerciseId;
  final int sets;
  final int reps;
  final int restTime;
  final String? notes;
  final String? videoUrl;

  const ExerciseInstructionScreen({
    super.key,
    required this.exerciseName,
    required this.animationPath,
    required this.workoutId,
    required this.dayId,
    required this.exerciseId,
    required this.sets,
    required this.reps,
    required this.restTime,
    this.notes,
    this.videoUrl,
  });

  Future<void> _launchVideoUrl() async {
    if (videoUrl == null) return;
    
    final url = Uri.parse(videoUrl!);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      developer.log('Could not launch video URL: $videoUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.workout_plans_title,
          style: AppTheme.bodyMedium,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Animation
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: animationPath == null
                          ? Container(
                              color: Colors.grey[100],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.animationComingSoon,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Lottie.asset(
                              animationPath!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                developer.log(
                                  'Failed to load exercise animation: $animationPath',
                                  name: 'ExerciseInstructionScreen',
                                  error: error,
                                );
                                return Container(
                                  color: Colors.grey[100],
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.fitness_center,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.animationComingSoon,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      ),
                    ),

                    // Exercise Name
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        exerciseName,
                        style: AppTheme.screenTitle.copyWith(
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sets
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            l10n.sets,
                            style: AppTheme.bodyMedium,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0FF789),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              sets.toString(),
                              style: AppTheme.bodyMedium.copyWith(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reps
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            l10n.reps,
                            style: AppTheme.bodyMedium,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0FF789),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              reps.toString(),
                              style: AppTheme.bodyMedium.copyWith(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Rest Time
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            l10n.restTime,
                            style: AppTheme.bodyMedium,
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0FF789),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '$restTime seconds',
                              style: AppTheme.bodyMedium.copyWith(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Coach Note
                    if (notes != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.noteFromCoach,
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              notes!,
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Video URL Button
            if (videoUrl != null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _launchVideoUrl,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Watch Video',
                      style: AppTheme.buttonTextLight,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_theme.dart';
import '../../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../../core/constants/enums.dart';
import '../../../../../../../core/network/http_client.dart';
import '../exercise/exercise_selection_screen.dart';
import '../../../../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class MuscleSelectionScreen extends StatefulWidget {
  final int dayNumber;

  const MuscleSelectionScreen({
    super.key,
    required this.dayNumber,
  });

  @override
  State<MuscleSelectionScreen> createState() => _MuscleSelectionScreenState();
}

class _MuscleSelectionScreenState extends State<MuscleSelectionScreen> {
  bool _isLoading = true;
  String? _error;
  List<String> _muscles = [];

  @override
  void initState() {
    super.initState();
    print('MuscleSelectionScreen: Initializing with day number: ${widget.dayNumber}');
    _loadMuscles();
  }

  Future<void> _loadMuscles() async {
    print('MuscleSelectionScreen: Loading muscles');
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get<Map<String, dynamic>>(
        '/api/plans/workout/muscles',
      );

      print('MuscleSelectionScreen: Received response: ${response.data}');
      if (response.data?['status'] == 'success') {
        setState(() {
          _muscles = List<String>.from(response.data!['data']['muscles']);
          _isLoading = false;
        });
        print('MuscleSelectionScreen: Loaded ${_muscles.length} muscles');
      }
    } catch (e) {
      print('MuscleSelectionScreen: Error loading muscles: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.workout_plans_title,
            style: AppTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.workout_plans_title,
            style: AppTheme.bodyMedium,
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.workout_plans_title,
          style: AppTheme.bodyMedium,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              l10n.workout_plans_choose_muscle,
              style: AppTheme.headerLarge.copyWith(
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            thumbColor: MaterialStateProperty.all(AppColors.accent),
                          ),
                        ),
                        child: Scrollbar(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                            itemCount: _muscles.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final muscle = _muscles[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  leading: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFD9D9D9),
                                    ),
                                  ),
                                  title: Text(
                                    muscle,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () {
                                    print('MuscleSelectionScreen: Navigating to exercises with day ${widget.dayNumber} and muscle $muscle');
                                    final params = {
                                      'day_number': widget.dayNumber,
                                      'muscle_group': muscle,
                                    };
                                    print('MuscleSelectionScreen: Navigation parameters: $params');
                                    context.push('/coach/plans/workout/exercises', extra: params);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(role: UserRole.coach, currentIndex: 0),
    );
  }
} 
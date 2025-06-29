import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class TraineeHomeScreen extends StatefulWidget {
  const TraineeHomeScreen({super.key});

  @override
  State<TraineeHomeScreen> createState() => _TraineeHomeScreenState();
}

class _TraineeHomeScreenState extends State<TraineeHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMetricIndex = 1;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _traineeProfile;
  Map<String, dynamic>? _workoutPlan;
  Map<String, dynamic>? _nutritionPlan;
  int _currentWorkoutDay = 1;
  int _currentNutritionDay = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final httpClient = HttpClient();

      // Get trainee profile
      final profileResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/profile/',
      );

      if (profileResponse.data?['status'] == 'success') {
        _traineeProfile = profileResponse.data!['data']['profile'];
      }

      // Get assigned workout plan
      final workoutResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/plans/workout/assigned',
      );

      if (workoutResponse.data?['status'] == 'success') {
        final workoutData = workoutResponse.data!['data']['assigned_workout'];
        if (workoutData != null) {
          _workoutPlan = workoutData;
          // Calculate current day based on start date
          final startDate = DateTime.parse(workoutData['start_date']);
          final daysSinceStart = DateTime.now().difference(startDate).inDays;
          _currentWorkoutDay = ((daysSinceStart % workoutData['workout']['duration']) + 1).toInt();
        }
      }

      // Get assigned nutrition plan
      final nutritionResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/plans/nutrition/assigned',
      );

      if (nutritionResponse.data?['status'] == 'success') {
        final nutritionData = nutritionResponse.data!['data']['assigned_plan'];
        if (nutritionData != null) {
          _nutritionPlan = nutritionData;
          // Calculate current day based on start date
          final startDate = DateTime.parse(nutritionData['start_date']);
          final daysSinceStart = DateTime.now().difference(startDate).inDays;
          _currentNutritionDay = ((daysSinceStart % nutritionData['nutrition']['duration']) + 1).toInt();
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: $_error'),
        ),
      );
    }

    // Find current day's exercises
    final currentDayExercises = _workoutPlan?['workout']?['days']
        ?.firstWhere(
          (day) => day['day_number'] == _currentWorkoutDay,
          orElse: () => null,
        )?['exercises'] as List<dynamic>?;

    // Find current day's nutrition
    final currentDayNutrition = _nutritionPlan?['nutrition']?['days']
        ?.firstWhere(
          (day) => day['day_number'] == _currentNutritionDay,
          orElse: () => null,
        );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                        _traineeProfile?['image_url'] != null
                            ? _traineeProfile!['image_url']
                            : 'assets/images/default_profile.jpg',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.goodMorning,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _traineeProfile?['full_name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF0FF789),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: l10n.workoutPlans),
                      Tab(text: l10n.nutritionPlans),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tab content
                SizedBox(
                  height: 100,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Workout plans tab
                      if (_workoutPlan != null && currentDayExercises != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${l10n.workout_plans_day} $_currentWorkoutDay',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      for (var exercise in currentDayExercises)
                                        Row(
                                          children: [
                                            const Icon(Icons.circle, size: 8, color: Color(0xFF0FF789)),
                                            const SizedBox(width: 8),
                                            Text(exercise['exercise']['title']),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.go('/trainee/workout-plan/${_workoutPlan!['workout']['title']}');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0FF789),
                                      foregroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(l10n.showPlan),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Center(child: Text(l10n.noWorkoutPlans)),
                      // Nutrition plans tab
                      _nutritionPlan != null
                          ? Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nutritionPlan!['nutrition']['title'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Day $_currentNutritionDay'),
                                ],
                              ),
                            )
                          : Center(child: Text(l10n.noNutritionPlans)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Dashboard title
                Text(
                  l10n.dashboard,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard(
                      icon: Icons.monitor_weight,
                      label: l10n.bodyWeight,
                      value: _traineeProfile?['weight']?.toString() ?? '0',
                      unit: l10n.kg,
                    ),
                    _buildMetricCard(
                      icon: Icons.height,
                      label: l10n.bodyHeight,
                      value: _traineeProfile?['height']?.toString() ?? '0',
                      unit: l10n.cm,
                    ),
                    _buildMetricCard(
                      icon: Icons.water_drop,
                      label: l10n.fatsPercentage,
                      value: _traineeProfile?['body_fat']?.toString() ?? '0',
                      unit: l10n.percentSymbol,
                    ),
                    _buildMetricCard(
                      icon: Icons.fitness_center,
                      label: l10n.bodyMuscle,
                      value: _traineeProfile?['body_muscle']?.toString() ?? '0',
                      unit: l10n.kg,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Metric selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMetricSelector('Fats', 0),
                    _buildMetricSelector('Weight', 1),
                    _buildMetricSelector('Height', 2),
                    _buildMetricSelector('Muscles', 3),
                  ],
                ),
                const SizedBox(height: 16),

                // Fats Graph
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D122A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.fatsGraph,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0FF789),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.monthly,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.currentFatPercentage,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_traineeProfile?['body_fat']?.toString() ?? '0'}${l10n.percentSymbol}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            final heights = [0.6, 0.4, 0.7, 0.9, 0.5, 0.3, 0.6];
                            final isSelected = index == 4;
                            return Container(
                              width: 30,
                              height: 100 * heights[index],
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0FF789) : Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Transform.translate(
                                        offset: const Offset(0, -20),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0FF789),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _traineeProfile?['body_fat']?.toString() ?? '0',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 2, // Home tab
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0FF789).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0FF789),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelector(String label, int index) {
    final isSelected = _selectedMetricIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMetricIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0FF789) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 
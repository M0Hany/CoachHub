import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/http_client.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../core/constants/enums.dart';
import 'package:dio/dio.dart';
import 'dart:math';
import '../../../../features/coach/presentation/screens/home/coach_home_screen.dart';

class ViewTraineeProfileScreen extends StatefulWidget {
  final int traineeId;
  const ViewTraineeProfileScreen({super.key, required this.traineeId});

  @override
  State<ViewTraineeProfileScreen> createState() => _ViewTraineeProfileScreenState();
}

class _ViewTraineeProfileScreenState extends State<ViewTraineeProfileScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _traineeProfile;
  Map<String, dynamic>? _workoutPlan;
  Map<String, dynamic>? _nutritionPlan;
  List<Map<String, dynamic>> _healthHistory = [];
  TabController? _tabController;
  Map<String, dynamic>? _recommendations;
  int _selectedFoodCategory = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchTraineeData();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchTraineeData() async {
    
    // Check if widget is still mounted before proceeding
    if (!mounted) {
      return;
    }
    
    setState(() { 
      _isLoading = true; 
    });
    try {
      final httpClient = HttpClient();
      final response = await httpClient.get<Map<String, dynamic>>(
        '/api/profile/${widget.traineeId}',
      );
      
      // Check if widget is still mounted before processing response
      if (!mounted) {
        return;
      }
      
      if (response.data?['status'] == 'success') {
        final profile = response.data!['data']['profile'];
        _traineeProfile = profile;
        
        // Clear previous plan data
        _workoutPlan = null;
        _nutritionPlan = null;
        
        // Fetch plans if assigned
        final assignedWorkout = profile['assignedWorkout'];
        
        if (assignedWorkout != null && assignedWorkout['workout_id'] != null) {
          final workoutId = assignedWorkout['workout_id'];
          final workoutResp = await httpClient.get<Map<String, dynamic>>('/api/plans/workout/$workoutId');
          
          // Check if widget is still mounted before processing workout response
          if (!mounted) {
            return;
          }
          
          if (workoutResp.data?['status'] == 'success') {
            _workoutPlan = workoutResp.data!['data']['workout_plan'];
          }
        } else {
        }
        
        final assignedNutrition = profile['assignedNutrition'];
        
        if (assignedNutrition != null && assignedNutrition['nutrition_id'] != null) {
          final nutritionId = assignedNutrition['nutrition_id'];
          final nutritionResp = await httpClient.get<Map<String, dynamic>>('/api/plans/nutrition/$nutritionId');
          
          // Check if widget is still mounted before processing nutrition response
          if (!mounted) {
            return;
          }
          
          if (nutritionResp.data?['status'] == 'success') {
            _nutritionPlan = nutritionResp.data!['data']['nutrition_plan'];
          }
        } else {
        }

        // Get health history data for the trainee
        try {
          final healthResponse = await httpClient.get<Map<String, dynamic>>(
            '/api/trainee/health/${widget.traineeId}',
          );

          // Check if widget is still mounted before processing health response
          if (!mounted) {
            return;
          }

          if (healthResponse.data?['status'] == 'success') {
            final healthData = healthResponse.data!['data'] as List<dynamic>;
            _healthHistory = healthData
                .map((item) => item as Map<String, dynamic>)
                .toList();
            
            // Sort by ID (or created_at if ID is not available)
            _healthHistory.sort((a, b) {
              if (a['id'] != null && b['id'] != null) {
                return (a['id'] as int).compareTo(b['id'] as int);
              } else if (a['created_at'] != null && b['created_at'] != null) {
                return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
              }
              return 0;
            });
          }
        } catch (e) {
          _healthHistory = [];
        }

        // Get recommendations for the trainee
        try {
          final recommendationsResponse = await httpClient.get<Map<String, dynamic>>(
            '/api/recommendation/plan/${widget.traineeId}',
          );

          // Check if widget is still mounted before processing recommendations response
          if (!mounted) {
            return;
          }

          if (recommendationsResponse.data?['status'] == 'success') {
            _recommendations = recommendationsResponse.data!['data'];
          }
        } catch (e) {
          _recommendations = null;
        }
      } else {
        _error = response.data?['message'] ?? 'Failed to fetch trainee profile';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() { 
          _isLoading = false; 
        });
      } else {
      }
    }
  }

  Future<void> _refreshData() async {
    
    // Check if widget is still mounted before proceeding
    if (!mounted) {
      return;
    }
    
    _error = null; // Clear any previous errors
    await _fetchTraineeData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.mainBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildExtendedAppBar(context, l10n),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  return _refreshData();
                },
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                        : _buildContent(context, l10n),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.coach,
        currentIndex: 2, // Home tab
      ),
    );
  }

  Widget _buildExtendedAppBar(BuildContext context, AppLocalizations l10n) {
    final profile = _traineeProfile;
    final String? imageUrl = profile?['image_url'];
    final String fullName = profile?['full_name'] ?? '';
    final int? age = profile?['age'];
    final String gender = profile?['gender'] ?? '';
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D122A),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.accent),
                onPressed: () => context.pop(),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    l10n.healthInformation,
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.accent),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.push(
                    '/chat/room/${widget.traineeId}',
                    extra: {
                      'recipientId': widget.traineeId.toString(),
                      'recipientName': profile?['full_name'] ?? 'Trainee',
                    },
                  );
                },
                child: Image.asset(
                  'assets/icons/navigation/Chat Accent.png',
                  width: 28,
                  height: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
                      : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: AppTheme.headerMedium.copyWith(color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${l10n.age}: ${age ?? '-'}',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.accent),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        gender.isNotEmpty
                            ? l10n.gender + ': ' +
                                (gender.toLowerCase() == 'male'
                                    ? l10n.male
                                    : gender.toLowerCase() == 'female'
                                        ? l10n.female
                                        : gender)
                            : '',
                        style: AppTheme.bodySmall.copyWith(color: AppTheme.accent),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    final profile = _traineeProfile;
    
    if (profile == null || _tabController == null) {
      return const SizedBox();
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0).copyWith(bottom: 90),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs in a box
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController!,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: AppColors.accent),
                insets: EdgeInsets.symmetric(horizontal: -24),
              ),
              indicatorColor: Colors.transparent,
              labelColor: AppColors.textDark,
              unselectedLabelColor: AppColors.textDark.withOpacity(0.6),
              tabs: [
                Tab(text: l10n.workoutPlans),
                Tab(text: l10n.nutritionPlans),
              ],
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dividerColor: Colors.transparent,
            ),
          ),
          // TabBarView content directly on background, aligned
          SizedBox(
            height: 350,
            child: TabBarView(
              controller: _tabController!,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWorkoutPlanSection(context, l10n),
                    const SizedBox(height: 16),
                    _buildSuggestedExercisesSection(l10n),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNutritionPlanSection(context, l10n),
                    const SizedBox(height: 16),
                    _buildSuggestedFoodSection(l10n),
                  ],
                ),
              ],
            ),
          ),
          // Dashboard
          _buildDashboardSection(l10n),
          const SizedBox(height: 24),
          // Graph
          _buildGraphSection(l10n),
          const SizedBox(height: 30),
          // End Subscription Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showEndSubscriptionDialog(context),
              child: Text(l10n.endSubscription),
            ),
          ),
          const SizedBox(height: 35),
        ],
      ),
    );
  }

  Widget _buildWorkoutPlanSection(BuildContext context, AppLocalizations l10n) {
    if (_workoutPlan == null) {
      return _buildNoPlanSection(l10n.noWorkoutPlans, l10n.assignPlan, () {
        _showAssignPlanDialog(context, 'workout');
      });
    }
    // Show workout plan details
    final plan = _workoutPlan!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.workout_plans_day, style: AppTheme.bodyMedium.copyWith(color: AppTheme.labelColor)),
                Text('1', style: AppTheme.headerLarge.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan['title'] ?? 'Workout Plan',
                          style: AppTheme.headerMedium.copyWith(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.planDurationDays(plan['duration'] ?? 0),
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.labelColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: -8,
                  child: GestureDetector(
                    onTap: () => _showUnassignPlanDialog(context, 'workout'),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPlanSection(BuildContext context, AppLocalizations l10n) {
    if (_nutritionPlan == null) {
      return _buildNoPlanSection(l10n.noNutritionPlans, l10n.assignPlan, () {
        _showAssignPlanDialog(context, 'nutrition');
      });
    }
    // Show nutrition plan details
    final plan = _nutritionPlan!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.workout_plans_day, style: AppTheme.bodyMedium.copyWith(color: AppTheme.labelColor)),
                Text('1', style: AppTheme.headerLarge.copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          plan['title'] ?? 'Nutrition Plan',
                          style: AppTheme.headerMedium.copyWith(fontSize: 16),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.planDurationDays(plan['duration'] ?? 0),
                          style: AppTheme.bodySmall.copyWith(color: AppTheme.labelColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: -8,
                  child: GestureDetector(
                    onTap: () => _showUnassignPlanDialog(context, 'nutrition'),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlanSection(String message, String buttonText, VoidCallback onAssign) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            message,
            style: AppTheme.bodySmall.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              textStyle: AppTheme.bodySmall,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  // Helper to parse exercise string into a list
  List<String> _parseExerciseList(String? exercise) {
    if (exercise == null || exercise.trim().isEmpty) return [];
    // Split by comma or 'or' and trim, capitalize first letter
    final list = exercise
        .replaceAll(' or ', ',')
        .split(',')
        .map((e) {
          final trimmed = e.trim();
          if (trimmed.isEmpty) return '';
          return trimmed[0].toUpperCase() + trimmed.substring(1);
        })
        .where((e) => e.isNotEmpty)
        .toList();
    if (list.isNotEmpty) {
      // Remove trailing full stop from the last item
      list[list.length - 1] = list.last.replaceAll(RegExp(r'\.\$'), '');
    }
    return list;
  }

  // Helper to parse diet string into a map of category -> items
  Map<String, List<String>> _parseDietMap(String? diet) {
    if (diet == null || diet.trim().isEmpty) return {};
    final Map<String, List<String>> result = {};
    final categoryRegex = RegExp(r'([\w ]+): *\(([^)]*)\)');
    for (final match in categoryRegex.allMatches(diet)) {
      final category = match.group(1)?.trim() ?? '';
      final items = match.group(2)?.split(',').map((e) {
        var item = e.trim();
        if (item.toLowerCase().startsWith('and ')) {
          item = item.substring(4).trim();
        }
        // Remove trailing 'and' if present (e.g., 'Milk, and Baru Nuts')
        if (item.toLowerCase().endsWith(' and')) {
          item = item.substring(0, item.length - 4).trim();
        }
        return item;
      }).where((e) => e.isNotEmpty).toList() ?? [];
      if (category.isNotEmpty && items.isNotEmpty) {
        result[category] = items;
      }
    }
    return result;
  }

  Widget _buildSuggestedExercisesSection(AppLocalizations l10n) {
    final exercises = _parseExerciseList(_recommendations?['exercise']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.suggestedExercises, style: AppTheme.headerSmall),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: exercises.isEmpty
              ? Text(l10n.noSuggestedExercises, style: AppTheme.bodyMedium)
              : SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: exercises
                        .map((e) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(e, style: AppTheme.bodySmall.copyWith(color: AppColors.textDark)),
                            ))
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSuggestedFoodSection(AppLocalizations l10n) {
    final dietMap = _parseDietMap(_recommendations?['diet']);
    final categories = ['Vegetables', 'Protein Intake', 'Juice'];
    // Only show categories that exist in the parsed map
    final availableCategories = categories.where((c) => dietMap.containsKey(c)).toList();
    // If none of the expected categories are present, show all keys
    final displayCategories = availableCategories.isNotEmpty ? availableCategories : dietMap.keys.toList();
    // Clamp selected index
    if (_selectedFoodCategory >= displayCategories.length) _selectedFoodCategory = 0;
    final selectedCategory = displayCategories.isNotEmpty ? displayCategories[_selectedFoodCategory] : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.suggestedFood, style: AppTheme.headerSmall),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: dietMap.isEmpty
              ? Text(l10n.noSuggestedFood, style: AppTheme.bodyMedium)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs for food categories
                    Row(
                      children: List.generate(displayCategories.length, (i) {
                        final isSelected = _selectedFoodCategory == i;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFoodCategory = i;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.accent : const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                displayCategories[i],
                                style: AppTheme.bodySmall.copyWith(
                                  color: isSelected ? Colors.black : AppTheme.textDark.withOpacity(0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: selectedCategory == null
                            ? Text(l10n.noSuggestedFood, style: AppTheme.bodyMedium)
                            : Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: dietMap[selectedCategory]!
                                    .map((item) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(item, style: AppTheme.bodySmall.copyWith(color: AppColors.textDark)),
                                        ))
                                    .toList(),
                              ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildDashboardSection(AppLocalizations l10n) {
    final profile = _traineeProfile;
    if (profile == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.dashboard, style: AppTheme.headerSmall),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricItem(
              iconAsset: 'assets/icons/Weight.png',
              label: l10n.weightLabel,
              value: profile['weight']?.toString() ?? '0',
              unit: l10n.kg,
            ),
            _buildMetricItem(
              iconAsset: 'assets/icons/Height.png',
              label: l10n.heightLabel,
              value: profile['height']?.toString() ?? '0',
              unit: l10n.cm,
            ),
            _buildMetricItem(
              iconAsset: 'assets/icons/Fats.png',
              label: l10n.fatsLabel,
              value: profile['body_fat']?.toString() ?? '0',
              unit: l10n.percentSymbol,
            ),
            _buildMetricItem(
              iconAsset: 'assets/icons/Muscle.png',
              label: l10n.muscleLabel,
              value: profile['body_muscle']?.toString() ?? '0',
              unit: l10n.percentSymbol,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem({
    String? iconAsset,
    required String label,
    required String value,
    required String unit,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          child: iconAsset != null
              ? Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Image.asset(iconAsset, fit: BoxFit.contain),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.bodySmall),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(unit, style: AppTheme.bodySmall),
          ],
        ),
      ],
    );
  }

  Widget _buildMealCell(String meal, bool isLast) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: meal.isEmpty
                  ? const SizedBox()
                  : Text(
                      meal,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          if (!isLast)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 1,
              color: AppColors.background,
            ),
        ],
      ),
    );
  }

  Widget _buildGraphSection(AppLocalizations l10n) {
    final profile = _traineeProfile;
    if (profile == null) return const SizedBox();
    return _HealthGraphSection(
      currentFat: double.tryParse(profile['body_fat']?.toString() ?? '0') ?? 0,
      currentWeight: double.tryParse(profile['weight']?.toString() ?? '0') ?? 0,
      currentMuscle: double.tryParse(profile['body_muscle']?.toString() ?? '0') ?? 0,
      healthHistory: _healthHistory,
    );
  }

  void _showAssignPlanDialog(BuildContext context, String planType) async {
    showDialog(
      context: context,
      builder: (context) {
        return _AssignPlanDialog(
          planType: planType,
          traineeId: widget.traineeId,
          onPlanSelected: (planId) async {
            Navigator.of(context).pop();
            await _assignPlanToTrainee(context, planType, planId);
          },
        );
      },
    );
  }

  Future<void> _assignPlanToTrainee(BuildContext context, String planType, int planId) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final httpClient = HttpClient();
      final endpoint = planType == 'workout'
          ? '/api/plans/workout/assign/$planId'
          : '/api/plans/nutrition/assign/$planId';

      final response = await httpClient.post<Map<String, dynamic>>(
        endpoint,
        data: {'trainee_id': widget.traineeId},
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );


      if (response.data?['status'] == 'success') {

        // Check if widget is still mounted before updating UI
        if (!mounted) {
          return;
        }

        // Fetch the assigned plan details to update the UI
        try {
          final planEndpoint = planType == 'workout'
              ? '/api/plans/workout/$planId'
              : '/api/plans/nutrition/$planId';

          final planResponse = await httpClient.get<Map<String, dynamic>>(planEndpoint);

          if (!mounted) {
            return;
          }

          if (planResponse.data?['status'] == 'success') {
            final planData = planType == 'workout'
                ? planResponse.data!['data']['workout_plan']
                : planResponse.data!['data']['nutrition_plan'];

            setState(() {
              if (planType == 'workout') {
                _workoutPlan = planData;
              } else {
                _nutritionPlan = planData;
              }
            });
          }
        } catch (e) {
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              planType == 'workout'
                  ? l10n.workoutPlanAssignedSuccessfully
                  : l10n.nutritionPlanAssignedSuccessfully,
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80, // Account for bottom nav bar
              left: 16,
              right: 16,
            ),
          ),
        );
      } else {

        // Check if widget is still mounted before showing snackbar
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?['message'] ?? 'Failed to assign plan'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80, // Account for bottom nav bar
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    } catch (e) {

      // Check if widget is still mounted before showing snackbar
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80, // Account for bottom nav bar
            left: 16,
            right: 16,
          ),
        ),
      );
    }
  }

  void _showUnassignPlanDialog(BuildContext context, String planType) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unassignPlanConfirmTitle),
        content: Text(l10n.unassignPlanConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _unassignPlanFromTrainee(context, planType);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _unassignPlanFromTrainee(BuildContext context, String planType) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final httpClient = HttpClient();
      final endpoint = planType == 'workout'
          ? '/api/plans/workout/unassign'
          : '/api/plans/nutrition/unassign';
      
      final response = await httpClient.delete<Map<String, dynamic>>(
        endpoint,
        data: {'trainee_id': widget.traineeId},
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );


      if (response.data?['status'] == 'success') {
        
        // Check if widget is still mounted before updating UI
        if (!mounted) {
          return;
        }
        
        // Update local state directly
        setState(() {
          if (planType == 'workout') {
            _workoutPlan = null;
          } else {
            _nutritionPlan = null;
          }
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.unassignPlanSuccess),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80, // Account for bottom nav bar
              left: 16,
              right: 16,
            ),
          ),
        );
      } else {
        
        // Check if widget is still mounted before showing snackbar
        if (!mounted) {
          return;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?['message'] ?? l10n.unassignPlanError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80, // Account for bottom nav bar
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    } catch (e) {
      
      // Check if widget is still mounted before showing snackbar
      if (!mounted) {
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unassignPlanError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80, // Account for bottom nav bar
            left: 16,
            right: 16,
          ),
        ),
      );
    }
  }

  void _showEndSubscriptionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.endSubscriptionTitle),
        content: Text(l10n.endSubscriptionMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _endSubscription(context);
              // Close dialog after navigation attempt
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _endSubscription(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final httpClient = HttpClient();
      
      final response = await httpClient.patch<Map<String, dynamic>>(
        '/api/subscription/end',
        data: {'trainee_id': widget.traineeId},
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );
      
      
      if (response.data?['status'] == 'success') {
        
        // Remove trainee from coach home screen local state
        try {
          CoachHomeScreen.removeTrainee(widget.traineeId);
        } catch (removeError) {
        }
        
        if (mounted) {
          
          // Navigate back to coach home screen using context.pop()
          try {
            context.pop();
          } catch (navigationError) {
          }
        } else {
        }
      } else {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data?['message'] ?? l10n.endSubscriptionError),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 80,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.endSubscriptionError),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 80,
            left: 16,
            right: 16,
          ),
        ),
      );
    }
  }
}

class _AssignPlanDialog extends StatefulWidget {
  final String planType; // 'workout' or 'nutrition'
  final int traineeId;
  final void Function(int planId) onPlanSelected;
  const _AssignPlanDialog({
    required this.planType, 
    required this.traineeId,
    required this.onPlanSelected,
  });

  @override
  State<_AssignPlanDialog> createState() => _AssignPlanDialogState();
}

class _AssignPlanDialogState extends State<_AssignPlanDialog> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() { _isLoading = true; });
    try {
      final httpClient = HttpClient();
      final endpoint = widget.planType == 'workout'
          ? '/api/plans/workout/my-plans'
          : '/api/plans/nutrition/my-plans';
      final response = await httpClient.get<Map<String, dynamic>>(endpoint);
      if (response.data?['status'] == 'success') {
        final plansData = widget.planType == 'workout'
            ? response.data!['data']['workout_plans']['plans']
            : response.data!['data']['nutrition_plans']['plans'];
        _plans = List<Map<String, dynamic>>.from(plansData);
      } else {
        _error = response.data?['message'] ?? 'Failed to fetch plans';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: AppTheme.mainBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 350,
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.planType == 'workout' ? l10n.workoutPlans : l10n.nutritionPlans,
                    style: AppTheme.headerSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                      : _plans.isEmpty
                          ? Center(child: Text(l10n.noPlanData))
                          : ListView.builder(
                              itemCount: _plans.length,
                              itemBuilder: (context, index) {
                                final plan = _plans[index];
                                return GestureDetector(
                                  onTap: () => widget.onPlanSelected(plan['id']),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: ListTile(
                                      title: Text(plan['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                      subtitle: Text('${plan['duration']} days'),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// Graph section copied from trainee_home_screen.dart
class _HealthGraphSection extends StatefulWidget {
  final double currentFat;
  final double currentWeight;
  final double currentMuscle;
  final List<Map<String, dynamic>> healthHistory;

  const _HealthGraphSection({
    required this.currentFat,
    required this.currentWeight,
    required this.currentMuscle,
    required this.healthHistory,
  });

  @override
  State<_HealthGraphSection> createState() => _HealthGraphSectionState();
}

class _HealthGraphSectionState extends State<_HealthGraphSection> {
  int selectedMetric = 0; // 0: Fats, 1: Weight, 2: Muscle
  int selectedBar = 0; // Default to first bar

  static const double _graphHeight = 130;

  List<double> getHealthData(int metric) {
    List<double> data = [];
    
    // Add historical data
    for (var healthRecord in widget.healthHistory) {
      switch (metric) {
        case 0: // Fats
          data.add(double.tryParse(healthRecord['body_fat']?.toString() ?? '0') ?? 0);
          break;
        case 1: // Weight
          data.add(double.tryParse(healthRecord['weight']?.toString() ?? '0') ?? 0);
          break;
        case 2: // Muscle
          data.add(double.tryParse(healthRecord['body_muscle']?.toString() ?? '0') ?? 0);
          break;
      }
    }
    
    // Add current data
    switch (metric) {
      case 0:
        data.add(widget.currentFat);
        break;
      case 1:
        data.add(widget.currentWeight);
        break;
      case 2:
        data.add(widget.currentMuscle);
        break;
    }
    
    // If no data, return current value only
    if (data.isEmpty) {
      switch (metric) {
        case 0:
          return [widget.currentFat];
        case 1:
          return [widget.currentWeight];
        case 2:
          return [widget.currentMuscle];
        default:
          return [0];
      }
    }
    
    return data;
  }

  List<String> getMonthLabels() {
    List<String> labels = [];
    
    // Add historical month labels
    for (var healthRecord in widget.healthHistory) {
      try {
        final date = DateTime.parse(healthRecord['created_at']);
        labels.add(_getMonthAbbreviation(date.month));
      } catch (e) {
        labels.add('N/A');
      }
    }
    
    // Add current month label
    final now = DateTime.now();
    labels.add(_getMonthAbbreviation(now.month));
    
    return labels;
  }

  String _getMonthAbbreviation(int month) {
    switch (month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return 'N/A';
    }
  }

  String getMetricLabel(int metric, AppLocalizations l10n) {
    switch (metric) {
      case 0:
        return l10n.currentFatPercentage;
      case 1:
        return l10n.bodyWeight;
      case 2:
        return l10n.bodyMuscle;
      default:
        return '';
    }
  }

  String getMetricUnit(int metric, AppLocalizations l10n) {
    switch (metric) {
      case 0:
        return l10n.percentSymbol;
      case 1:
        return l10n.kg;
      case 2:
        return l10n.percentSymbol;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = getHealthData(selectedMetric);
    final currentValue = data.isNotEmpty ? data.last : 0;
    final metricLabel = getMetricLabel(selectedMetric, l10n);
    final metricUnit = getMetricUnit(selectedMetric, l10n);
    final metricNames = [l10n.fatsLabel, l10n.weightLabel, l10n.muscleLabel];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D122A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(3, (i) {
              final isSelected = selectedMetric == i;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMetric = i;
                      selectedBar = data.length - 1; // Reset to last bar (current value)
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.accent : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      metricNames[i],
                      style: AppTheme.bodySmall.copyWith(
                        color: isSelected ? Colors.black : AppTheme.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            metricLabel,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 4),
          Text(
            '$currentValue$metricUnit',
            style: AppTheme.bodyLarge.copyWith(color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),
          // Graph
          Column(
            children: [
              SizedBox(
                height: _graphHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (index) {
                    final isSelected = selectedBar == index;
                    final max = data.reduce((a, b) => a > b ? a : b);
                    final min = data.reduce((a, b) => a < b ? a : b);
                    
                    // Improved height calculation with better normalization
                    double barHeight;
                    if (max == min) {
                      barHeight = 0.7; // Default height when all values are the same
                    } else {
                      // Calculate normalized value (0 to 1)
                      final normalizedValue = (data[index] - min) / (max - min);
                      
                      // Apply a power function to amplify small differences
                      // Using power of 0.7 to make differences more visible
                      final amplifiedValue = pow(normalizedValue, 0.7);
                      
                      // Map to height range (0.3 to 1.0)
                      barHeight = 0.3 + (0.7 * amplifiedValue);
                    }
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBar = index;
                        });
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 30,
                            height: (_graphHeight - 30) * barHeight,
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accent : const Color(0xFF434E81),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: -38,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  '${data[index]}$metricUnit',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              // Month labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: getMonthLabels().map((month) {
                  return SizedBox(
                    width: 30,
                    child: Text(
                      month,
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textLight),
                      textAlign: TextAlign.center,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../../features/coach/presentation/providers/coach_search_provider.dart';
import '../../../../../features/coach/data/models/coach_model.dart';
import 'view_coach_profile_screen.dart';

class TraineeSearchScreen extends StatefulWidget {
  const TraineeSearchScreen({super.key});

  @override
  State<TraineeSearchScreen> createState() => _TraineeSearchScreenState();
}

class _TraineeSearchScreenState extends State<TraineeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachSearchProvider>().searchCoaches(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<CoachSearchProvider>();
      provider.searchCoaches(isRecommendation: _selectedFilter == 'Recommendations');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CoachSearchProvider>().searchCoaches(query: query, refresh: true);
    });
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
      
      final provider = context.read<CoachSearchProvider>();
      provider.resetSearch();
      if (filter == 'Recommendations') {
        provider.searchCoaches(refresh: true, isRecommendation: true);
      } else {
        provider.searchCoaches(refresh: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.mainBackgroundColor,
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(15),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.accent),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Search',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 45,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textDark,
                        ),
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: l10n.searchForCoachesFields,
                          hintStyle: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textDark.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppTheme.textDark,
                            size: 20,
                          ),
                          suffixIcon: Icon(
                            Icons.menu,
                            color: AppTheme.textDark,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          _buildFilterChip('All'),
                          const SizedBox(width: 12),
                          _buildFilterChip('Recommendations'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Consumer<CoachSearchProvider>(
                        builder: (context, provider, child) {
                          if (provider.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(provider.errorMessage ?? 'An error occurred'),
                                  ElevatedButton(
                                    onPressed: () => provider.searchCoaches(
                                      refresh: true,
                                      isRecommendation: _selectedFilter == 'Recommendations',
                                    ),
                                    child: Text(l10n.retry),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!provider.isLoading && provider.coaches.isEmpty) {
                            return Center(
                              child: Text(
                                l10n.noRecommendedCoaches,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          return Stack(
                            children: [
                              GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.zero,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: provider.coaches.length + (provider.hasMoreData ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= provider.coaches.length) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final coach = provider.coaches[index];
                                  return _buildCoachCard(context, coach, l10n);
                                },
                              ),
                              if (provider.isLoading && provider.coaches.isEmpty)
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavBar(
          role: UserRole.trainee,
          currentIndex: 0,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: isSelected ? AppTheme.textDark : AppTheme.textDark.withOpacity(0.7),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onFilterChanged(label);
        }
      },
      selectedColor: AppTheme.accent,
      backgroundColor: AppTheme.mainBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(
          color: isSelected ? AppTheme.accent : AppTheme.textDark.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      labelPadding: EdgeInsets.zero,
    );
  }

  Widget _buildCoachCard(BuildContext context, CoachModel coach, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accent,
                width: 1.5,
              ),
            ),
            child: _buildProfileImage(coach.imageUrl),
          ),
          const SizedBox(height: 8),
          Text(
            coach.fullName,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < coach.rating.floor()
                    ? Icons.star
                    : index < coach.rating
                        ? Icons.star_half
                        : Icons.star_border,
                color: AppTheme.accent,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 100,
            height: 30,
            child: ElevatedButton(
              onPressed: () {
                context.go('/trainee/coach/${coach.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Show Profile',
                style: AppTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
        : null;
    return CircleAvatar(
      radius: 40,
      backgroundImage: fullUrl != null
          ? NetworkImage(fullUrl)
          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
    );
  }
} 
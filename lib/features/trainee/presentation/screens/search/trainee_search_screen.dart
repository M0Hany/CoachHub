import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../core/constants/enums.dart';
import '../../../../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class TraineeSearchScreen extends StatefulWidget {
  const TraineeSearchScreen({super.key});

  @override
  State<TraineeSearchScreen> createState() => _TraineeSearchScreenState();
}

class _TraineeSearchScreenState extends State<TraineeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _mockCoaches = [
    {
      'id': '1',
      'name': 'Coach_Sameh',
      'image': 'assets/images/default_profile.jpg',
      'rating': 4.5,
    },
    {
      'id': '2',
      'name': 'walid_Adel_',
      'image': 'assets/images/default_profile.jpg',
      'rating': 5.0,
    },
    {
      'id': '3',
      'name': 'Shimaa_Ragab',
      'image': 'assets/images/default_profile.jpg',
      'rating': 4.5,
    },
    {
      'id': '4',
      'name': 'Coach_Mustafa',
      'image': 'assets/images/default_profile.jpg',
      'rating': 3.5,
    },
    {
      'id': '5',
      'name': 'Jessie_Elbaz',
      'image': 'assets/images/default_profile.jpg',
      'rating': 3.0,
    },
    {
      'id': '6',
      'name': 'Islam_AbuAuf',
      'image': 'assets/images/default_profile.jpg',
      'rating': 3.0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D122A),
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const BackButton(color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.searchForClientsFields,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () {
                        // TODO: Implement filter dialog
                      },
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Filter Tabs
            Container(
              color: Colors.grey[200],
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Recommendations'),
                  ],
                ),
              ),
            ),
            // Coaches Grid
            Expanded(
              child: Container(
                color: Colors.grey[200],
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _mockCoaches.length,
                  itemBuilder: (context, index) {
                    final coach = _mockCoaches[index];
                    return _buildCoachCard(context, coach, l10n);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 0,
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = label;
          });
        }
      },
      selectedColor: AppTheme.secondaryButtonColor,
      backgroundColor: Colors.white,
    );
  }

  Widget _buildCoachCard(BuildContext context, Map<String, dynamic> coach, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(coach['image']),
          ),
          const SizedBox(height: 8),
          Text(
            coach['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Icon(
                index < coach['rating'].floor()
                    ? Icons.star
                    : index < coach['rating']
                        ? Icons.star_half
                        : Icons.star_border,
                color: AppTheme.secondaryButtonColor,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 8),
          _buildActionButton('Show Profile', false, coach, l10n),
          const SizedBox(height: 4),
          _buildActionButton('Subscribe', true, coach, l10n),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, bool isPrimary, Map<String, dynamic> coach, AppLocalizations l10n) {
    return SizedBox(
      width: 100,
      height: 30,
      child: ElevatedButton(
        onPressed: () {
          if (label == 'Show Profile') {
            context.go('/trainee/coach/${coach['id']}');
          } else if (label == 'Subscribe') {
            // TODO: Implement subscribe functionality
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPrimary ? AppTheme.secondaryButtonColor : Colors.white,
          foregroundColor:
              isPrimary ? Colors.black : AppTheme.secondaryButtonColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: AppTheme.secondaryButtonColor,
              width: isPrimary ? 0 : 1,
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
} 
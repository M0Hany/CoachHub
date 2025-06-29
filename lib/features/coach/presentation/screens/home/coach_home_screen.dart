import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _coachProfile;
  List<Map<String, dynamic>> _clients = [];
  int _totalClients = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final httpClient = HttpClient();

      // Get coach profile
      _coachProfile = authProvider.currentUser?.toJson();

      // Get subscribed clients
      final response = await httpClient.get<Map<String, dynamic>>(
        '/api/subscription/clients',
      );

      if (response.data?['status'] == 'success') {
        final clientsData = response.data!['data'];
        _totalClients = clientsData['total'] as int;
        if (_totalClients > 0) {
          _clients = (clientsData['clients'] as List)
              .map((client) => client['trainee'] as Map<String, dynamic>)
              .toList();
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

    return Scaffold(
      backgroundColor: AppTheme.mainBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Profile header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage(
                            _coachProfile?['image'] != null
                                ? _coachProfile!['image']
                                : 'assets/images/default_profile.jpg',
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.goodMorning,
                            style: AppTheme.bodyMedium,
                          ),
                          Text(
                            _coachProfile?['name'] ?? '',
                            style: AppTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryButtonColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      style: const TextStyle(color: AppTheme.textLight),
                      decoration: InputDecoration(
                        hintText: l10n.searchClients,
                        hintStyle: const TextStyle(color: AppTheme.textLight),
                        border: InputBorder.none,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Icon(Icons.search, color: AppTheme.textLight),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 40),
                        fillColor: AppTheme.primaryButtonColor,
                        filled: true,
                      ),
                    ),
                  ),
                ),

                // Clients grid
                Expanded(
                  child: _totalClients == 0
                      ? Center(
                          child: Text(
                            l10n.noTraineesSubscribed,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 100,
                          ),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 13,
                            mainAxisSpacing: 22,
                          ),
                          itemCount: _clients.length,
                          itemBuilder: (context, index) {
                            final client = _clients[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 74,
                                    height: 74,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.accent,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundColor: const Color(0xFF0FF789).withOpacity(0.2),
                                      backgroundImage: AssetImage(
                                        client['image_url'] != null
                                            ? client['image_url']
                                            : 'assets/images/default_profile.jpg',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    client['full_name'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    l10n.ageGender(
                                      client['age'].toString(),
                                      client['gender'] as String,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 120,
                                    height: 32,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // TODO: Implement health data viewing
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accent,
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        l10n.showHealthData,
                                        style: AppTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavBar(
              role: UserRole.coach,
              currentIndex: 2, // Home tab
            ),
          ),
        ],
      ),
    );
  }
} 
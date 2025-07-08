import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/network/http_client.dart';
import 'package:provider/provider.dart';
import '../../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
  
  // Static callback to remove trainee from any instance
  static Function(int)? _removeTraineeCallback;
  
  // Static method to set the callback
  static void setRemoveTraineeCallback(Function(int) callback) {
    _removeTraineeCallback = callback;
  }
  
  // Static method to remove trainee from the current instance
  static void removeTrainee(int traineeId) {
    if (_removeTraineeCallback != null) {
      _removeTraineeCallback!(traineeId);
    }
  }
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _coachProfile;
  List<Map<String, dynamic>> _clients = [];
  int _totalClients = 0;
  int _totalSubscriptionRequests = 0;
  List<Map<String, dynamic>> _subscriptionRequests = [];
  
  // Method to remove a trainee from local state when subscription ends
  void removeTraineeFromLocalState(int traineeId) {
    setState(() {
      _clients.removeWhere((client) => client['id'] == traineeId);
      _totalClients = _clients.length;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Set up the callback for removing trainees
    CoachHomeScreen.setRemoveTraineeCallback(removeTraineeFromLocalState);
  }

  Future<void> _loadData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final httpClient = HttpClient();

      // Get coach profile
      final profileResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/profile/',
      );

      if (profileResponse.data?['status'] == 'success') {
        _coachProfile = profileResponse.data!['data']['profile'];
      }

      // Get subscribed clients
      final clientsResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/subscription/clients',
      );

      if (clientsResponse.data?['status'] == 'success') {
        final clientsData = clientsResponse.data!['data'];
        _totalClients = clientsData['total'] as int;
        if (_totalClients > 0) {
          _clients = (clientsData['clients'] as List)
              .map((client) => client['trainee'] as Map<String, dynamic>)
              .toList();
        }
      }

      // Get subscription requests
      final requestsResponse = await httpClient.get<Map<String, dynamic>>(
        '/api/subscription/requests',
      );

      if (requestsResponse.data?['status'] == 'success') {
        final requestsData = requestsResponse.data!['data'];
        _totalSubscriptionRequests = requestsData['total'] as int;
        if (_totalSubscriptionRequests > 0) {
          _subscriptionRequests = (requestsData['requests'] as List)
              .map((request) => request as Map<String, dynamic>)
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

  Widget _buildProfileImage(Map<String, dynamic>? profile, {double radius = 40}) {
    String? imageUrl = profile?['image_url'] as String?;
    String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
        : null;
    return CircleAvatar(
      radius: radius,
      backgroundImage: fullUrl != null
          ? NetworkImage(fullUrl)
          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
    );
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppTheme.mainBackgroundColor,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.mainBackgroundColor,
        body: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                              child: _buildProfileImage(_coachProfile),
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
                                  _coachProfile?['full_name'] ?? '',
                                  style: AppTheme.headerSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.push('/coach/subscription-requests');
                                  },
                                  icon: Image.asset(
                                    'assets/icons/navigation/Requests.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                                if (_totalSubscriptionRequests > 0)
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        _totalSubscriptionRequests.toString(),
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    context.push('/notifications');
                                  },
                                  icon: Image.asset(
                                    'assets/icons/navigation/Notifications.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                ),
                              ],
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
                    child: RefreshIndicator(
                      onRefresh: _loadData,
                      child: _totalClients == 0
                          ? SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.6,
                                child: Center(
                                  child: Text(
                                    l10n.noTraineesSubscribed,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
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
                                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.accent,
                                            width: 2,
                                          ),
                                        ),
                                        child: _buildProfileImage(client),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        client['full_name'] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 120,
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final traineeId = client['id'];
                                            context.push('/coach/view-trainee/$traineeId');
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
      ),
    );
  }
} 
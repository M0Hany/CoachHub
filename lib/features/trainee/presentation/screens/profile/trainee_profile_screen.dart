import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../../features/auth/models/user_model.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/enums.dart';
import 'dart:developer' as developer;
import 'dart:io';
import '../../../../../../l10n/app_localizations.dart';

class TraineeProfileScreen extends StatefulWidget {
  const TraineeProfileScreen({super.key});

  static const _navyColor = Color(0xFF0D122A);
  static const _accentGreen = Color(0xFF0FF789);

  @override
  State<TraineeProfileScreen> createState() => _TraineeProfileScreenState();
}

class _TraineeProfileScreenState extends State<TraineeProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshProfile();
    });
  }

  String _formatGoals(List<Goal>? goals) {
    if (goals == null || goals.isEmpty) return 'Not set';
    return goals.map((goal) => goal.name).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final trainee = context.watch<AuthProvider>().currentUser;
    final l10n = AppLocalizations.of(context)!;

    developer.log('Building TraineeProfileScreen');
    developer.log('Profile Image URL: ${trainee?.imageUrl}',
        name: 'TraineeProfileScreen');
    developer.log('Weight: ${trainee?.traineeData?.weight}',
        name: 'TraineeProfileScreen');
    developer.log('Height: ${trainee?.traineeData?.height}',
        name: 'TraineeProfileScreen');
    developer.log('Body Fat: ${trainee?.traineeData?.bodyFat}',
        name: 'TraineeProfileScreen');
    developer.log('Body Muscle: ${trainee?.traineeData?.bodyMuscle}',
        name: 'TraineeProfileScreen');
    developer.log('Goals: ${trainee?.traineeData?.goals?.map((g) => g.name).join(", ")}',
        name: 'TraineeProfileScreen');

    if (context.watch<AuthProvider>().isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (context.watch<AuthProvider>().error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${context.watch<AuthProvider>().error}'),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().resetError();
                  context.read<AuthProvider>().refreshProfile();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDDD6D6),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 16.0,
                  bottom: 100.0, // Add extra padding at bottom to account for nav bar
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.profile,
                          style: const TextStyle(
                            fontFamily: 'ErasITCDemi',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: TraineeProfileScreen._navyColor,
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/icons/navigation/Settings.png',
                            width: 28,
                            height: 28,
                          ),
                          onPressed: () => context.go('/trainee/settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Profile Picture
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: _buildProfileImage(trainee),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: TraineeProfileScreen._accentGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Personal Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.personalInfo,
                                style: const TextStyle(
                                  fontFamily: 'ErasITCDemi',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: TraineeProfileScreen._navyColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          InfoRow(
                            icon: Icons.person_outline,
                            label: l10n.name,
                            value: trainee?.fullName ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.email_outlined,
                            label: l10n.emailLabel,
                            value: trainee?.email ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.male,
                            label: l10n.gender,
                            value: trainee?.gender?.toString().split('.').last ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          InfoRow(
                            icon: Icons.star_outline,
                            label: l10n.fitnessGoals,
                            value: _formatGoals(trainee?.traineeData?.goals),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Navigation Bar
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavBar(
              role: UserRole.trainee,
              currentIndex: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(UserModel? trainee) {
    String? imageUrl = trainee?.imageUrl;
    String? fullUrl = (imageUrl != null && imageUrl.isNotEmpty)
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coachhub-production.up.railway.app/$imageUrl')
        : null;
    return CircleAvatar(
      radius: 48,
      backgroundImage: fullUrl != null
          ? NetworkImage(fullUrl)
          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
      child: (fullUrl == null)
          ? const Icon(Icons.person, size: 48, color: TraineeProfileScreen._navyColor)
          : null,
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: TraineeProfileScreen._navyColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 16,
                  color: TraineeProfileScreen._navyColor,
                ),
                softWrap: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DashboardMetric extends StatelessWidget {
  final Widget icon;
  final String value;
  final String unit;
  final String label;

  const DashboardMetric({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: TraineeProfileScreen._accentGreen,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Alexandria',
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Alexandria',
                color: TraineeProfileScreen._navyColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(text: value),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
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

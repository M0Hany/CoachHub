import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../../core/constants/api_constants.dart';
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final trainee = authProvider.currentUser;
    final l10n = AppLocalizations.of(context)!;

    // Debug prints to verify data
    developer.log('Trainee Data:', name: 'TraineeProfileScreen');
    developer.log('Name: ${trainee?.name}', name: 'TraineeProfileScreen');
    developer.log('Email: ${trainee?.email}', name: 'TraineeProfileScreen');
    developer.log('Gender: ${trainee?.gender}', name: 'TraineeProfileScreen');
    developer.log('Profile Image URL: ${trainee?.profileImage}',
        name: 'TraineeProfileScreen');
    developer.log('Raw User Data: ${trainee?.toJson()}',
        name: 'TraineeProfileScreen');
    developer.log('Weight: ${trainee?.traineeData?.weight}',
        name: 'TraineeProfileScreen');
    developer.log('Height: ${trainee?.traineeData?.height}',
        name: 'TraineeProfileScreen');
    developer.log('Fat Percentage: ${trainee?.traineeData?.fatPercentage}',
        name: 'TraineeData');
    developer.log('Muscle Percentage: ${trainee?.traineeData?.musclePercentage}',
        name: 'TraineeData');
    developer.log('Goals: ${trainee?.traineeData?.goals}',
        name: 'TraineeProfileScreen');

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${authProvider.error}'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontFamily: 'ErasITCDemi',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: TraineeProfileScreen._navyColor,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: TraineeProfileScreen._navyColor,
                      size: 24,
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
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: trainee?.profileImage != null &&
                                trainee!.profileImage!.isNotEmpty
                            ? FileImage(File(trainee.profileImage!))
                            : null,
                        child: trainee?.profileImage == null ||
                                trainee!.profileImage!.isEmpty
                            ? const Icon(Icons.person,
                                size: 50,
                                color: TraineeProfileScreen._navyColor)
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: TraineeProfileScreen._accentGreen,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              color: TraineeProfileScreen._navyColor),
                          onPressed: () {
                            // TODO: Implement profile picture edit
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Personal Info Card
              Expanded(
                child: Container(
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
                          const Text(
                            'Personal info',
                            style: TextStyle(
                              fontFamily: 'ErasITCDemi',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: TraineeProfileScreen._navyColor,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Implement edit functionality
                            },
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                color: TraineeProfileScreen._accentGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      InfoRow(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: trainee?.name?.isNotEmpty == true
                            ? trainee!.name!
                            : 'Not set',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: trainee?.email ?? 'Not set',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.male,
                        label: 'Gender',
                        value: trainee?.gender?.toString().split('.').last ??
                            'Not set',
                      ),
                      const SizedBox(height: 12),
                      InfoRow(
                        icon: Icons.star_outline,
                        label: 'Goals',
                        value:
                            trainee?.traineeData?.goals?.join(', ') ?? 'Not set',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Dashboard Card
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
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontFamily: 'ErasITCDemi',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: TraineeProfileScreen._navyColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DashboardMetric(
                            icon: Image.asset(
                              'assets/icons/Weight.png',
                              width: 24,
                              height: 24,
                              color: Colors.black,
                            ),
                            value: trainee?.traineeData?.weight != null
                                ? trainee!.traineeData!.weight!.toStringAsFixed(1)
                                : '0',
                            unit: 'kg',
                            label: 'Weight',
                          ),
                          const SizedBox(width: 16),
                          DashboardMetric(
                            icon: Image.asset(
                              'assets/icons/Height.png',
                              width: 24,
                              height: 24,
                              color: Colors.black,
                            ),
                            value: trainee?.traineeData?.height != null
                                ? trainee!.traineeData!.height!.toStringAsFixed(1)
                                : '0',
                            unit: 'cm',
                            label: 'Height',
                          ),
                          const SizedBox(width: 16),
                          DashboardMetric(
                            icon: Image.asset(
                              'assets/icons/Fats.png',
                              width: 24,
                              height: 24,
                              color: Colors.black,
                            ),
                            value: trainee?.traineeData?.fatPercentage != null
                                ? trainee!.traineeData!.fatPercentage!
                                    .toStringAsFixed(1)
                                : '0',
                            unit: l10n.percentSymbol,
                            label: 'Fat Percentage',
                          ),
                          const SizedBox(width: 16),
                          DashboardMetric(
                            icon: Image.asset(
                              'assets/icons/Muscle.png',
                              width: 24,
                              height: 24,
                              color: Colors.black,
                            ),
                            value: trainee?.traineeData?.musclePercentage != null
                                ? trainee!.traineeData!.musclePercentage!
                                    .toStringAsFixed(1)
                                : '0',
                            unit: l10n.percentSymbol,
                            label: l10n.bodyMuscle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        role: UserRole.trainee,
        currentIndex: 3,
      ),
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

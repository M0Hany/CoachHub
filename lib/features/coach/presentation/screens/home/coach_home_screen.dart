import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../core/constants/enums.dart';
import '../../../../../l10n/app_localizations.dart';

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Mock data for clients with proper typing
    final List<Map<String, dynamic>> clients = [
      {
        'name': 'Hani_Medhat_',
        'gender': 'Male',
        'age': 27,
        'imageUrl': 'assets/images/default_profile.png',
      },
      {
        'name': 'Mourad08',
        'gender': 'Male',
        'age': 32,
        'imageUrl': 'assets/images/default_profile.png',
      },
      {
        'name': 'Shorouk',
        'gender': 'Female',
        'age': 25,
        'imageUrl': null,
      },
      {
        'name': 'Dina_05',
        'gender': 'Female',
        'age': 28,
        'imageUrl': 'assets/images/default_profile.png',
      },
      {
        'name': 'Mostafa',
        'gender': 'Male',
        'age': 30,
        'imageUrl': 'assets/images/default_profile.png',
      },
      {
        'name': 'Yousef_Ahmed',
        'gender': 'Male',
        'age': 24,
        'imageUrl': null,
      },
    ];

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
                        child: const CircleAvatar(
                          radius: 32,
                          backgroundImage: AssetImage('assets/images/default_profile.png'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good Morning,',
                            style: AppTheme.bodyMedium,
                          ),
                          Text(
                            'Khalid Salah',
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
                  child: GridView.builder(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 16,
                      bottom: 100, // Add extra padding at bottom to account for nav bar
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 22,
                    ),
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index];
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
                              width: 74, // Slightly larger than 2 * radius (70) to accommodate the border
                              height: 74,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.accent, // Change to your desired border color
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xFF0FF789).withOpacity(0.2),
                                child: client['imageUrl'] != null
                                    ? ClipOval(
                                  child: Image.asset(
                                    client['imageUrl'] as String,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              client['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            // const SizedBox(height: 3),
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: const BottomNavBar(
              role: UserRole.coach,
              currentIndex: 2, // Home tab
            ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../../../core/constants/enums.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../../../../core/providers/language_provider.dart';
import '../../../../../../features/auth/presentation/providers/auth_provider.dart';

class CoachSettingsScreen extends StatelessWidget {
  const CoachSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.currentLocale.languageCode == 'ar';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(50),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 32,
                    bottom: 24,
                    left: 24,
                    right: 24,
                  ),
                  child: Center(
                    child: Text(
                      l10n.settings,
                      style: AppTheme.screenTitle,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSection(
                        context,
                        l10n.language,
                        [
                          _buildLanguageOption(
                            context,
                            'English',
                            !isArabic,
                            () => _changeLanguage(context, 'en'),
                          ),
                          _buildLanguageOption(
                            context,
                            'العربية',
                            isArabic,
                            () => _changeLanguage(context, 'ar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        l10n.accountSettings,
                        [
                          _buildSettingTile(
                            context,
                            l10n.notificationSettings,
                            Icons.notifications_outlined,
                            onTap: () {
                              // TODO: Navigate to notifications settings
                            },
                          ),
                          _buildSettingTile(
                            context,
                            l10n.availability,
                            Icons.calendar_today_outlined,
                            onTap: () {
                              // TODO: Navigate to availability settings
                            },
                          ),
                          _buildSettingTile(
                            context,
                            l10n.pricing,
                            Icons.attach_money,
                            onTap: () {
                              // TODO: Navigate to pricing settings
                            },
                          ),
                          _buildSettingTile(
                            context,
                            l10n.darkMode,
                            Icons.dark_mode_outlined,
                            isSwitch: true,
                            onChanged: (value) {
                              // TODO: Implement dark mode
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        context,
                        l10n.expertise,
                        [
                          _buildSettingTile(
                            context,
                            l10n.certifications,
                            Icons.workspace_premium_outlined,
                            onTap: () {
                              // TODO: Navigate to certifications
                            },
                          ),
                          _buildSettingTile(
                            context,
                            l10n.specializations,
                            Icons.fitness_center_outlined,
                            onTap: () {
                              // TODO: Navigate to specializations
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLogoutButton(context, l10n),
                      const SizedBox(height: 80), // Add padding for bottom nav bar
                    ],
                  ),
                ),
              ],
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomNavBar(
                role: UserRole.coach,
                currentIndex: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D122A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String language,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      onTap: onTap,
      title: Text(
        language,
        style: TextStyle(
          color: isSelected ? const Color(0xFF0FF789) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check_circle,
              color: Color(0xFF0FF789),
            )
          : null,
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    IconData icon, {
    bool isSwitch = false,
    VoidCallback? onTap,
    Function(bool)? onChanged,
  }) {
    return ListTile(
      onTap: isSwitch ? null : onTap,
      leading: Icon(
        icon,
        color: const Color(0xFF0D122A),
      ),
      title: Text(title),
      trailing: isSwitch
          ? Switch(
              value: false, // TODO: Get value from provider
              onChanged: onChanged,
              activeColor: const Color(0xFF0FF789),
            )
          : const Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () async {
          try {
            final authProvider = context.read<AuthProvider>();
            await authProvider.logout();
            if (context.mounted) {
              context.go('/login');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          l10n.logout,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    provider.changeLanguage(languageCode);
  }
} 
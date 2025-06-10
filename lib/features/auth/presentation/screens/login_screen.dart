import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/widgets/bottom_nav_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isArabic = languageProvider.currentLocale.languageCode == 'ar';
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                languageProvider.changeLanguage('en');
                Navigator.pop(context);
              },
              title: const Text('English'),
              trailing: !isArabic
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0FF789),
                    )
                  : null,
            ),
            ListTile(
              onTap: () {
                languageProvider.changeLanguage('ar');
                Navigator.pop(context);
              },
              title: const Text('العربية'),
              trailing: isArabic
                  ? const Icon(
                      Icons.check_circle,
                      color: Color(0xFF0FF789),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
        context,
      );

      if (success && mounted) {
        final userRole = authProvider.userRole;
        final isAuthenticated = authProvider.isAuthenticated;

        debugPrint('Login success, user role: $userRole, isAuthenticated: $isAuthenticated');
        debugPrint('Current user: ${authProvider.currentUser?.toJson()}');

        if (userRole == UserRole.coach) {
          debugPrint('Navigating to coach profile');
          if (mounted) {
            context.go('/coach/profile');
          }
        } else if (userRole == UserRole.trainee) {
          debugPrint('Navigating to trainee home');
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                context.go('/trainee/home');
              }
            });
          }
        } else {
          debugPrint('Unknown user role: $userRole');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.language,
              color: Color(0xFF0FF789),
            ),
            onPressed: _showLanguageDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 64),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.welcomeBack,
                                style: AppTheme.headerLarge.copyWith(
                                  height: 1,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.loginSubtitle,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          l10n.email,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          decoration: AppTheme.authInputDecoration.copyWith(
                            hintText: l10n.enterEmail,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xFF8E8E93),
                            ),
                          ),
                          style: const TextStyle(
                            color: AppTheme.authInputText,
                            fontSize: 16,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.validation_required;
                            }
                            if (!value.contains('@')) {
                              return l10n.validation_email;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.password,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          decoration: AppTheme.authInputDecoration.copyWith(
                            hintText: l10n.enterPassword,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF8E8E93),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Color(0xFF8E8E93),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          style: const TextStyle(
                            color: AppTheme.authInputText,
                            fontSize: 16,
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.validation_required;
                            }
                            if (value.length < 6) {
                              return l10n.validation_password_length;
                            }
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                              },
                              child: Text(
                                l10n.forgetPassword,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: AppTheme.whiteButtonStyle,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  l10n.signIn,
                                  style: AppTheme.mainText,
                                ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(
                            l10n.dontHaveAccount,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/onboarding'),
                          child: Text(
                            l10n.viewOnboarding,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.secondaryButtonColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

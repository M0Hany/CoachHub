import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'dart:developer' as developer;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validation_required;
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return AppLocalizations.of(context)!.validation_email;
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validation_required;
    }
    if (value.length < 3) {
      return AppLocalizations.of(context)!.validation_username_length;
    }
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return AppLocalizations.of(context)!.validation_username_format;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.validation_required;
    }
    
    // Check password strength
    bool hasMinLength = value.length >= 8;
    bool hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(value);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(value);
    
    if (!hasMinLength || !hasCapitalLetter || !hasNumber) {
      return AppLocalizations.of(context)!.passwordRequirementMessage;
    }
    
    return null;
  }

  void _showPasswordRequirements() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.passwordRequirementsTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.passwordRequirementMinLength),
            Text(l10n.passwordRequirementCapital),
            Text(l10n.passwordRequirementNumber),
          ],
        ),
        backgroundColor: AppTheme.error,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      developer.log('Starting registration process', name: 'RegisterScreen');

      try {
        final success = await context.read<AuthProvider>().register(
              email: _emailController.text,
              username: _usernameController.text,
              password: _passwordController.text,
            );

        developer.log('Registration result: $success, mounted: $mounted', name: 'RegisterScreen');

        if (success && mounted) {
          developer.log('Showing success snackbar', name: 'RegisterScreen');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registerSuccess),
              backgroundColor: AppTheme.success,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Add a slight delay to allow the snackbar to be visible
          await Future.delayed(const Duration(milliseconds: 500));
          
          if (mounted) {  // Double-check mounted state before navigation
            developer.log('Navigating to OTP screen', name: 'RegisterScreen');
            context.push('/verify-otp');
          } else {
            developer.log('Widget not mounted before navigation', name: 'RegisterScreen');
          }
        } else {
          if (mounted) {
            final error = context.read<AuthProvider>().error ?? 'Registration failed';
            developer.log('Showing error snackbar: $error', name: 'RegisterScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        }
      } catch (e) {
        developer.log('Registration error: $e', name: 'RegisterScreen', error: e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      // Check if password validation failed and show requirements
      final passwordValue = _passwordController.text;
      bool hasMinLength = passwordValue.length >= 8;
      bool hasCapitalLetter = RegExp(r'[A-Z]').hasMatch(passwordValue);
      bool hasNumber = RegExp(r'[0-9]').hasMatch(passwordValue);
      
      if (!hasMinLength || !hasCapitalLetter || !hasNumber) {
        _showPasswordRequirements();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppTheme.authBackgroundColor,
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
                        const SizedBox(height: 48),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/logo.png',
                              height: 32,
                              width: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'CoachHub',
                              style: AppTheme.logoText.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                l10n.createAccount,
                                style: AppTheme.headerLarge.copyWith(
                                    fontSize: 60,
                                    height: 1,
                                    fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.center,
                                softWrap: true,
                              ),
                            ),
                          ],
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
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          style: const TextStyle(
                            color: AppTheme.authInputText,
                            fontSize: 16,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.username,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _usernameController,
                          decoration: AppTheme.authInputDecoration.copyWith(
                            hintText: l10n.enterUsername,
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          style: const TextStyle(
                            color: AppTheme.authInputText,
                            fontSize: 16,
                          ),
                          validator: _validateUsername,
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
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppTheme.authHintText,
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
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 64),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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
                              l10n.signUp,
                              style: AppTheme.mainText,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _isLoading ? null : () => context.go('/login'),
                          child: Text(
                            l10n.alreadyHaveAccount,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textLight,
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

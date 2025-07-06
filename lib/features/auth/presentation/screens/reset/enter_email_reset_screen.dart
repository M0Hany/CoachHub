import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/constants/enums.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class EnterEmailResetScreen extends StatefulWidget {
  const EnterEmailResetScreen({super.key});

  @override
  State<EnterEmailResetScreen> createState() => _EnterEmailResetScreenState();
}

class _EnterEmailResetScreenState extends State<EnterEmailResetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://coachhub-production.up.railway.app/api/auth/request-password-reset'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': _emailController.text},
      );
      if (response.statusCode == 200 && response.body.contains('success')) {
        if (!mounted) return;
        context.go('/reset/otp_reset_screen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send code. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.primary,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 64),
                  Text(
                    l10n.forgotPasswordTitle,
                    style: AppTheme.headerLarge.copyWith(
                      height: 1,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.forgotPasswordSubtitle,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _ResetStepper(),
                  const SizedBox(height: 40),
                  Text(
                    l10n.resetEmailLabel,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: AppTheme.authInputDecoration.copyWith(
                      hintText: l10n.resetEmailHint,
                      prefixIcon: const Icon(
                        Icons.mail_outline,
                        color: Color(0xFF8E8E93),
                        size: 24,
                      ),
                    ),
                    style: const TextStyle(
                      color: AppTheme.authInputText,
                      fontSize: 16,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.validation_required;
                      }
                      // Simple email validation
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                        return l10n.validation_email;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendCode,
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
                            l10n.resetSendCode,
                            style: AppTheme.mainText,
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetStepper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StepCircle(isActive: true, icon: Icons.mail_outline),
            _StepperLine(),
            _StepCircle(icon: Icons.lock_open_outlined),
            _StepperLine(),
            _StepCircle(icon: Icons.lock_outline),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Text(
                l10n.resetStepEmail,
                style: AppTheme.bodySmall.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 44), // 32 (line) + 12 (2x6 margin)
            SizedBox(
              width: 50,
              child: Text(
                l10n.resetStepOtp,
                style: AppTheme.bodySmall.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 44),
            SizedBox(
              width: 50,
              child: Text(
                l10n.resetStepNewPassword,
                style: AppTheme.bodySmall.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  const _StepCircle({required this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.accent : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.accent : Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 20,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _StepperLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 6),
        Container(
          width: 32,
          height: 2,
          color: Colors.white,
        ),
        const SizedBox(width: 6),
      ],
    );
  }
} 
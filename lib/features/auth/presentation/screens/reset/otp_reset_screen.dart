import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../core/constants/enums.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class OtpResetScreen extends StatefulWidget {
  const OtpResetScreen({super.key});

  static String? resetToken; // Store token for next step

  @override
  State<OtpResetScreen> createState() => _OtpResetScreenState();
}

class _OtpResetScreenState extends State<OtpResetScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onOtpDigitChanged(int index, String value) {
    setState(() {}); // Trigger rebuild to update border color
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _onContinue() async {
    final l10n = AppLocalizations.of(context)!;
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.otpInvalid)),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://coachhub-production.up.railway.app/api/auth/verify'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'otp': otp},
      );
      if (response.statusCode == 200 && response.body.contains('success') && response.body.contains('token')) {
        final token = RegExp(r'"token"\s*:\s*"([^"]+)"').firstMatch(response.body)?.group(1);
        if (token != null) {
          OtpResetScreen.resetToken = token;
          if (!mounted) return;
          context.go('/reset/new_password_screen');
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.otpInvalid)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.otpInvalid)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  l10n.otpResetTitle,
                  style: AppTheme.headerMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.otpResetSubtitle,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _OtpResetStepper(),
                const SizedBox(height: 40),
                _OtpInputRow(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  isArabic: isArabic,
                  onChanged: _onOtpDigitChanged,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _onContinue,
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
                          l10n.otpResetContinue,
                          style: AppTheme.mainText,
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpResetStepper extends StatelessWidget {
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
            _StepCircle(isActive: true, icon: Icons.lock_open_outlined),
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
            const SizedBox(width: 44),
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

class _OtpInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isArabic;
  final void Function(int, String) onChanged;
  const _OtpInputRow({required this.controllers, required this.focusNodes, required this.isArabic, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Always LTR for OTP input
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          6,
          (index) => Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: controllers[index].text.isNotEmpty 
                    ? AppTheme.accent 
                    : const Color(0xFFD0D6F4),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextFormField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => onChanged(index, value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 
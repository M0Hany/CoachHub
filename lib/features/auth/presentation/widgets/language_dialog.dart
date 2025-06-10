import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/language_provider.dart';

void showLanguageDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  final languageProvider = Provider.of<LanguageProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.languageSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('English'),
            leading: Radio<String>(
              value: 'en',
              groupValue: languageProvider.currentLocale.languageCode,
              onChanged: (value) {
                languageProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ),
          ListTile(
            title: const Text('العربية'),
            leading: Radio<String>(
              value: 'ar',
              groupValue: languageProvider.currentLocale.languageCode,
              onChanged: (value) {
                languageProvider.setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    ),
  );
} 
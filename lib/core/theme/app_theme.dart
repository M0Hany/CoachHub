import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const mainBackgroundColor = Color(0xFFDDD6D6);
  static const primaryButtonColor = Color(0xFF0D122A);
  static const secondaryButtonColor = Color(0xFF0FF789);
  static const accent = Color(0xFF0FF789);
  static const primary = Color(0xFF0D122A);
  static const textLight = Colors.white;
  static const labelColor = Color(0XFF555558);
  static const textDark = Color(0xFF0D122A);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);

  // Auth Screen Colors
  static const authBackgroundColor = Color(0xFF0D122A);
  static const authInputBackground = Colors.white;
  static const authInputText = Colors.black87;
  static const authHintText = Color(0xFF9E9E9E);

  // Text Styles
  static const onBoardingTitle = TextStyle(
    fontFamily: 'ErasITCDemi',
    fontSize: 42,
    fontWeight: FontWeight.w600,
    color: textLight,
  );

  static const onBoardingDescription = TextStyle(
    fontFamily: 'Alexandria',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: textLight,
  );

  static const logoText = TextStyle(
    fontFamily: 'ErasITCDemi',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textLight,
  );

  static const headerLarge = TextStyle(
    fontFamily: 'ErasITCDemi',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: textLight,
  );

  static const headerMedium = TextStyle(
    fontFamily: 'ErasITCDemi',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const headerSmall = TextStyle(
    fontFamily: 'ErasITCDemi',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const screenTitle = TextStyle(
    fontFamily: 'ErasITCDemi',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: secondaryButtonColor,
  );

  static const bodyLarge = TextStyle(
    fontFamily: 'Alexandria',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textDark,
  );

  static const bodyMedium = TextStyle(
    fontFamily: 'Alexandria',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textDark,
  );

  static const bodySmall = TextStyle(
    fontSize: 9,
    color: textDark,
    fontFamily: 'Alexandria',
  );

  static const buttonTextLight = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textLight,
    fontFamily: 'Alexandria',
  );

  static const buttonTextDark = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textDark,
    fontFamily: 'Alexandria',
  );

  static const labelText = TextStyle(
    fontSize: 10,
    color: labelColor,
    fontFamily: 'Alexandria',
  );

  static const mainText = TextStyle(
    fontSize: 16,
    color: textDark,
    fontWeight: FontWeight.w600,
    fontFamily: 'Alexandria',
  );

  // Button Styles
  static final primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryButtonColor,
    foregroundColor: textLight,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: secondaryButtonColor,
    foregroundColor: textDark,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final whiteButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: textDark,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  // Input Decorations for direct use in widgets
  static const defaultInputDecoration = InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
      fontFamily: 'Alexandria',
      color: Colors.grey,
    ),
  );

  static const authInputDecoration = InputDecoration(
    filled: true,
    fillColor: authInputBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
      fontFamily: 'Alexandria',
      color: authHintText,
    ),
  );

  // Theme-level input decoration
  static const defaultInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: TextStyle(
      fontFamily: 'Alexandria',
      color: Colors.grey,
    ),
  );

  static const Color primaryColor = Color(0xFF0FF789);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF1A1B1E);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  static const Color infoColor = Color(0xFF1976D2);

  static ThemeData get themeData => ThemeData(
    primaryColor: primaryButtonColor,
    scaffoldBackgroundColor: mainBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryButtonColor,
      secondary: secondaryButtonColor,
      background: mainBackgroundColor,
      error: error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryButtonColor,
      foregroundColor: secondaryButtonColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: primaryButtonColor,
        size: 24,
      ),
      titleTextStyle: TextStyle(
        color: secondaryButtonColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: 'Alexandria',
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: labelColor,
        textStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          fontFamily: 'Alexandria',
        ),
      ),
    ),
    textTheme: const TextTheme(
    bodyLarge: TextStyle(fontFamily: 'Alexandria'),
    bodyMedium: TextStyle(fontFamily: 'Alexandria'),
    titleLarge: TextStyle(fontFamily: 'Alexandria'),
    labelLarge: TextStyle(fontFamily: 'Alexandria'),
  ),
    inputDecorationTheme: defaultInputDecorationTheme,
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      ),
    useMaterial3: true,
  );
}

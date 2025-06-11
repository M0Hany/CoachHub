import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/complete_profile_screen.dart';
import 'features/coach/presentation/screens/coach_expertise_screen.dart';
import 'features/trainee/presentation/screens/health/trainee_health_data_screen.dart';
import 'features/auth/presentation/screens/dashboard_screen.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/coach/presentation/providers/workout/workout_plan_provider.dart';
import 'features/coach/presentation/providers/nutrition/nutrition_plan_provider.dart';
import 'core/providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/network/http_client.dart';
import 'core/services/token_service.dart';
import 'features/auth/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final tokenService = TokenService();
  final httpClient = HttpClient(); // Uses singleton pattern now

  // Initialize providers
  final authService = AuthService(httpClient, tokenService);
  final authProvider = AuthProvider(authService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => authProvider,
        ),
        ChangeNotifierProvider<WorkoutPlanProvider>(
          create: (_) => WorkoutPlanProvider(),
        ),
        ChangeNotifierProvider<NutritionPlanProvider>(
          create: (_) => NutritionPlanProvider(),
        ),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp.router(
          title: 'CoachHub',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
          locale: languageProvider.currentLocale,
        );
      },
    );
  }
}

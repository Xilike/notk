import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_state.dart';
import 'widgets/auto_speak_page.dart';
import 'widgets/ui.dart';

class TasisApp extends StatelessWidget {
  const TasisApp({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.blue,
      primary: AppColors.blue,
      secondary: AppColors.pink,
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [educationalRouteObserver],
      title: 'تأسيس النطق',
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.skyBottom,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(height: 1.35, color: AppColors.navy),
          titleLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.navy,
          ),
          iconTheme: IconThemeData(color: AppColors.navy),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.navy,
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            side: const BorderSide(color: AppColors.cardBorder, width: 2.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
      home: state.onboarded ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

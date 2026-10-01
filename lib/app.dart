import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_state.dart';
import 'widgets/auto_speak_page.dart';

class TasisApp extends StatelessWidget {
  const TasisApp({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF21A9F6)),
        scaffoldBackgroundColor: const Color(0xFFF4FAFF),
        textTheme: const TextTheme(bodyMedium: TextStyle(height: 1.35)),
      ),
      home: state.onboarded ? const HomeScreen() : const OnboardingScreen(),
    );
  }
}

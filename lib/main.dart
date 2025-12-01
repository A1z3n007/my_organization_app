import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth/auth_screen.dart';
import 'screens/dashboard/dashboard_shell.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final appState = AppState(prefs);
  await appState.initialize();
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final colorScheme = ColorScheme.fromSeed(
          seedColor: const Color(0xFF00D1FF),
          brightness: Brightness.dark,
        );
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Neon CRM',
          themeMode: ThemeMode.dark,
          theme: ThemeData(
            colorScheme: colorScheme,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF030712),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF030712),
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
            ),
            cardColor: const Color(0xFF0B1224),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF050914),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white54,
              showUnselectedLabels: true,
            ),
          ),
          home: appState.currentUser == null
              ? AuthScreen(appState: appState)
              : DashboardShell(appState: appState),
        );
      },
    );
  }
}

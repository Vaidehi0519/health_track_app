import 'package:flutter/material.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/state/app_state.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = await AppState.load();
  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: appState,
      child: AnimatedBuilder(
        animation: appState,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Health Tracker',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: appState.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

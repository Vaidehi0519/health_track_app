import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:health_track_app/core/state/app_scope.dart';
import 'package:health_track_app/core/state/app_state.dart';
import 'package:health_track_app/core/theme/app_theme.dart';
import 'package:health_track_app/firebase_options.dart';
import 'package:health_track_app/ui/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GoogleSignIn.instance.initialize();
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
      child: Builder(
        builder: (context) {
          final state = AppScope.of(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Health Tracker',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

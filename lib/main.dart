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

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.appState});

  final AppState appState;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.appState.themeMode;
    widget.appState.addListener(_handleAppStateChanged);
  }

  @override
  void didUpdateWidget(covariant MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState == widget.appState) return;
    oldWidget.appState.removeListener(_handleAppStateChanged);
    _themeMode = widget.appState.themeMode;
    widget.appState.addListener(_handleAppStateChanged);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_handleAppStateChanged);
    super.dispose();
  }

  void _handleAppStateChanged() {
    final nextThemeMode = widget.appState.themeMode;
    if (nextThemeMode == _themeMode) return;
    setState(() => _themeMode = nextThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: widget.appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Health Tracker',
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _themeMode,
        home: const SplashScreen(),
      ),
    );
  }
}

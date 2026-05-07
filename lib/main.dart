import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1397E5),
          primary: const Color(0xFF1397E5),
          secondary: const Color(0xFF32C74E),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

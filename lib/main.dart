import 'package:flutter/material.dart';
import 'package:health_track_app/ui/screens/auth/login_screens.dart';
import 'package:health_track_app/ui/screens/auth/welcome_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
      //home: LoginScreens(),
    );
  }
}

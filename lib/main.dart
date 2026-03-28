import 'package:flutter/material.dart';
//import 'package:placementsync/home_screen.dart';
import 'package:placementsync/signup.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignUpScreen()
    );
  }
}

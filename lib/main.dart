import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/dashboard_screen.dart';

void main() async {
  // Ensures Flutter engine is fully booted before we run
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LevelZeroApp());
}

class LevelZeroApp extends StatelessWidget {
  const LevelZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelZero.Qst',
      debugShowCheckedModeBanner: false, // Hides the annoying red debug banner
      theme: AppTheme.darkTheme,         // Applies your dark Solo Leveling theme
      home: const DashboardScreen(),     // Boots directly into your new Hub
    );
  }
}
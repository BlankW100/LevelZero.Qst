import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'ui/awakening_screen.dart'; // <-- We changed the import here

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LevelZeroApp());
}

class LevelZeroApp extends StatelessWidget {
  const LevelZeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LevelZero.Qst',
      debugShowCheckedModeBanner: false, 
      theme: AppTheme.darkTheme,         
      home: const AwakeningScreen(),     // <-- And changed the boot screen here!
    );
  }
}
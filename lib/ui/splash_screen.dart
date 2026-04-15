import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // 1. Initialize the hard drive storage
    final storage = StorageService();
    await storage.init();

    // 2. Force the app to wait for 2 seconds so the user can read the screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    // 3. Delete the loading screen from memory and push the Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SYSTEM INITIALIZING...",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary, // Neon Blue
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0, // Spaces out the letters for a sci-fi feel
                  ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.secondary, // Glowing Green
            ),
          ],
        ),
      ),
    );
  }
}
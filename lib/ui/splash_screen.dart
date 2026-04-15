import 'package:flutter/material.dart';
import '../services/local_storage.dart';
import 'dashboard_screen.dart'; // Import the DashboardScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Initialize storage service
    await _storage.init();

    // Artificial delay for splash screen visibility
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    // Navigate to DashboardScreen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    }
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
                    color: Theme.of(context).colorScheme.primary, // Neon blue text
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0, // For a glowing effect
                  ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), // Glowing green indicator
            ),
          ],
        ),
      ),
    );
  }
}
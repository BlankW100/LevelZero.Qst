import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';
import 'dashboard_screen.dart'; // Required to navigate here after setup

class AwakeningScreen extends StatefulWidget {
  const AwakeningScreen({super.key});

  @override
  State<AwakeningScreen> createState() => _AwakeningScreenState();
}

class _AwakeningScreenState extends State<AwakeningScreen> {
  final TextEditingController _textController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  // Default to Assassin so the UI has a starting point
  HunterClass _selectedClass = HunterClass.assassin; 

  // Create a clean list of classes, removing 'beginner' from the choices
  final List<HunterClass> _availableClasses = HunterClass.values
      .where((c) => c != HunterClass.beginner)
      .toList();

  @override
  void initState() {
    super.initState();
    _storageService.init(); // Must initialize storage before we can save!
  }

  @override
  void dispose() {
    _textController.dispose(); // Always clean up controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Prevents the keyboard from pushing the UI off screen
      resizeToAvoidBottomInset: false, 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // --- TOP SECTION ---
              Text(
                "SYSTEM AWAKENING",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Enter your Hunter Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 40),

              // --- MIDDLE SECTION ---
              Text(
                "Select Your Path:",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 items per row is perfect for mobile
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5, // Makes the cards look like wide buttons
                  ),
                  itemCount: _availableClasses.length,
                  itemBuilder: (context, index) {
                    final classValue = _availableClasses[index];
                    final isSelected = _selectedClass == classValue;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedClass = classValue;
                        });
                      },
                      child: Card(
                        // If selected, glow green. If not, use standard grey border.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected 
                                ? Theme.of(context).colorScheme.secondary 
                                : Theme.of(context).colorScheme.surface,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        // Darker background if selected
                        color: isSelected 
                          ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.5) 
                          : Theme.of(context).colorScheme.surface,
                        child: Center(
                          child: Text(
                            // Capitalize the first letter of the enum name
                            classValue.name[0].toUpperCase() + classValue.name.substring(1),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.secondary 
                                      : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- BOTTOM SECTION ---
              const SizedBox(height: 20),
              SizedBox(
                height: 60, // Massive button
                child: ElevatedButton(
                  onPressed: () async {
                    final typedName = _textController.text.trim();
                    
                    // Don't let them proceed without a name!
                    if (typedName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('You must enter a Hunter Name.')),
                      );
                      return;
                    }

                    // 1. Create the new profile
                    final hunterProfile = HunterProfile(
                      name: typedName,
                      playerClass: _selectedClass,
                    );
                    
                    // 2. Save it to the vault
                    await _storageService.saveProfile(hunterProfile);
                    
                    if (!context.mounted) return;
                    
                    // 3. Teleport to the Dashboard
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardScreen()),
                    );
                  },
                  child: Text(
                    'AWAKEN',
                    style: TextStyle(
                      fontSize: 20,
                      letterSpacing: 3.0,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
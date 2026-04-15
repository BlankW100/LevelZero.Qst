import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;
  
  // Tracks which tab in the footer is currently selected
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _storage.init();
    HunterProfile? loadedProfile = _storage.loadProfile();

    if (loadedProfile == null) {
      loadedProfile = HunterProfile();
      await _storage.saveProfile(loadedProfile);
    }

    setState(() {
      _profile = loadedProfile;
    });
  }

  // Function to show the Notification Popup
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "System Notifications",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: const Text("No new notifications at this time."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CLOSE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            debugPrint("Navigate to Profile");
          },
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle, size: 30),
              SizedBox(width: 8),
              Text('Hunter Profile'),
            ],
          ),
        ),
        centerTitle: false,
        // ADDED: The Notification Bell
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            color: Theme.of(context).colorScheme.secondary, // Green bell
            onPressed: _showNotifications,
          ),
          const SizedBox(width: 10), // Padding on the right
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    "LEVEL ${_profile!.level}",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 48),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "XP: ${_profile!.currentXp}/${_profile!.xpToNextLevel}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: _profile!.xpToNextLevel > 0 ? _profile!.currentXp / _profile!.xpToNextLevel : 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard(context, 'STR', _profile!.strength),
                const SizedBox(width: 10),
                _buildStatCard(context, 'AGI', _profile!.agility),
                const SizedBox(width: 10),
                _buildStatCard(context, 'INT', _profile!.intelligence),
                const SizedBox(width: 10),
                _buildStatCard(context, 'END', _profile!.endurance),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Daily Quests",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Placeholder Quest ${index + 1}: 0/100",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Checkbox(
                          value: false,
                          onChanged: (bool? value) {},
                          fillColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return Theme.of(context).colorScheme.secondary;
                              }
                              return Theme.of(context).colorScheme.surface;
                            },
                          ),
                          checkColor: Theme.of(context).colorScheme.onSecondary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // ADDED: The Bottom Navigation Bar (Footer)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Required for more than 3 items
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10, // Small text to fit 6 items
        unselectedFontSize: 10,
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index; // Updates the active icon
          });
          // Future: Add routing to switch screens here
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Quest'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.backpack), label: 'Inv'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String statName, int statValue) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                statName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              Text('$statValue', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
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

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _storage.init();
    HunterProfile? loadedProfile = _storage.loadProfile();

    if (loadedProfile == null) {
      // Create a default profile if none exists
      loadedProfile = HunterProfile();
      await _storage.saveProfile(loadedProfile);
    }

    setState(() {
      _profile = loadedProfile;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            print("Navigate to Profile"); // Placeholder for navigation
            // Future navigation to profile screen
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
        centerTitle: false, // Align title to the start
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level Card
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
          // XP Progress Bar
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
          // Stats Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildStatCard(context, 'STR', _profile!.strength),
                const SizedBox(width: 16),
                _buildStatCard(context, 'AGI', _profile!.agility),
                const SizedBox(width: 16),
                _buildStatCard(context, 'INT', _profile!.intelligence),
                const SizedBox(width: 16),
                _buildStatCard(context, 'END', _profile!.endurance),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Daily Quests Section Header
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
          // Quests List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 3, // Placeholder for 3 quests
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
                          value: false, // Placeholder value
                          onChanged: (bool? value) {
                            // Handle checkbox state change (future implementation)
                            print("Quest ${index + 1} checked: $value");
                          },
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
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
    );
  }

  Widget _buildStatCard(BuildContext context, String statName, int statValue) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
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
              Text(
                '$statValue',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
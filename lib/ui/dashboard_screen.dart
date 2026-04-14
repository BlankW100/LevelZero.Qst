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
        title: const Text('Hunter Hub'),
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
          // Stats Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.5,
              ),
              itemCount: 4, // For STR, AGI, INT, END
              itemBuilder: (context, index) {
                String statName;
                int statValue;
                switch (index) {
                  case 0:
                    statName = 'STR';
                    statValue = _profile!.strength;
                    break;
                  case 1:
                    statName = 'AGI';
                    statValue = _profile!.agility;
                    break;
                  case 2:
                    statName = 'INT';
                    statValue = _profile!.intelligence;
                    break;
                  case 3:
                    statName = 'END';
                    statValue = _profile!.endurance;
                    break;
                  default:
                    statName = '';
                    statValue = 0;
                }
                return Card(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          statName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$statValue',
                          style: Theme.of(context).textTheme.headlineMedium,
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
}
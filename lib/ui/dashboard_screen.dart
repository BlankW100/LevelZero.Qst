import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/quest.dart';
import '../services/local_storage.dart';
import '../data/quest_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;
  List<Quest> _quests = []; 

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

  Future<void> _loadData() async {
    await _storage.init();
    HunterProfile? loadedProfile = _storage.loadProfile();

    if (loadedProfile == null) {
      loadedProfile = HunterProfile();
      await _storage.saveProfile(loadedProfile);
    }

    List<Quest> loadedQuests = _storage.loadQuests();

    // The new Quest Engine!
    if (loadedQuests.isEmpty) {
      loadedQuests = QuestList.generateDailyQuests(loadedProfile);
      await _storage.saveQuests(loadedQuests);
    }

    setState(() {
      _profile = loadedProfile;
      _quests = loadedQuests;
    });
  }

  // --- RESTORED: THE REWARD ENGINE ---
  void _completeQuest(int index) {
    if (_quests[index].isCompleted) return; 

    setState(() {
      _quests[index].isCompleted = true;
      _profile!.currentXp += _quests[index].xpReward;

      // Level Up Logic
      while (_profile!.currentXp >= _profile!.xpToNextLevel) {
        _profile!.currentXp -= _profile!.xpToNextLevel; 
        _profile!.level++;
        _profile!.xpToNextLevel = (_profile!.xpToNextLevel * 1.5).toInt(); 
        
        _profile!.strength += 1;
        _profile!.agility += 1;
        _profile!.intelligence += 1;
        _profile!.endurance += 1;
      }
    });

    _storage.saveProfile(_profile!);
    _storage.saveQuests(_quests);
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text("System Notifications", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        content: const Text("No new notifications at this time."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("CLOSE")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_circle, size: 30),
            const SizedBox(width: 8),
            Text(_profile!.name), 
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            color: Theme.of(context).colorScheme.secondary,
            onPressed: _showNotifications,
          ),
          const SizedBox(width: 10),
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
                    "XP: ${_profile!.currentXp} / ${_profile!.xpToNextLevel}",
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
            child: _quests.isEmpty 
              ? const Center(child: Text("No quests assigned."))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _quests.length,
                  itemBuilder: (context, index) {
                    final quest = _quests[index];
                    return Card(
                      color: quest.isCompleted 
                          ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.3) 
                          : Theme.of(context).cardColor,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quest.title,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                                      color: quest.isCompleted ? Colors.grey : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Reward: ${quest.xpReward} XP [${quest.statFocus.name.toUpperCase()}]",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Checkbox(
                              value: quest.isCompleted,
                              onChanged: quest.isCompleted 
                                  ? null 
                                  : (bool? value) {
                                      if (value == true) {
                                        _completeQuest(index);
                                      }
                                    },
                              fillColor: WidgetStateProperty.resolveWith<Color>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.selected) || states.contains(WidgetState.disabled)) {
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
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/quest.dart';
import '../services/local_storage.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;
  List<Quest> _quests = [];
  
  // 1 = Monday, 7 = Sunday
  Map<int, String> _weeklyPlan = {
    1: 'STR', 2: 'AGI', 3: 'INT', 4: 'END', 5: 'STR', 6: 'REST', 7: 'REST'
  };

  final List<String> _planOptions = ['STR', 'AGI', 'INT', 'END', 'REST'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storage.init();
    final prefs = await SharedPreferences.getInstance();
    
    // Load the saved calendar plan
    String? savedPlan = prefs.getString('weekly_plan');
    if (savedPlan != null) {
      Map<String, dynamic> decoded = jsonDecode(savedPlan);
      _weeklyPlan = decoded.map((key, value) => MapEntry(int.parse(key), value.toString()));
    }

    setState(() {
      _profile = _storage.loadProfile();
      _quests = _storage.loadQuests();
    });
  }

  Future<void> _savePlan() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> stringMap = _weeklyPlan.map((key, value) => MapEntry(key.toString(), value));
    await prefs.setString('weekly_plan', jsonEncode(stringMap));
  }

  // Cycles the plan when you tap a day on the calendar
  void _cyclePlanDay(int weekday) {
    setState(() {
      int currentIndex = _planOptions.indexOf(_weeklyPlan[weekday] ?? 'REST');
      int nextIndex = (currentIndex + 1) % _planOptions.length;
      _weeklyPlan[weekday] = _planOptions[nextIndex];
    });
    _savePlan();
  }

  // --- THE TARGETED REGENERATOR ---
  void _refreshUncompletedQuests() {
    setState(() {
      // 1. Keep quests that are already checked off
      List<Quest> keptQuests = _quests.where((q) => q.isCompleted).toList();
      
      // 2. Figure out how many new ones we need to reach 4 total daily quests
      int needed = 4 - keptQuests.length;
      if (needed > 0) {
        int today = DateTime.now().weekday;
        String todayPlan = _weeklyPlan[today] ?? 'REST';
        List<Quest> newQuests = _generateTargetedQuests(needed, todayPlan);
        keptQuests.addAll(newQuests);
      }
      
      _quests = keptQuests;
    });
    
    // Save the new quests to the hard drive so the Dashboard sees them too!
    _storage.saveQuests(_quests);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uncompleted Quests Regenerated!")));
  }

  List<Quest> _generateTargetedQuests(int amount, String plan) {
    List<Quest> newQuests = [];
    List<Map<String, dynamic>> pool = [];

    // Different pools based on the calendar plan
    if (plan == 'STR') {
      pool = [
        {'title': '100 Push-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 100},
        {'title': '50 Pull-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'amt': 50},
        {'title': '100 Squats', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 100},
        {'title': 'Core Workout', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 15},
      ];
    } else if (plan == 'AGI') {
      pool = [
        {'title': '10km Run', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'amt': 10},
        {'title': 'Shadow Boxing', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankE, 'amt': 15},
        {'title': 'Jump Rope 1000x', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankD, 'amt': 1000},
        {'title': 'Sprint Intervals', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'amt': 10},
      ];
    } else if (plan == 'INT') {
      pool = [
        {'title': 'Study Logic / Code', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankC, 'amt': 60},
        {'title': 'Read 20 Pages', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankE, 'amt': 20},
        {'title': 'Learn New Framework', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankB, 'amt': 60},
      ];
    } else if (plan == 'END') {
      pool = [
        {'title': 'Plank for 5 Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankD, 'amt': 5},
        {'title': 'Long Jog (No Stops)', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankB, 'amt': 30},
        {'title': 'Cold Shower', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankE, 'amt': 1},
      ];
    } else { // REST
      pool = [
        {'title': 'Drink 2L Water', 'stat': StatFocus.general, 'diff': QuestDifficulty.rankE, 'amt': 2},
        {'title': 'Meditate 10 Mins', 'stat': StatFocus.general, 'diff': QuestDifficulty.rankE, 'amt': 10},
        {'title': 'Stretch Body', 'stat': StatFocus.general, 'diff': QuestDifficulty.rankE, 'amt': 15},
        {'title': 'Sleep 8 Hours', 'stat': StatFocus.general, 'diff': QuestDifficulty.rankD, 'amt': 8},
      ];
    }

    pool.shuffle();
    for (int i = 0; i < amount; i++) {
      var qData = pool[i % pool.length]; // Modulo in case we need more quests than the pool has
      newQuests.add(Quest(
        id: 'tgt_${DateTime.now().millisecondsSinceEpoch}_$i',
        title: qData['title'] as String,
        statFocus: qData['stat'] as StatFocus,
        difficulty: qData['diff'] as QuestDifficulty,
        amount: qData['amt'] as int,
        type: QuestType.daily,
        xpReward: Quest.calculateDynamicXP(
          difficulty: qData['diff'] as QuestDifficulty,
          amount: qData['amt'] as int,
          statFocus: qData['stat'] as StatFocus,
          playerClass: _profile!.playerClass,
        ),
      ));
    }
    return newQuests;
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    int today = DateTime.now().weekday;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("QUEST BOARD", style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. HEADER PROFILE (Reused from Vault) ---
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2)),
                    child: const Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_profile!.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text("Lv. ${_profile!.level} | ${_profile!.rank}", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- 2. WEEKLY CALENDAR PLANNER ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("TRAINING SCHEDULE", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            Container(
              height: 70,
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  int dayNum = index + 1;
                  List<String> dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                  bool isToday = dayNum == today;
                  String plan = _weeklyPlan[dayNum] ?? 'REST';

                  return GestureDetector(
                    onTap: () => _cyclePlanDay(dayNum),
                    child: Container(
                      width: 55,
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        color: isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Theme.of(context).colorScheme.surface,
                        border: Border.all(color: isToday ? Theme.of(context).colorScheme.primary : Colors.white12, width: isToday ? 2 : 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dayNames[index], style: TextStyle(color: isToday ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(plan, style: TextStyle(
                            color: plan == 'REST' ? Colors.greenAccent : (isToday ? Theme.of(context).colorScheme.primary : Colors.white),
                            fontSize: 14, fontWeight: FontWeight.bold,
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // --- 3. QUEST LIST & REFRESH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("ACTIVE MISSIONS", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.amber),
                    onPressed: _refreshUncompletedQuests,
                    tooltip: "Regenerate based on today's plan",
                  ),
                ],
              ),
            ),
            
            // Displays quests natively
            ..._quests.map((quest) {
              return Card(
                color: quest.isCompleted ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.3) : Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ListTile(
                  title: Text(quest.title, style: TextStyle(
                    decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                    color: quest.isCompleted ? Colors.grey : Colors.white,
                  )),
                  subtitle: Text("[${quest.statFocus.name.toUpperCase()}]", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                  trailing: quest.isCompleted 
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                ),
              );
            }),
            const SizedBox(height: 30),

            // --- 4. DUNGEON GATE MOCKUP ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("SYSTEM GATES (DUNGEONS)", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),
            const SizedBox(height: 8),
            Container(
              height: 140,
              margin: const EdgeInsets.only(bottom: 30),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildGateCard("Goblin Hideout", "E-Rank", "STR", Colors.brown),
                  _buildGateCard("Slime Swamp", "D-Rank", "AGI", Colors.green),
                  _buildGateCard("Unknown Distortion", "??-Rank", "HIDDEN", Colors.purpleAccent, isHidden: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGateCard(String name, String rank, String stat, Color color, {bool isHidden = false}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 2),
        image: DecorationImage(
          // Just adding a subtle dark gradient to make it look like a portal
          image: const NetworkImage(''), 
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.8), BlendMode.darken),
          fit: BoxFit.cover,
        )
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4)),
            child: Text(rank, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          Text(isHidden ? "???" : name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Row(
            children: [
              Icon(isHidden ? Icons.visibility_off : Icons.token, color: Colors.grey, size: 12),
              const SizedBox(width: 4),
              Text("Focus: $stat", style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
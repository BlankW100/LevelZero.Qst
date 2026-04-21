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
  
  // NEW: Saves plans using exact dates (e.g., "2026-04-21": "STR")
  Map<String, String> _monthlyPlan = {};
  final List<String> _planOptions = ['STR', 'AGI', 'INT', 'END', 'REST'];

  // Calendar State
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storage.init();
    final prefs = await SharedPreferences.getInstance();
    
    // Load the specific daily plans
    String? savedPlan = prefs.getString('monthly_plan');
    if (savedPlan != null) {
      Map<String, dynamic> decoded = jsonDecode(savedPlan);
      _monthlyPlan = decoded.map((key, value) => MapEntry(key, value.toString()));
    }

    setState(() {
      _profile = _storage.loadProfile();
      _quests = _storage.loadQuests();
    });
  }

  Future<void> _savePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('monthly_plan', jsonEncode(_monthlyPlan));
  }

  // Helper to format date keys safely
  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // --- NEW: THE DROPDOWN POPUP ---
  void _showPlanSelectionDialog(DateTime date) {
    String dateKey = _getDateKey(date);
    String currentPlan = _monthlyPlan[dateKey] ?? 'REST';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Plan for ${date.day}/${date.month}/${date.year}", 
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          content: DropdownButtonHideUnderline(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: currentPlan,
                dropdownColor: Theme.of(context).colorScheme.surface,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.amber),
                items: _planOptions.map((String plan) {
                  return DropdownMenuItem<String>(
                    value: plan,
                    child: Text(plan, style: TextStyle(color: _getPlanColor(plan), fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _monthlyPlan[dateKey] = newValue;
                    });
                    _savePlan();
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
        );
      }
    );
  }

  Color _getPlanColor(String plan) {
    switch (plan) {
      case 'STR': return Colors.redAccent;
      case 'AGI': return Colors.blueAccent;
      case 'INT': return Colors.purpleAccent;
      case 'END': return Colors.orangeAccent;
      case 'REST': return Colors.greenAccent;
      default: return Colors.grey;
    }
  }

  void _refreshUncompletedQuests() {
    setState(() {
      List<Quest> keptQuests = _quests.where((q) => q.isCompleted).toList();
      int needed = 4 - keptQuests.length;
      if (needed > 0) {
        String todayKey = _getDateKey(DateTime.now());
        String todayPlan = _monthlyPlan[todayKey] ?? 'REST';
        List<Quest> newQuests = _generateTargetedQuests(needed, todayPlan);
        keptQuests.addAll(newQuests);
      }
      _quests = keptQuests;
    });
    
    _storage.saveQuests(_quests);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uncompleted Quests Regenerated!")));
  }

  List<Quest> _generateTargetedQuests(int amount, String plan) {
    List<Quest> newQuests = [];
    List<Map<String, dynamic>> pool = [];

    if (plan == 'STR') {
      pool = [
        {'title': '100 Push-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 100},
        {'title': '50 Pull-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'amt': 50},
        {'title': '100 Squats', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 100},
      ];
    } else if (plan == 'AGI') {
      pool = [
        {'title': '10km Run', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'amt': 10},
        {'title': 'Shadow Boxing', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankE, 'amt': 15},
        {'title': 'Sprint Intervals', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'amt': 10},
      ];
    } else if (plan == 'INT') {
      pool = [
        {'title': 'Study Logic / Code', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankC, 'amt': 60},
        {'title': 'Read 20 Pages', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankE, 'amt': 20},
      ];
    } else if (plan == 'END') {
      pool = [
        {'title': 'Plank for 5 Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankD, 'amt': 5},
        {'title': 'Long Jog (No Stops)', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankB, 'amt': 30},
      ];
    } else { 
      pool = [
        {'title': 'Drink 2L Water', 'stat': StatFocus.general, 'diff': QuestDifficulty.rankE, 'amt': 2},
        {'title': 'Sleep 8 Hours', 'stat': StatFocus.general, 'diff': QuestDifficulty.rankD, 'amt': 8},
      ];
    }

    pool.shuffle();
    for (int i = 0; i < amount; i++) {
      var qData = pool[i % pool.length];
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

  // --- THE CALENDAR RENDERER ---
  Widget _buildMonthlyCalendar() {
    int daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    // 0 = Sunday, 1 = Monday ... 6 = Saturday (Adjusted for UI)
    int firstWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7; 
    
    List<String> weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<String> monthNames = ["", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          // Header: < January 2026 >
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: Colors.white),
                onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1)),
              ),
              Text("${monthNames[_currentMonth.month]} ${_currentMonth.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Days of Week Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) => Text(day, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold))).toList(),
          ),
          const SizedBox(height: 10),
          // The Actual Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.8, // Taller boxes to fit the plan text
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: daysInMonth + firstWeekday,
            itemBuilder: (context, index) {
              if (index < firstWeekday) return const SizedBox(); // Empty slots before the 1st
              
              int dayNum = index - firstWeekday + 1;
              DateTime date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
              String dateKey = _getDateKey(date);
              String plan = _monthlyPlan[dateKey] ?? 'REST';
              
              bool isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;

              return GestureDetector(
                onTap: () => _showPlanSelectionDialog(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isToday ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: isToday ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("$dayNum", style: TextStyle(color: isToday ? Colors.white : Colors.white70, fontWeight: isToday ? FontWeight.bold : FontWeight.normal)),
                      const SizedBox(height: 2),
                      Text(plan, style: TextStyle(color: _getPlanColor(plan), fontSize: 8, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
            // --- 1. HEADER PROFILE ---
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

            // --- 2. ACTIVE MISSIONS (Moved to Top!) ---
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
            
            ..._quests.map((quest) {
              return Card(
                color: quest.isCompleted ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.3) : Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: ListTile(
                  title: Text(quest.title, style: TextStyle(decoration: quest.isCompleted ? TextDecoration.lineThrough : null, color: quest.isCompleted ? Colors.grey : Colors.white)),
                  subtitle: Text("[${quest.statFocus.name.toUpperCase()}]", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                  trailing: quest.isCompleted ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                ),
              );
            }),
            const SizedBox(height: 24),

            // --- 3. MONTHLY CALENDAR ---
            _buildMonthlyCalendar(),
            const SizedBox(height: 30),

            // --- 4. DUNGEON GATE MOCKUP ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("INITIAL DUNGEON", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
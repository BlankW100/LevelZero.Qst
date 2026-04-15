import '../models/quest.dart';
import '../models/user_profile.dart';

class QuestList {
  // --- THE QUEST REPOSITORIES ---
  // You can add, remove, or modify anything in these lists at any time!

  static final List<Map<String, dynamic>> strengthQuests = [
    {'title': '100 Push-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 100},
    {'title': '100 Squats', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 100},
    {'title': 'Carry Heavy Groceries', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankE, 'amt': 1},
    {'title': 'Deadhang for 2 Mins', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'amt': 2},
  ];

  static final List<Map<String, dynamic>> agilityQuests = [
    {'title': '10km Run', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'amt': 10},
    {'title': 'Shadow Boxing', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankE, 'amt': 15},
    {'title': 'Camera Gimbal Maneuvers', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankE, 'amt': 20},
    {'title': 'Corn Snake Handling/Taming', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankE, 'amt': 10},
  ];

  static final List<Map<String, dynamic>> enduranceQuests = [
    {'title': 'Plank for 5 Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankD, 'amt': 5},
    {'title': 'Walk the Cyberjaya Campus', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'amt': 60},
    {'title': 'Full Storyboard Sketching', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'amt': 120},
    {'title': 'Deep Cleaning the Hub', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankE, 'amt': 30},
  ];

  static final List<Map<String, dynamic>> intelligenceQuests = [
    {'title': 'Develop Formula_L1ve Logic', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankB, 'amt': 60},
    {'title': 'Debug C++ Assignments', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankC, 'amt': 45},
    {'title': 'Configure Local Ollama Model', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankB, 'amt': 30},
    {'title': 'Refactor Flutter Code', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankC, 'amt': 40},
    {'title': 'Analyze ASNB/Moomoo Dividends', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankD, 'amt': 20},
  ];

  // --- THE DAILY GENERATOR ---
  // This engine pulls 1 random quest from each category to build a balanced day
  static List<Quest> generateDailyQuests(HunterProfile profile) {
    List<Quest> dailyQuests = [];
    
    // 1. Shuffle all categories to randomize the draw
    strengthQuests.shuffle();
    agilityQuests.shuffle();
    enduranceQuests.shuffle();
    intelligenceQuests.shuffle();

    // 2. Pick the top one from each shuffled list
    final List<Map<String, dynamic>> selectedTasks = [
      strengthQuests.first,
      agilityQuests.first,
      enduranceQuests.first,
      intelligenceQuests.first, 
    ];

    // 3. Convert them into real Quest objects and calculate XP
    for (int i = 0; i < selectedTasks.length; i++) {
      var qData = selectedTasks[i];
      dailyQuests.add(Quest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_$i', // Creates a unique ID based on the exact millisecond
        title: qData['title'] as String,
        statFocus: qData['stat'] as StatFocus,
        difficulty: qData['diff'] as QuestDifficulty,
        amount: qData['amt'] as int,
        xpReward: Quest.calculateDynamicXP(
          difficulty: qData['diff'] as QuestDifficulty,
          amount: qData['amt'] as int,
          statFocus: qData['stat'] as StatFocus,
          playerClass: profile.playerClass,
        ),
      ));
    }

    return dailyQuests;
  }
}
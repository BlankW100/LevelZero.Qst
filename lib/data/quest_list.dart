import 'dart:math';
import '../models/quest.dart';
import '../models/user_profile.dart';

class QuestList {
  // --- THE MASTER QUEST REPOSITORY ---
  // Using %AMT% as a placeholder so we can inject the random number directly into the title!

  static final List<Map<String, dynamic>> strengthQuests = [
    {'titleFormat': '%AMT% Standard Push-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'min': 10, 'max': 80},
    {'titleFormat': '%AMT% Bodyweight Squats', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'min': 20, 'max': 150},
    {'titleFormat': '%AMT% Pull-ups / Chin-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankB, 'min': 5, 'max': 20},
    {'titleFormat': '%AMT% Overhead Press / Pike Push-ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'min': 10, 'max': 30},
    {'titleFormat': '%AMT% Dumbbell Lateral Raises', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'min': 10, 'max': 50},
    {'titleFormat': '%AMT% Bicep Curls', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'min': 10, 'max': 50},
    {'titleFormat': '%AMT% Tricep Dips', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'min': 15, 'max': 50},
    {'titleFormat': '%AMT% Sit-Ups', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'min': 20, 'max': 200},
    {'titleFormat': '%AMT% Calf Raises', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankE, 'min': 20, 'max': 100},
    {'titleFormat': '%AMT% Reverse Sit-ups / Leg Raises', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankC, 'min': 5, 'max': 20},
    {'titleFormat': '%AMT% Russian Twists', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'min': 20, 'max': 120},
    {'titleFormat': '%AMT% Glute Bridges', 'stat': StatFocus.strength, 'diff': QuestDifficulty.rankD, 'min': 10, 'max': 40},
  ];

  static final List<Map<String, dynamic>> agilityQuests = [
    {'titleFormat': 'Jog / Run %AMT% km', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'min': 1, 'max': 8},
    {'titleFormat': '%AMT%x 50m Sprints', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankB, 'min': 3, 'max': 5},
    {'titleFormat': 'Jump Rope for %AMT% Mins', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankD, 'min': 3, 'max': 8},
    {'titleFormat': 'Side Jumps for %AMT% Mins', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankD, 'min': 3, 'max': 8},
    {'titleFormat': 'Star Jumps for %AMT% Mins', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankD, 'min': 1, 'max': 5},
    {'titleFormat': '%AMT% Burpees', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankB, 'min': 3, 'max': 25},
    {'titleFormat': '%AMT% Mountain Climbers', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'min': 30, 'max': 150},
    {'titleFormat': 'High Knees for %AMT% Mins', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankC, 'min': 2, 'max': 10},
    {'titleFormat': 'Dynamic Stretching for %AMT% Mins', 'stat': StatFocus.agility, 'diff': QuestDifficulty.rankE, 'min': 3, 'max': 5},
  ];

  static final List<Map<String, dynamic>> enduranceQuests = [
    {'titleFormat': 'Standard Plank for %AMT% Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 1, 'max': 8},
    {'titleFormat': 'Side Plank for %AMT% Mins (per side)', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 1, 'max': 5},
    {'titleFormat': 'Wall Sit for %AMT% Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 2, 'max': 7},
    {'titleFormat': '%AMT% Superman Holds', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankD, 'min': 5, 'max': 15},
    {'titleFormat': 'Farmer\'s Walk for %AMT% Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 3, 'max': 10},
    {'titleFormat': 'Cycling for %AMT% Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 5, 'max': 15},
    {'titleFormat': '%AMT% Rowing Reps', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 10, 'max': 50},
    {'titleFormat': 'Stair Climbing for %AMT% Mins', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankC, 'min': 3, 'max': 10},
    {'titleFormat': 'Rucking for %AMT% km', 'stat': StatFocus.endurance, 'diff': QuestDifficulty.rankB, 'min': 3, 'max': 5},
  ];

  static final List<Map<String, dynamic>> intelligenceQuests = [
    {'titleFormat': 'Reading for %AMT% Mins', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankE, 'min': 5, 'max': 30},
    {'titleFormat': 'Focused Work/Study for %AMT% Mins', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankC, 'min': 30, 'max': 60},
    {'titleFormat': 'Learn a New Skill for %AMT% Mins', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankD, 'min': 5, 'max': 15},
    {'titleFormat': 'Chess / Puzzles for %AMT% Mins', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankD, 'min': 15, 'max': 30},
    {'titleFormat': 'Mindfulness Meditation for %AMT% Mins', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankE, 'min': 5, 'max': 15},
    {'titleFormat': 'Box Breathing for %AMT% Mins', 'stat': StatFocus.intelligence, 'diff': QuestDifficulty.rankE, 'min': 3, 'max': 15},
  ];

  // --- THE RANDOMIZER ENGINE ---
  static List<Quest> generateDailyQuests(HunterProfile profile) {
    List<Quest> dailyQuests = [];
    final random = Random();
    
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

    // 3. Roll the dice and build the quests
    for (int i = 0; i < selectedTasks.length; i++) {
      var qData = selectedTasks[i];
      
      // Generate the random number between min and max
      int minAmt = qData['min'] as int;
      int maxAmt = qData['max'] as int;
      int randomAmount = minAmt + random.nextInt((maxAmt - minAmt) + 1);

      // Swap the %AMT% placeholder with the actual number
      String rawTitle = qData['titleFormat'] as String;
      String finalTitle = rawTitle.replaceAll('%AMT%', randomAmount.toString());

      dailyQuests.add(Quest(
        id: 'daily_${DateTime.now().millisecondsSinceEpoch}_$i', 
        title: finalTitle,
        statFocus: qData['stat'] as StatFocus,
        difficulty: qData['diff'] as QuestDifficulty,
        amount: randomAmount, // The math engine will use this random number to calculate XP!
        xpReward: Quest.calculateDynamicXP(
          difficulty: qData['diff'] as QuestDifficulty,
          amount: randomAmount,
          statFocus: qData['stat'] as StatFocus,
          playerClass: profile.playerClass,
        ),
      ));
    }

    return dailyQuests;
  }
}
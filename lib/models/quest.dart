import 'user_profile.dart';

enum StatFocus { strength, agility, intelligence, endurance, general }
enum QuestDifficulty { rankE, rankD, rankC, rankB, rankA, rankS }
// RESTORED: The QuestType enum so the app knows what kind of quest this is!
enum QuestType { daily, weekly, main, penalty } 

class Quest {
  final String id;
  final String title;
  final String description;
  final StatFocus statFocus;
  final QuestDifficulty difficulty;
  final QuestType type; // RESTORED
  final int amount;
  final int xpReward;
  bool isCompleted;

  Quest({
    required this.id,
    required this.title,
    this.description = '',
    required this.statFocus,
    required this.difficulty,
    this.type = QuestType.daily, // Defaults to daily
    required this.amount,
    required this.xpReward,
    this.isCompleted = false,
  });

  // --- THE DYNAMIC XP ENGINE ---
  static int calculateDynamicXP({
    required QuestDifficulty difficulty,
    required int amount,
    required StatFocus statFocus,
    required HunterClass playerClass,
  }) {
    int base = 0;
    switch (difficulty) {
      case QuestDifficulty.rankE: base = 10; break;
      case QuestDifficulty.rankD: base = 25; break;
      case QuestDifficulty.rankC: base = 50; break;
      case QuestDifficulty.rankB: base = 100; break;
      case QuestDifficulty.rankA: base = 250; break;
      case QuestDifficulty.rankS: base = 1000; break;
    }

    double multiplier = 1.0;
    if (playerClass == HunterClass.warrior && statFocus == StatFocus.strength) multiplier = 1.5;
    if (playerClass == HunterClass.assassin && statFocus == StatFocus.agility) multiplier = 1.5;
    if (playerClass == HunterClass.mage && statFocus == StatFocus.intelligence) multiplier = 1.5;
    if (playerClass == HunterClass.tank && statFocus == StatFocus.endurance) multiplier = 1.5;

    return ((base + amount) * multiplier).toInt();
  }

  // --- HARD DRIVE SAVE/LOAD LOGIC ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'statFocus': statFocus.name,
      'difficulty': difficulty.name,
      'type': type.name, // Saves the type
      'amount': amount,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      statFocus: StatFocus.values.firstWhere((e) => e.name == json['statFocus'], orElse: () => StatFocus.general),
      difficulty: QuestDifficulty.values.firstWhere((e) => e.name == json['difficulty'], orElse: () => QuestDifficulty.rankE),
      type: QuestType.values.firstWhere((e) => e.name == json['type'], orElse: () => QuestType.daily), // Loads the type
      amount: json['amount'] ?? 0,
      xpReward: json['xpReward'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
// --- NEW ENUMS FOR RPG MECHANICS ---
enum QuestType { daily, main, penalty }

// ADDED: The expanded roster of basic classes
enum HunterClass { beginner, assassin, tank, mage, knight, fighter, ranger, scholar }

enum StatFocus { strength, agility, intelligence, endurance, general }
enum QuestDifficulty { rankE, rankD, rankC, rankB, rankA, rankS }

class Quest {
  final String id;
  final String title;
  final String description;
  final int xpReward; 
  bool isCompleted;
  
  final QuestType type;
  final StatFocus statFocus;
  final QuestDifficulty difficulty;
  final int amount; 

  Quest({
    required this.id,
    required this.title,
    this.description = '',
    required this.xpReward, 
    this.isCompleted = false,
    this.type = QuestType.daily,
    this.statFocus = StatFocus.general,
    this.difficulty = QuestDifficulty.rankE,
    this.amount = 1,
  });

  // --- THE XP GENERATOR ENGINE ---
  static int calculateDynamicXP({
    required QuestDifficulty difficulty,
    required int amount,
    required StatFocus statFocus,
    required HunterClass playerClass,
  }) {
    // 1. Difficulty Multiplier
    double diffMultiplier = 1.0;
    switch (difficulty) {
      case QuestDifficulty.rankE: diffMultiplier = 1.0; break;
      case QuestDifficulty.rankD: diffMultiplier = 2.0; break;
      case QuestDifficulty.rankC: diffMultiplier = 3.0; break;
      case QuestDifficulty.rankB: diffMultiplier = 4.5; break;
      case QuestDifficulty.rankA: diffMultiplier = 6.0; break;
      case QuestDifficulty.rankS: diffMultiplier = 10.0; break;
    }

    // 2. Base XP
    double systemScaler = 0.5; 
    double baseXP = (amount * diffMultiplier) * systemScaler;

    // 3. Class Affinity Bonus (The updated logic!)
    double classBonus = 1.0;
    
    // Skip calculations if it's a general chore (like "wash dishes")
    if (statFocus != StatFocus.general) {
      switch (playerClass) {
        case HunterClass.assassin: // Pure AGI
          if (statFocus == StatFocus.agility) classBonus = 1.5;
          break;
        case HunterClass.tank: // Pure STR / END
          if (statFocus == StatFocus.strength || statFocus == StatFocus.endurance) classBonus = 1.5;
          break;
        case HunterClass.mage: // Pure INT
          if (statFocus == StatFocus.intelligence) classBonus = 1.5;
          break;
        case HunterClass.knight: // The All-Rounder
          classBonus = 1.3; // Gets 1.3x on ALL stats
          break;
        case HunterClass.fighter: // STR + AGI Hybrid
          if (statFocus == StatFocus.strength || statFocus == StatFocus.agility) classBonus = 1.4;
          break;
        case HunterClass.ranger: // AGI + END Hybrid
          if (statFocus == StatFocus.agility || statFocus == StatFocus.endurance) classBonus = 1.4;
          break;
        case HunterClass.scholar: // INT + END Hybrid
          if (statFocus == StatFocus.intelligence || statFocus == StatFocus.endurance) classBonus = 1.4;
          break;
        case HunterClass.beginner:
          classBonus = 1.0;
          break;
      }
    }

    return (baseXP * classBonus).round();
  }

  // --- TRANSLATORS (JSON) ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'isCompleted': isCompleted,
      'type': type.name,
      'statFocus': statFocus.name,
      'difficulty': difficulty.name,
      'amount': amount,
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      xpReward: json['xpReward'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      type: QuestType.values.firstWhere((e) => e.name == json['type'], orElse: () => QuestType.daily),
      statFocus: StatFocus.values.firstWhere((e) => e.name == json['statFocus'], orElse: () => StatFocus.general),
      difficulty: QuestDifficulty.values.firstWhere((e) => e.name == json['difficulty'], orElse: () => QuestDifficulty.rankE),
      amount: json['amount'] as int? ?? 1,
    );
  }
}
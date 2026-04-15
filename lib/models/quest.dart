
// --- NEW ENUMS FOR RPG MECHANICS ---
enum QuestType { daily, main, penalty }
enum HunterClass { beginner, assassin, tank, mage }
enum StatFocus { strength, agility, intelligence, endurance, general }

// Difficulty multiplier: E=1, D=2, C=3, B=4, A=5, S=10
enum QuestDifficulty { rankE, rankD, rankC, rankB, rankA, rankS }

class Quest {
  final String id;
  final String title;
  final String description;
  final int xpReward; // The final calculated XP
  bool isCompleted;
  
  final QuestType type;
  final StatFocus statFocus;
  final QuestDifficulty difficulty;
  final int amount; // Reps, Minutes, or Seconds

  Quest({
    required this.id,
    required this.title,
    this.description = '',
    required this.xpReward, // We will calculate this before passing it in
    this.isCompleted = false,
    this.type = QuestType.daily,
    this.statFocus = StatFocus.general,
    this.difficulty = QuestDifficulty.rankE,
    this.amount = 1,
  });

  // --- THE XP GENERATOR ENGINE ---
  // This calculates exactly how much XP a quest should give based on the user's class
  static int calculateDynamicXP({
    required QuestDifficulty difficulty,
    required int amount,
    required StatFocus statFocus,
    required HunterClass playerClass,
  }) {
    // 1. Convert difficulty rank to a math multiplier
    double diffMultiplier = 1.0;
    switch (difficulty) {
      case QuestDifficulty.rankE: diffMultiplier = 1.0; break;
      case QuestDifficulty.rankD: diffMultiplier = 2.0; break;
      case QuestDifficulty.rankC: diffMultiplier = 3.0; break;
      case QuestDifficulty.rankB: diffMultiplier = 4.5; break;
      case QuestDifficulty.rankA: diffMultiplier = 6.0; break;
      case QuestDifficulty.rankS: diffMultiplier = 10.0; break;
    }

    // 2. Base XP Calculation (System scaler reduces massive numbers)
    // E.g., 100 pushups at Rank C = 100 * 3.0 * 0.5 = 150 Base XP
    double systemScaler = 0.5; 
    double baseXP = (amount * diffMultiplier) * systemScaler;

    // 3. Class Affinity Bonus (50% extra XP for doing your job!)
    double classBonus = 1.0;
    if (playerClass == HunterClass.assassin && statFocus == StatFocus.agility) classBonus = 1.5;
    if (playerClass == HunterClass.tank && (statFocus == StatFocus.strength || statFocus == StatFocus.endurance)) classBonus = 1.5;
    if (playerClass == HunterClass.mage && statFocus == StatFocus.intelligence) classBonus = 1.5;

    // Return the final rounded number
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
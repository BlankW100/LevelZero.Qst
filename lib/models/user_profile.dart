import 'quest.dart'; 
class HunterProfile {
  String name;
  int level;
  int currentXp;
  int xpToNextLevel;
  
  // Core Stats
  int strength;
  int agility;
  int intelligence;
  int endurance;

 
  HunterClass playerClass;

  HunterProfile({
    this.name = 'Player',
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.strength = 5,
    this.agility = 5,
    this.intelligence = 5,
    this.endurance = 5,
    this.playerClass = HunterClass.beginner, // Defaults to beginner
  });

  // Translators for saving to the hard drive
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'strength': strength,
      'agility': agility,
      'intelligence': intelligence,
      'endurance': endurance,
      'playerClass': playerClass.name, // Save the class as text
    };
  }

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    return HunterProfile(
      name: json['name'] as String? ?? 'Player',
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      strength: json['strength'] as int? ?? 5,
      agility: json['agility'] as int? ?? 5,
      intelligence: json['intelligence'] as int? ?? 5,
      endurance: json['endurance'] as int? ?? 5,
      // Safely read the class string back into an Enum
      playerClass: HunterClass.values.firstWhere(
        (e) => e.name == json['playerClass'],
        orElse: () => HunterClass.beginner,
      ),
    );
  }
}
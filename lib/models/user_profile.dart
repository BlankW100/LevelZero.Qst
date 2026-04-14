class HunterProfile {
  int level;
  int currentXp;
  int xpToNextLevel;
  int strength;
  int agility;
  int intelligence;
  int endurance;

  HunterProfile({
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.strength = 5,
    this.agility = 5,
    this.intelligence = 5,
    this.endurance = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'currentXp': currentXp,
      'xpToNextLevel': xpToNextLevel,
      'strength': strength,
      'agility': agility,
      'intelligence': intelligence,
      'endurance': endurance,
    };
  }

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    return HunterProfile(
      level: json['level'],
      currentXp: json['currentXp'],
      xpToNextLevel: json['xpToNextLevel'],
      strength: json['strength'],
      agility: json['agility'],
      intelligence: json['intelligence'],
      endurance: json['endurance'],
    );
  }
}
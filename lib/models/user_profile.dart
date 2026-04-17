import 'item.dart';

// 1. ALL of your original classes are restored here!
enum HunterClass { beginner, none, warrior, assassin, mage, tank, knight, fighter, ranger, scholar }

class HunterProfile {
  String name;
  HunterClass playerClass; 
  String rank;
  int level;
  int currentXp;
  int xpToNextLevel;
  int coins;

  int strength;
  int agility;
  int intelligence;
  int endurance;

  int maxHp;
  int currentHp;
  int maxMp;
  int currentMp;

  int inventoryCapacity;
  List<Item> inventory;
  Map<String, Item> equippedGear;

  HunterProfile({
    this.name = 'Hunter', 
    this.playerClass = HunterClass.beginner, // 2. Default is now beginner!
    this.rank = 'E-Rank', this.level = 1, this.currentXp = 0,
    this.xpToNextLevel = 100, this.coins = 0,
    this.strength = 5, this.agility = 5, this.intelligence = 5, this.endurance = 5,
    this.maxHp = 100, this.currentHp = 100, this.maxMp = 100, this.currentMp = 100,
    this.inventoryCapacity = 25,
    List<Item>? inventory, Map<String, Item>? equippedGear,
  }) : inventory = inventory ?? [], equippedGear = equippedGear ?? {};

  // --- THE HP/MANA SYNERGY ENGINE ---
  void updateHpMp() {
    int rawHp = 100 + (endurance * 10) + (level * 10);
    int rawMp = 100 + (intelligence * 10) + (level * 10);

    // Updated to use HunterClass inside the switch statement
    switch (playerClass) {
      case HunterClass.warrior: maxHp = (rawHp * 1.5).toInt(); maxMp = (rawMp * 0.8).toInt(); break;
      case HunterClass.mage: maxHp = (rawHp * 0.8).toInt(); maxMp = (rawMp * 1.5).toInt(); break;
      case HunterClass.tank: maxHp = (rawHp * 2.0).toInt(); maxMp = (rawMp * 0.5).toInt(); break;
      case HunterClass.assassin: maxHp = (rawHp * 1.1).toInt(); maxMp = (rawMp * 1.1).toInt(); break;
      default: maxHp = rawHp; maxMp = rawMp; break;
    }
    if (currentHp > maxHp) currentHp = maxHp;
    if (currentMp > maxMp) currentMp = maxMp;
  }

  Map<String, dynamic> toJson() => {
    'name': name, 'playerClass': playerClass.name, 'rank': rank, 'level': level,
    'currentXp': currentXp, 'xpToNextLevel': xpToNextLevel, 'coins': coins,
    'strength': strength, 'agility': agility, 'intelligence': intelligence, 'endurance': endurance,
    'maxHp': maxHp, 'currentHp': currentHp, 'maxMp': maxMp, 'currentMp': currentMp,
    'inventoryCapacity': inventoryCapacity,
    'inventory': inventory.map((i) => i.toJson()).toList(),
    'equippedGear': equippedGear.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    var profile = HunterProfile(
      name: json['name'] ?? 'Hunter',
      // Updated to safely load HunterClass from hard drive
      playerClass: HunterClass.values.firstWhere((e) => e.name == json['playerClass'], orElse: () => HunterClass.none),
      rank: json['rank'] ?? 'E-Rank', level: json['level'] ?? 1,
      currentXp: json['currentXp'] ?? 0, xpToNextLevel: json['xpToNextLevel'] ?? 100,
      coins: json['coins'] ?? 0,
      strength: json['strength'] ?? 5, agility: json['agility'] ?? 5,
      intelligence: json['intelligence'] ?? 5, endurance: json['endurance'] ?? 5,
      maxHp: json['maxHp'] ?? 100, currentHp: json['currentHp'] ?? 100,
      maxMp: json['maxMp'] ?? 100, currentMp: json['currentMp'] ?? 100,
      inventoryCapacity: json['inventoryCapacity'] ?? 25,
      inventory: (json['inventory'] as List?)?.map((i) => Item.fromJson(i)).toList() ?? [],
      equippedGear: (json['equippedGear'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, Item.fromJson(v))) ?? {},
    );
    profile.updateHpMp(); 
    return profile;
  }
}
import 'quest.dart'; 
import 'item.dart'; // NEW: Import the item blueprint

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

  // NEW: RPG Systems
  HunterClass playerClass;
  String rank; // Your "gred" (e.g., E-Rank, S-Rank)
  int coins;
  int inventoryCapacity; // Starts at 25 (5x5)
  List<Item> inventory;

  HunterProfile({
    this.name = 'Player',
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.strength = 5,
    this.agility = 5,
    this.intelligence = 5,
    this.endurance = 5,
    this.playerClass = HunterClass.beginner,
    this.rank = 'E-Rank',
    this.coins = 0,
    this.inventoryCapacity = 25, 
    List<Item>? inventory,
  }) : inventory = inventory ?? []; // If no inventory provided, start empty

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
      'playerClass': playerClass.name,
      'rank': rank,
      'coins': coins,
      'inventoryCapacity': inventoryCapacity,
      // Convert every item in the backpack into text
      'inventory': inventory.map((i) => i.toJson()).toList(),
    };
  }

  factory HunterProfile.fromJson(Map<String, dynamic> json) {
    // Safely parse the saved inventory items
    var invList = json['inventory'] as List? ?? [];
    List<Item> loadedInventory = invList.map((i) => Item.fromJson(i as Map<String, dynamic>)).toList();

    return HunterProfile(
      name: json['name'] as String? ?? 'Player',
      level: json['level'] as int? ?? 1,
      currentXp: json['currentXp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      strength: json['strength'] as int? ?? 5,
      agility: json['agility'] as int? ?? 5,
      intelligence: json['intelligence'] as int? ?? 5,
      endurance: json['endurance'] as int? ?? 5,
      playerClass: HunterClass.values.firstWhere(
        (e) => e.name == json['playerClass'],
        orElse: () => HunterClass.beginner,
      ),
      // Safely default new values if loading an old save file
      rank: json['rank'] as String? ?? 'E-Rank',
      coins: json['coins'] as int? ?? 0,
      inventoryCapacity: json['inventoryCapacity'] as int? ?? 25,
      inventory: loadedInventory,
    );
  }
}
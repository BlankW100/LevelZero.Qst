import 'dart:math';
import '../models/item.dart';

enum ProductType { item, upgrade }

class ShopProduct {
  final String id;
  final String name;
  final String description;
  final int price;
  final ProductType type;
  final ItemCategory category;
  final ItemRarity rarity;
  bool isSoldOut; 

  final String? buffStat;
  final int inGameBoost;
  final int dailyReduction;

  ShopProduct({
    required this.id, required this.name, required this.description, 
    required this.price, required this.type, required this.category, 
    required this.rarity, this.isSoldOut = false,
    this.buffStat, this.inGameBoost = 0, this.dailyReduction = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description, 
    'price': price, 'type': type.name, 'category': category.name, 
    'rarity': rarity.name, 'isSoldOut': isSoldOut,
    'buffStat': buffStat, 'inGameBoost': inGameBoost, 'dailyReduction': dailyReduction,
  };

  factory ShopProduct.fromJson(Map<String, dynamic> json) {
    return ShopProduct(
      id: json['id'], name: json['name'], description: json['description'],
      price: json['price'], isSoldOut: json['isSoldOut'],
      type: ProductType.values.firstWhere((e) => e.name == json['type']),
      category: ItemCategory.values.firstWhere((e) => e.name == json['category']),
      rarity: ItemRarity.values.firstWhere((e) => e.name == json['rarity']),
      buffStat: json['buffStat'], inGameBoost: json['inGameBoost'] ?? 0, dailyReduction: json['dailyReduction'] ?? 0,
    );
  }

  Item toItem() {
    return Item(
      id: id, name: name, description: description, 
      category: category, rarity: rarity,
      buffStat: buffStat, inGameBoost: inGameBoost, dailyReduction: dailyReduction
    );
  }
}

class ShopData {
  static final Random _rng = Random();

  static final List<Map<String, dynamic>> commonGear = [
    {'name': 'Rusty Iron Ring', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 1, 'max': 3},
    {'name': 'Torn Cloak', 'desc': '[AGI +%AMT%] Daily: -%AMT% Min to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 1, 'max': 3},
    {'name': 'Wooden Buckler', 'desc': '[END +%AMT%] Daily: -%AMT% Min to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 1, 'max': 3},
    {'name': 'Cracked Spectacles', 'desc': '[INT +%AMT%] Daily: -%AMT% Min to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 1, 'max': 3},
    {'name': 'Faded Bandana', 'desc': '[AGI +%AMT%] Daily: -%AMT% Min to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 1, 'max': 3},
    {'name': 'Chipped Dagger', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 1, 'max': 3},
    {'name': 'Worn Leather Gloves', 'desc': '[END +%AMT%] Daily: -%AMT% Min to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 1, 'max': 3},
    {'name': 'Beast Bone', 'desc': 'Low-tier crafting material.', 'cat': ItemCategory.material},
    {'name': 'Slime Residue', 'desc': 'Sticky alchemy material.', 'cat': ItemCategory.material},
  ];

  static final List<Map<String, dynamic>> uncommonGear = [
    {'name': 'Trainee\'s Blade', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 3, 'max': 5},
    {'name': 'Leather Boots', 'desc': '[AGI +%AMT%] Daily: -%AMT% Mins to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 3, 'max': 5},
    {'name': 'Iron Chestplate', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 3, 'max': 5},
    {'name': 'Scholar\'s Monocle', 'desc': '[INT +%AMT%] Daily: -%AMT% Mins to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 3, 'max': 5},
    {'name': 'Weighted Wristbands', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 3, 'max': 5},
    {'name': 'Hunter\'s Bow', 'desc': '[AGI +%AMT%] Daily: -%AMT% Mins to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 3, 'max': 5},
    {'name': 'Apprentice Wand', 'desc': '[INT +%AMT%] Daily: -%AMT% Mins to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 3, 'max': 5},
    {'name': 'Goblin Ore', 'desc': 'Uncommon smelting material.', 'cat': ItemCategory.material},
  ];

  static final List<Map<String, dynamic>> rareGear = [
    {'name': 'Steel Longsword', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 5, 'max': 7},
    {'name': 'Elven Cloak', 'desc': '[AGI +%AMT%] Daily: -%AMT% Mins to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 5, 'max': 7},
    {'name': 'Knight\'s Pauldrons', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 5, 'max': 7},
    {'name': 'Amulet of Focus', 'desc': '[INT +%AMT%] Daily: -%AMT% Mins to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 5, 'max': 7},
    {'name': 'Ranger\'s Longbow', 'desc': '[AGI +%AMT%] Daily: -%AMT% Mins to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 5, 'max': 7},
    {'name': 'Mithril Shirt', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 5, 'max': 7},
    {'name': 'Berserker Axe', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 5, 'max': 7},
    {'name': 'Wyvern Scale', 'desc': 'Rare material pulsing with heat.', 'cat': ItemCategory.material},
  ];

  static final List<Map<String, dynamic>> epicGear = [
    {'name': 'Shadow Dagger', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 10, 'max': 15},
    {'name': 'Assassin\'s Cowl', 'desc': '[AGI +%AMT%] Daily: -%AMT% Mins to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 10, 'max': 15},
    {'name': 'Obsidian Armor', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 10, 'max': 15},
    {'name': 'Tome of Insight', 'desc': '[INT +%AMT%] Daily: -%AMT% Mins to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 10, 'max': 15},
    {'name': 'Dragonbone Sword', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 10, 'max': 15},
    {'name': 'Archmage Circlet', 'desc': '[INT +%AMT%] Daily: -%AMT% Mins to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 10, 'max': 15},
    {'name': 'Titan Gauntlets', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 10, 'max': 15},
    {'name': 'Demon Heart', 'desc': 'A frighteningly powerful epic material.', 'cat': ItemCategory.material},
  ];

  static final List<Map<String, dynamic>> legendaryGear = [
    {'name': 'The Monarch\'s Blade', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 20, 'max': 20},
    {'name': 'Wings of Hermes', 'desc': '[AGI +%AMT%] Daily: -%AMT% Mins to AGI tasks.', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 20, 'max': 20},
    {'name': 'Aegis Shield', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 20, 'max': 20},
    {'name': 'Eye of the Sage', 'desc': '[INT +%AMT%] Daily: -%AMT% Mins to INT tasks.', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 20, 'max': 20},
    {'name': 'Excalibur', 'desc': '[STR +%AMT%] Daily: -%AMT% Reps to STR tasks.', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 20, 'max': 20},
    {'name': 'Sunfire Armor', 'desc': '[END +%AMT%] Daily: -%AMT% Mins to END tasks.', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 20, 'max': 20},
  ];

  static List<ShopProduct> generateDailyShop() {
    List<ShopProduct> dailyItems = [];
    
    ShopProduct rollItem(List<Map<String, dynamic>> pool, ItemRarity rarity, int minPrice, int maxPrice) {
      final itemData = pool[_rng.nextInt(pool.length)];
      final price = minPrice + _rng.nextInt((maxPrice - minPrice) + 1);
      final id = 'shop_${rarity.name}_${DateTime.now().millisecondsSinceEpoch}_${_rng.nextInt(1000)}';
      
      int rolledBuff = 0;
      if (itemData.containsKey('min') && itemData.containsKey('max')) {
        int minB = itemData['min'];
        int maxB = itemData['max'];
        rolledBuff = minB + _rng.nextInt((maxB - minB) + 1);
      }

      String finalDesc = itemData['desc'];
      if (rolledBuff > 0) {
        finalDesc = finalDesc.replaceAll('%AMT%', rolledBuff.toString());
      }

      return ShopProduct(
        id: id,
        name: itemData['name'],
        description: finalDesc,
        price: price,
        type: ProductType.item,
        category: itemData['cat'],
        rarity: rarity,
        buffStat: itemData['stat'], 
        inGameBoost: rolledBuff,       
        dailyReduction: rolledBuff,    
      );
    }

    // Wrapped loops in curly braces to satisfy linter
    for (int i = 0; i < 3; i++) {
      dailyItems.add(rollItem(commonGear, ItemRarity.common, 3, 15));
    }

    for (int i = 0; i < 2; i++) {
      if (_rng.nextDouble() < 0.60) {
        dailyItems.add(rollItem(uncommonGear, ItemRarity.uncommon, 20, 35));
      } else {
        dailyItems.add(rollItem(rareGear, ItemRarity.rare, 36, 60));
      }
    }

    dailyItems.add(rollItem(epicGear, ItemRarity.epic, 61, 88));

    if (_rng.nextDouble() < 0.60) {
      dailyItems.add(rollItem(epicGear, ItemRarity.epic, 61, 88));
    } else {
      dailyItems.add(rollItem(legendaryGear, ItemRarity.legendary, 100, 250));
    }

    return dailyItems;
  }
}
import 'dart:math';
import '../models/item.dart';

enum ProductType { item, upgrade }

class ShopProduct {
  final String id, name, description;
  final int price, inGameBoost, dailyReduction;
  final ProductType type;
  final ItemCategory category;
  final ItemRarity rarity;
  final String? buffStat, equipSlot;
  bool isSoldOut; 

  ShopProduct({
    required this.id, required this.name, required this.description, required this.price, 
    required this.type, required this.category, required this.rarity, this.isSoldOut = false,
    this.buffStat, this.inGameBoost = 0, this.dailyReduction = 0, this.equipSlot,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description, 'price': price, 'type': type.name, 
    'category': category.name, 'rarity': rarity.name, 'isSoldOut': isSoldOut,
    'buffStat': buffStat, 'inGameBoost': inGameBoost, 'dailyReduction': dailyReduction, 'equipSlot': equipSlot,
  };

  factory ShopProduct.fromJson(Map<String, dynamic> json) => ShopProduct(
    id: json['id'], name: json['name'], description: json['description'], price: json['price'], isSoldOut: json['isSoldOut'],
    type: ProductType.values.firstWhere((e) => e.name == json['type']),
    category: ItemCategory.values.firstWhere((e) => e.name == json['category']),
    rarity: ItemRarity.values.firstWhere((e) => e.name == json['rarity']),
    buffStat: json['buffStat'], inGameBoost: json['inGameBoost'] ?? 0, dailyReduction: json['dailyReduction'] ?? 0, equipSlot: json['equipSlot'],
  );

  Item toItem() => Item(id: id, name: name, description: description, category: category, rarity: rarity, buffStat: buffStat, inGameBoost: inGameBoost, dailyReduction: dailyReduction, equipSlot: equipSlot);
}

class ShopData {
  static final Random _rng = Random();

  // Added 'slot' to assign gear to body parts!
  static final List<Map<String, dynamic>> gearPool = [
    {'name': 'Rusty Ring', 'desc': '[STR +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 1, 'max': 3, 'slot': 'RING', 'rarity': ItemRarity.common},
    {'name': 'Torn Cloak', 'desc': '[AGI +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 1, 'max': 3, 'slot': 'CHEST', 'rarity': ItemRarity.common},
    {'name': 'Wooden Shield', 'desc': '[END +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 1, 'max': 3, 'slot': 'WEAPON', 'rarity': ItemRarity.common},
    {'name': 'Iron Sword', 'desc': '[STR +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 5, 'max': 7, 'slot': 'WEAPON', 'rarity': ItemRarity.rare},
    {'name': 'Leather Boots', 'desc': '[AGI +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'AGI', 'min': 3, 'max': 5, 'slot': 'BOOTS', 'rarity': ItemRarity.uncommon},
    {'name': 'Steel Helmet', 'desc': '[END +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'END', 'min': 5, 'max': 7, 'slot': 'HELMET', 'rarity': ItemRarity.rare},
    {'name': 'Amulet of Focus', 'desc': '[INT +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'INT', 'min': 10, 'max': 15, 'slot': 'AMULET', 'rarity': ItemRarity.epic},
    {'name': 'Demon Blade', 'desc': '[STR +%AMT%]', 'cat': ItemCategory.equipment, 'stat': 'STR', 'min': 20, 'max': 20, 'slot': 'WEAPON', 'rarity': ItemRarity.legendary},
    {'name': 'Slime Core', 'desc': 'Crafting Material', 'cat': ItemCategory.material, 'rarity': ItemRarity.common},
  ];

  static List<ShopProduct> generateDailyShop() {
    List<ShopProduct> dailyItems = [];
    for (int i = 0; i < 6; i++) {
      final data = gearPool[_rng.nextInt(gearPool.length)];
      final rarity = data['rarity'] as ItemRarity;
      int buff = 0;
      if (data.containsKey('min')) buff = (data['min'] as int) + _rng.nextInt(((data['max'] as int) - (data['min'] as int)) + 1);
      
      dailyItems.add(ShopProduct(
        id: 'shop_${DateTime.now().millisecondsSinceEpoch}_$i',
        name: data['name'], description: (data['desc'] as String).replaceAll('%AMT%', buff.toString()),
        price: 15 + _rng.nextInt(100), type: ProductType.item, category: data['cat'], rarity: rarity,
        buffStat: data['stat'], inGameBoost: buff, dailyReduction: buff, equipSlot: data['slot'],
      ));
    }
    return dailyItems;
  }
}
enum ItemCategory { equipment, material, consumable, other }
enum ItemRarity { common, uncommon, rare, epic, legendary } 

class Item {
  final String id;
  final String name;
  final String description;
  final ItemCategory category;
  final ItemRarity rarity;
  int quantity;
  
  final String? buffStat; 
  final int inGameBoost;  
  final int dailyReduction; 
  // NEW: Tells the game which slot this gear goes into!
  final String? equipSlot; 

  Item({
    required this.id, required this.name, required this.description,
    required this.category, this.rarity = ItemRarity.common,
    this.quantity = 1, this.buffStat, this.inGameBoost = 0,
    this.dailyReduction = 0, this.equipSlot,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'title': name, 'description': description,
    'category': category.name, 'rarity': rarity.name, 
    'quantity': quantity, 'buffStat': buffStat,
    'inGameBoost': inGameBoost, 'dailyReduction': dailyReduction,
    'equipSlot': equipSlot,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String,
    name: json['title'] as String? ?? json['name'] as String? ?? 'Unknown Item',
    description: json['description'] as String? ?? '',
    category: ItemCategory.values.firstWhere((e) => e.name == json['category'], orElse: () => ItemCategory.other),
    rarity: ItemRarity.values.firstWhere((e) => e.name == json['rarity'], orElse: () => ItemRarity.common),
    quantity: json['quantity'] as int? ?? 1,
    buffStat: json['buffStat'] as String?,
    inGameBoost: json['inGameBoost'] as int? ?? 0,
    dailyReduction: json['dailyReduction'] as int? ?? 0,
    equipSlot: json['equipSlot'] as String?,
  );
}
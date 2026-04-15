enum ItemCategory { equipment, material, consumable, other }

class Item {
  final String id;
  final String name;
  final String description;
  final ItemCategory category;
  int quantity;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.quantity = 1,
  });

  // Translators for saving to the hard drive
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name, // 'name' mapped to 'title' in json for safety
      'description': description,
      'category': category.name,
      'quantity': quantity,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['title'] as String? ?? json['name'] as String? ?? 'Unknown Item',
      description: json['description'] as String? ?? '',
      category: ItemCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ItemCategory.other,
      ),
      quantity: json['quantity'] as int? ?? 1,
    );
  }
} 
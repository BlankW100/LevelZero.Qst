import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/item.dart';
import '../services/local_storage.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Equipment', 'Material', 'Once-Use', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _storage.init();
    setState(() {
      _profile = _storage.loadProfile();
    });
  }

  List<Item> _getFilteredItems() {
    if (_profile == null) return [];
    if (_selectedCategory == 'All') return _profile!.inventory;

    return _profile!.inventory.where((item) {
      switch (_selectedCategory) {
        case 'Equipment': return item.category == ItemCategory.equipment;
        case 'Material': return item.category == ItemCategory.material;
        case 'Once-Use': return item.category == ItemCategory.consumable;
        case 'Other': return item.category == ItemCategory.other;
        default: return false;
      }
    }).toList();
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common: return const Color(0xFFB0B0B0);
      case ItemRarity.uncommon: return const Color(0xFFA5FF5C);
      case ItemRarity.rare: return const Color(0xFF42B9F5);
      case ItemRarity.epic: return const Color(0xFF9B51E0);
      case ItemRarity.legendary: return const Color(0xFFFFD700);
    }
  }

  String _getShortCategoryName(ItemCategory category) {
    switch (category) {
      case ItemCategory.equipment: return "EQUIP";
      case ItemCategory.material: return "MAT";
      case ItemCategory.consumable: return "ITEM";
      case ItemCategory.other: return "MISC";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredItems = _getFilteredItems();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("VAULT / INVENTORY", style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top Header
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2)),
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_profile!.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Lv. ${_profile!.level} | Grade: ${_profile!.rank}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400])),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                    const SizedBox(height: 4),
                    Text("${_profile!.coins} G", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),

          // Category Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) { 
                      if (selected) {
                        setState(() => _selectedCategory = category); 
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          
          // Capacity Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Storage Capacity", style: TextStyle(color: Colors.grey[400])),
                Text("${_profile!.inventory.length} / ${_profile!.inventoryCapacity}", style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- THE 5x5 INVENTORY GRID ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, 
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _profile!.inventoryCapacity, 
              itemBuilder: (context, index) {
                bool isSlotOccupied = index < filteredItems.length;

                if (isSlotOccupied) {
                  final item = filteredItems[index];
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: _getRarityColor(item.rarity),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2), 
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            "${item.rarity.name.toUpperCase()}\n${_getShortCategoryName(item.category)}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black, 
                              fontWeight: FontWeight.w900, 
                              fontSize: 9, 
                              fontFamily: 'Courier', 
                              height: 1.1, 
                            ),
                          ),
                        ),
                        if (item.quantity > 1)
                          Positioned(
                            bottom: 2, right: 4,
                            child: Text(
                              "x${item.quantity}",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161621), 
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
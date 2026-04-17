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

  // --- NEW: Interactive Popup Logic ---
  void _showItemDetails(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _getRarityColor(item.rarity), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            item.name,
            style: TextStyle(color: _getRarityColor(item.rarity), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Text("Category: ${item.category.name.toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text("Rarity: ${item.rarity.name.toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              
              // Only show stats if the item actually has them!
              if (item.buffStat != null) ...[
                const SizedBox(height: 12),
                const Text("--- SYSTEM BONUSES ---", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text("Target Stat: ${item.buffStat}", style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                Text("In-Game Boost: +${item.inGameBoost}", style: const TextStyle(color: Colors.amber, fontSize: 13)),
                Text("Daily Reduction: -${item.dailyReduction}", style: const TextStyle(color: Colors.amber, fontSize: 13)),
              ],
              const SizedBox(height: 16),
              Text("Quantity Owned: ${item.quantity}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            // DELETE BUTTON
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(item);
              },
              child: const Text("DELETE", style: TextStyle(color: Colors.redAccent)),
            ),
            // USE / EQUIP BUTTON
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _useItem(item);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: Text(
                item.category == ItemCategory.equipment ? "EQUIP" : "USE", 
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        );
      },
    );
  }

  void _useItem(Item item) {
    setState(() {
      if (item.category == ItemCategory.consumable) {
        // Consume the item
        if (item.quantity > 1) {
          item.quantity--;
        } else {
          _profile!.inventory.remove(item);
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Consumed ${item.name}. System stats slightly restored."), backgroundColor: Theme.of(context).colorScheme.primary));
      } else if (item.category == ItemCategory.equipment) {
        // Equipment logic (Placeholder until we build the equip screen!)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("System Error: Equipment Slot module not yet installed."), backgroundColor: Colors.redAccent));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("This item cannot be used directly."), backgroundColor: Colors.grey));
      }
    });
    _storage.saveProfile(_profile!);
  }

  void _deleteItem(Item item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _profile!.inventory.remove(item);
      }
    });
    _storage.saveProfile(_profile!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Discarded ${item.name}."), backgroundColor: Colors.redAccent));
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
                  
                  // --- NEW: Wrapped in a GestureDetector so it opens the Dialog! ---
                  return GestureDetector(
                    onTap: () => _showItemDetails(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getRarityColor(item.rarity),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 2), 
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                item.name.toUpperCase(), // Display actual item name!
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black, 
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 8, // Scaled down slightly to fit names better
                                  fontFamily: 'Courier', 
                                  height: 1.1, 
                                ),
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
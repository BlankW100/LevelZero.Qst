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

  // The categories matching your requirements
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

  // Helper to filter items based on the selected tab
  List<Item> _getFilteredItems() {
    if (_profile == null) return [];
    
    if (_selectedCategory == 'All') {
      return _profile!.inventory;
    }

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

  // Assigns a specific icon depending on the item category
  IconData _getCategoryIcon(ItemCategory category) {
    switch (category) {
      case ItemCategory.equipment: return Icons.shield;
      case ItemCategory.material: return Icons.diamond;
      case ItemCategory.consumable: return Icons.local_drink;
      case ItemCategory.other: return Icons.extension;
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
        title: Text(
          "VAULT / INVENTORY", 
          style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 1. TOP HEADER (Stats & Money) ---
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
                // Avatar Frame
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                
                // Name & Rank
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _profile!.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Lv. ${_profile!.level} | Grade: ${_profile!.rank}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
                
                // Coins / Wealth
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      "${_profile!.coins} G",
                      style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- 2. CATEGORY TABS ---
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
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) _selectedCategory = category;
                      });
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                      ),
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
                Text("${_profile!.inventory.length} / ${_profile!.inventoryCapacity}", 
                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // --- 3. THE 5x5 INVENTORY GRID ---
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // 5 items per row
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              // Render exactly the number of slots defined by max capacity (starts at 25)
              itemCount: _profile!.inventoryCapacity, 
              itemBuilder: (context, index) {
                // If this specific index has an item, draw the item. Otherwise, draw an empty slot.
                bool isSlotOccupied = index < filteredItems.length;

                if (isSlotOccupied) {
                  final item = filteredItems[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(_getCategoryIcon(item.category), color: Colors.white70, size: 28),
                        ),
                        // Quantity Badge in bottom right
                        if (item.quantity > 1)
                          Positioned(
                            bottom: 2,
                            right: 4,
                            child: Text(
                              "x${item.quantity}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                } else {
                  // DRAW EMPTY SLOT
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black26, // Very dark background for empty slots
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
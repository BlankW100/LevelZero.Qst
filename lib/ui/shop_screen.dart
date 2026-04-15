import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/item.dart';
import '../services/local_storage.dart';
import '../data/shop_data.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;

  List<ShopProduct> _dailyRandoms = [];
  int _hpBought = 0;
  int _mpBought = 0;
  final int _dailyLimit = 5;

  @override
  void initState() {
    super.initState();
    _initShop();
  }

  Future<void> _initShop() async {
    await _storage.init();
    _profile = _storage.loadProfile();

    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0]; 
    String? lastShopDate = prefs.getString('last_shop_date');

    if (lastShopDate != today) {
      _dailyRandoms = ShopData.generateDailyShop();
      _hpBought = 0;
      _mpBought = 0;
      
      await prefs.setString('last_shop_date', today);
      await prefs.setInt('shop_hp_bought', 0);
      await prefs.setInt('shop_mp_bought', 0);
      await prefs.setString('daily_randoms', jsonEncode(_dailyRandoms.map((e) => e.toJson()).toList()));
    } else {
      _hpBought = prefs.getInt('shop_hp_bought') ?? 0;
      _mpBought = prefs.getInt('shop_mp_bought') ?? 0;
      
      String? savedShop = prefs.getString('daily_randoms');
      if (savedShop != null) {
        List<dynamic> decodedList = jsonDecode(savedShop);
        _dailyRandoms = decodedList.map((e) => ShopProduct.fromJson(e)).toList();
      } else {
        _dailyRandoms = ShopData.generateDailyShop();
      }
    }
    setState(() {});
  }

  Future<void> _saveShopState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('shop_hp_bought', _hpBought);
    await prefs.setInt('shop_mp_bought', _mpBought);
    await prefs.setString('daily_randoms', jsonEncode(_dailyRandoms.map((e) => e.toJson()).toList()));
    _storage.saveProfile(_profile!);
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

  void _showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(color: isError ? Colors.white : Colors.black)),
        backgroundColor: isError ? Colors.redAccent : Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _buyBasicItem(String id, String name, int price, bool isHp) {
    if (_profile!.coins < price) {
      _showMessage("System Error: Insufficient funds.", isError: true);
      return;
    }
    if (_profile!.inventory.length >= _profile!.inventoryCapacity) {
      _showMessage("System Error: Inventory is full.", isError: true);
      return;
    }

    setState(() {
      _profile!.coins -= price;
      _profile!.inventory.add(Item(
        id: id, name: name, description: "Restores minor stats.", 
        category: ItemCategory.consumable, rarity: ItemRarity.common
      ));
      
      // Wrapped in curly braces to satisfy linter
      if (isHp) {
        _hpBought++;
      } else {
        _mpBought++;
      }
    });
    
    _saveShopState();
    _showMessage("System Alert: $name added to Vault.");
  }

  void _buyRandomItem(int index) {
    ShopProduct product = _dailyRandoms[index];
    
    // Wrapped in curly braces
    if (product.isSoldOut) {
      return;
    }
    
    if (_profile!.coins < product.price) {
      _showMessage("System Error: Insufficient funds.", isError: true);
      return;
    }
    if (_profile!.inventory.length >= _profile!.inventoryCapacity) {
      _showMessage("System Error: Inventory is full.", isError: true);
      return;
    }

    setState(() {
      _profile!.coins -= product.price;
      _profile!.inventory.add(product.toItem());
      _dailyRandoms[index].isSoldOut = true; 
    });

    _saveShopState();
    _showMessage("System Alert: ${product.name} acquired!");
  }

  void _devGiveCoins() {
    setState(() {
      _profile!.coins += 1000;
    });
    _storage.saveProfile(_profile!);
    _showMessage("Cheat Activated: +1000 Gold");
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null || _dailyRandoms.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("SYSTEM SHOP", style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("FUNDS", style: TextStyle(color: Colors.grey, fontSize: 16)),
                  GestureDetector(
                    onDoubleTap: _devGiveCoins,
                    child: Row(
                      children: [
                        Text("${_profile!.coins}", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 28)),
                        const SizedBox(width: 8),
                        const Icon(Icons.monetization_on, color: Colors.amber, size: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text("DAILY SUPPLIES (Resets Midnight)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _buildBasicFlaskCard("Small Life Flask", 15, true, _hpBought),
                  const SizedBox(height: 10),
                  _buildBasicFlaskCard("Small Mana Flask", 15, false, _mpBought),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 24.0, bottom: 8.0),
              child: Text("DAILY ROTATION", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = _dailyRandoms[index];
                final color = _getRarityColor(item.rarity);
                final canAfford = _profile!.coins >= item.price;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  color: Theme.of(context).colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: item.isSoldOut ? Colors.grey[800]! : color.withValues(alpha: 0.6), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Opacity(
                    opacity: item.isSoldOut ? 0.4 : 1.0, 
                    child: ListTile(
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: color, 
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${item.rarity.name.toUpperCase()}\nITEM",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black, 
                            fontWeight: FontWeight.w900, 
                            fontSize: 8, 
                            fontFamily: 'Courier', 
                            height: 1.1
                          ),
                        ),
                      ),
                      title: Text(item.name, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      subtitle: Text(item.description, style: const TextStyle(fontSize: 12)),
                      trailing: item.isSoldOut 
                        ? const Text("SOLD", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                        : ElevatedButton(
                            onPressed: () => _buyRandomItem(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canAfford ? color.withValues(alpha: 0.2) : Colors.grey[800],
                              side: BorderSide(color: canAfford ? color : Colors.transparent),
                            ),
                            child: Text("${item.price} G", style: TextStyle(color: canAfford ? Colors.white : Colors.grey)),
                          ),
                    ),
                  ),
                );
              },
              childCount: _dailyRandoms.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildBasicFlaskCard(String name, int price, bool isHp, int amountBought) {
    bool isSoldOut = amountBought >= _dailyLimit;
    bool canAfford = _profile!.coins >= price;

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(12),
      ),
      child: Opacity(
        opacity: isSoldOut ? 0.4 : 1.0,
        child: ListTile(
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFB0B0B0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 2),
            ),
            alignment: Alignment.center,
            child: const Text(
              "COMMON\nITEM",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 8, fontFamily: 'Courier', height: 1.1),
            ),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Limit: $amountBought / $_dailyLimit"),
          trailing: isSoldOut 
            ? const Text("SOLD OUT", style: TextStyle(color: Colors.red))
            : ElevatedButton(
                onPressed: () => _buyBasicItem("basic_${isHp?'hp':'mp'}", name, price, isHp),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.grey[800],
                ),
                child: Text("$price G", style: TextStyle(color: canAfford ? Theme.of(context).colorScheme.primary : Colors.grey)),
              ),
        ),
      ),
    );
  }
}
import 'dart:math' show max;
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/item.dart';
import '../services/local_storage.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;

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

  // --- NEW: Added Rarity Color to Stats Screen ---
  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common: return const Color(0xFFB0B0B0);
      case ItemRarity.uncommon: return const Color(0xFFA5FF5C);
      case ItemRarity.rare: return const Color(0xFF42B9F5);
      case ItemRarity.epic: return const Color(0xFF9B51E0);
      case ItemRarity.legendary: return const Color(0xFFFFD700);
    }
  }

  // --- NEW: The Equipped Item Popup Dialog ---
  void _showEquippedItemDetails(Item item, String slot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: _getRarityColor(item.rarity), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.name, style: TextStyle(color: _getRarityColor(item.rarity), fontWeight: FontWeight.bold))),
              Text("[$slot]", style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.description, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Text("Rarity: ${item.rarity.name.toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              
              if (item.buffStat != null) ...[
                const SizedBox(height: 12),
                const Text("--- GRANTED BONUSES ---", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text("+${item.inGameBoost} ${item.buffStat}", style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("CLOSE", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _unequipItem(item, slot);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("REMOVE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _unequipItem(Item item, String slot) {
    if (_profile!.inventory.length >= _profile!.inventoryCapacity) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inventory Full! Cannot remove gear.")));
      return;
    }
    setState(() {
      _profile!.inventory.add(item);
      _profile!.equippedGear.remove(slot);
      
      int boost = item.inGameBoost;
      switch (item.buffStat) {
        case 'STR': _profile!.strength -= boost; break;
        case 'AGI': _profile!.agility -= boost; break;
        case 'INT': _profile!.intelligence -= boost; break;
        case 'END': _profile!.endurance -= boost; break;
      }
      _profile!.updateHpMp();
    });
    _storage.saveProfile(_profile!);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unequipped ${item.name}.")));
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    int maxHp = 100 + (_profile!.endurance * 20) + (_profile!.level * 50);
    int currentHp = maxHp; 
    int maxMp = 50 + (_profile!.intelligence * 15) + (_profile!.level * 20);
    int currentMp = maxMp;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text("SYSTEM STATS", style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0)), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_profile!.name.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("LV. ${_profile!.level} | ${_profile!.rank}", style: const TextStyle(fontSize: 16, color: Colors.amber)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text("HP   ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: currentHp / maxHp, color: Colors.redAccent, backgroundColor: Colors.red.withValues(alpha: 0.2), minHeight: 8))),
                        Text("  $currentHp/$maxHp", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text("MANA ", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: currentMp / maxMp, color: Colors.blueAccent, backgroundColor: Colors.blue.withValues(alpha: 0.2), minHeight: 8))),
                        Text("  $currentMp/$maxMp", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- EQUIPMENT UI ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown[700]!, width: 2), 
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(children: [_buildEquipSlot("HELMET", Icons.security), const SizedBox(height: 12), _buildEquipSlot("CHEST", Icons.shield), const SizedBox(height: 12), _buildEquipSlot("BOOTS", Icons.snowshoeing)]),
                    Expanded(child: Container(height: 200, alignment: Alignment.center, child: Icon(Icons.person, size: 180, color: Colors.grey[800]))),
                    Column(children: [_buildEquipSlot("WEAPON", Icons.colorize), const SizedBox(height: 12), _buildEquipSlot("RING", Icons.radio_button_unchecked), const SizedBox(height: 12), _buildEquipSlot("AMULET", Icons.wb_iridescent)]),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(color: const Color(0xFF161621), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_buildStatBox("STR", _profile!.strength), _buildStatBox("AGI", _profile!.agility), _buildStatBox("INT", _profile!.intelligence), _buildStatBox("END", _profile!.endurance)],
                ),
              ),
              const SizedBox(height: 20),

              const Text("STAT DISTRIBUTION", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              SizedBox(
                width: 250, height: 250,
                child: CustomPaint(
                  painter: RadarChartPainter(str: _profile!.strength, agi: _profile!.agility, intl: _profile!.intelligence, end: _profile!.endurance),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UPGRADED: Now shows the Retro Box UI when equipped! ---
  Widget _buildEquipSlot(String slot, IconData defaultIcon) {
    bool isEquipped = _profile!.equippedGear.containsKey(slot);
    Item? item = isEquipped ? _profile!.equippedGear[slot] : null;

    return GestureDetector(
      onTap: () {
        if (isEquipped) {
          _showEquippedItemDetails(item!, slot);
        }
      },
      child: Column(
        children: [
          Container(
            width: 55, height: 55,
            decoration: BoxDecoration(
              // ADDED THE ! HERE -> item!.rarity
              color: isEquipped ? _getRarityColor(item!.rarity) : Colors.black45,
              border: Border.all(color: isEquipped ? Colors.black : Colors.brown[600]!, width: isEquipped ? 2.0 : 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(2.0),
            child: isEquipped 
                ? Text(
                    item!.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 8, fontFamily: 'Courier', height: 1.1),
                  )
                : Icon(defaultIcon, color: Colors.white24, size: 28),
          ),
          const SizedBox(height: 4),
          Text(isEquipped ? item!.name.split(' ').first : slot, 
            // ADDED THE ! HERE -> item!.rarity
            style: TextStyle(fontSize: 10, color: isEquipped ? _getRarityColor(item!.rarity) : Colors.grey, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, int value) {
    return Container(
      width: 60, height: 70,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text("$value", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ... Keep the RadarChartPainter class exactly the same at the bottom of the file!
class RadarChartPainter extends CustomPainter {
  final int str, agi, intl, end;
  RadarChartPainter({required this.str, required this.agi, required this.intl, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2; double centerY = size.height / 2; double radius = size.width / 2;
    int maxStat = [str, agi, intl, end, 10].reduce(max); 
    double scaleLimit = maxStat * 1.2; 

    Paint gridPaint = Paint()..color = Colors.grey[800]!..style = PaintingStyle.stroke..strokeWidth = 1;
    Paint webPaint = Paint()..color = Colors.grey[700]!..style = PaintingStyle.stroke..strokeWidth = 1;
    Paint fillPaint = Paint()..color = const Color(0xFF42B9F5).withValues(alpha: 0.4)..style = PaintingStyle.fill;
    Paint outlinePaint = Paint()..color = const Color(0xFF42B9F5)..style = PaintingStyle.stroke..strokeWidth = 2;

    for (int i = 1; i <= 4; i++) {
      double r = radius * (i / 4);
      Path path = Path()..moveTo(centerX, centerY - r)..lineTo(centerX + r, centerY)..lineTo(centerX, centerY + r)..lineTo(centerX - r, centerY)..close();
      canvas.drawPath(path, gridPaint);
    }
    canvas.drawLine(Offset(centerX, centerY - radius), Offset(centerX, centerY + radius), webPaint);
    canvas.drawLine(Offset(centerX - radius, centerY), Offset(centerX + radius, centerY), webPaint);

    double strR = radius * (str / scaleLimit); double agiR = radius * (agi / scaleLimit);
    double endR = radius * (end / scaleLimit); double intR = radius * (intl / scaleLimit);

    Path statPath = Path()..moveTo(centerX, centerY - strR)..lineTo(centerX + agiR, centerY)..lineTo(centerX, centerY + endR)..lineTo(centerX - intR, centerY)..close();
    canvas.drawPath(statPath, fillPaint); canvas.drawPath(statPath, outlinePaint);

    _drawText(canvas, "STR", Offset(centerX, centerY - radius - 15));
    _drawText(canvas, "AGI", Offset(centerX + radius + 15, centerY));
    _drawText(canvas, "END", Offset(centerX, centerY + radius + 10));
    _drawText(canvas, "INT", Offset(centerX - radius - 20, centerY));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    TextPainter painter = TextPainter(text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
    painter.layout();
    painter.paint(canvas, Offset(position.dx - (painter.width / 2), position.dy - (painter.height / 2)));
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
import 'dart:math' show max;
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
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

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Dynamic HP & MP based on your actual stats!
    int maxHp = 100 + (_profile!.endurance * 20) + (_profile!.level * 50);
    int currentHp = maxHp; // Default to full until we add a damage system
    int maxMp = 50 + (_profile!.intelligence * 15) + (_profile!.level * 20);
    int currentMp = maxMp;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("SYSTEM STATS", style: TextStyle(color: Theme.of(context).colorScheme.primary, letterSpacing: 2.0)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // --- 1. USER PROFILE HEADER ---
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
                    // HP Bar
                    Row(
                      children: [
                        const Text("HP   ", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(value: currentHp / maxHp, color: Colors.redAccent, backgroundColor: Colors.red.withValues(alpha: 0.2), minHeight: 8),
                          ),
                        ),
                        Text("  $currentHp/$maxHp", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // MP Bar
                    Row(
                      children: [
                        const Text("MANA ", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(value: currentMp / maxMp, color: Colors.blueAccent, backgroundColor: Colors.blue.withValues(alpha: 0.2), minHeight: 8),
                          ),
                        ),
                        Text("  $currentMp/$maxMp", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 2. EQUIPMENT UI ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown[700]!, width: 2), // Gives it that RPG leather/wood border feel
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Column (Armor)
                    Column(
                      children: [
                        _buildEquipSlot("HELMET", Icons.security),
                        const SizedBox(height: 12),
                        _buildEquipSlot("CHEST", Icons.shield),
                        const SizedBox(height: 12),
                        _buildEquipSlot("BOOTS", Icons.snowshoeing),
                      ],
                    ),
                    // Center Silhouette
                    Expanded(
                      child: Container(
                        height: 200,
                        alignment: Alignment.center,
                        child: Icon(Icons.person, size: 180, color: Colors.grey[800]), // Silhouette placeholder
                      ),
                    ),
                    // Right Column (Weapons & Accessories)
                    Column(
                      children: [
                        _buildEquipSlot("WEAPON", Icons.colorize), // Closest to a sword icon
                        const SizedBox(height: 12),
                        _buildEquipSlot("RING", Icons.radio_button_unchecked),
                        const SizedBox(height: 12),
                        _buildEquipSlot("AMULET", Icons.wb_iridescent),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 3. STAT BLOCKS ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF161621),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatBox("STR", _profile!.strength),
                    _buildStatBox("AGI", _profile!.agility),
                    _buildStatBox("INT", _profile!.intelligence),
                    _buildStatBox("END", _profile!.endurance),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- 4. THE RADAR CHART ---
              const Text("STAT DISTRIBUTION", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 20),
              SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: RadarChartPainter(
                    str: _profile!.strength,
                    agi: _profile!.agility,
                    intl: _profile!.intelligence, // Using 'intl' to avoid protected keyword 'int'
                    end: _profile!.endurance,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for the Empty Equipment Slots
  Widget _buildEquipSlot(String label, IconData defaultIcon) {
    return Column(
      children: [
        Container(
          width: 55, height: 55,
          decoration: BoxDecoration(
            color: Colors.black45,
            border: Border.all(color: Colors.brown[600]!, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(defaultIcon, color: Colors.white24, size: 28),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Helper Widget for the Stat Blocks
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

// ==========================================
// THE MATHEMATICAL RADAR CHART ENGINE
// ==========================================
class RadarChartPainter extends CustomPainter {
  final int str;
  final int agi;
  final int intl;
  final int end;

  RadarChartPainter({required this.str, required this.agi, required this.intl, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    // Find the highest stat to scale the chart dynamically
    int maxStat = [str, agi, intl, end, 10].reduce(max); 
    // Add 20% padding to the top so the graph never touches the very edge
    double scaleLimit = maxStat * 1.2; 

    Paint gridPaint = Paint()..color = Colors.grey[800]!..style = PaintingStyle.stroke..strokeWidth = 1;
    Paint webPaint = Paint()..color = Colors.grey[700]!..style = PaintingStyle.stroke..strokeWidth = 1;
    
    Paint fillPaint = Paint()
      ..color = const Color(0xFF42B9F5).withValues(alpha: 0.4) // Neon Blue fill
      ..style = PaintingStyle.fill;
      
    Paint outlinePaint = Paint()
      ..color = const Color(0xFF42B9F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 1. Draw the concentric grid webs (Background)
    for (int i = 1; i <= 4; i++) {
      double r = radius * (i / 4);
      Path path = Path();
      path.moveTo(centerX, centerY - r); // Top
      path.lineTo(centerX + r, centerY); // Right
      path.lineTo(centerX, centerY + r); // Bottom
      path.lineTo(centerX - r, centerY); // Left
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // 2. Draw the Axis Lines
    canvas.drawLine(Offset(centerX, centerY - radius), Offset(centerX, centerY + radius), webPaint);
    canvas.drawLine(Offset(centerX - radius, centerY), Offset(centerX + radius, centerY), webPaint);

    // 3. Calculate dynamic points based on your actual stats
    // STR (Top), AGI (Right), END (Bottom), INT (Left)
    double strR = radius * (str / scaleLimit);
    double agiR = radius * (agi / scaleLimit);
    double endR = radius * (end / scaleLimit);
    double intR = radius * (intl / scaleLimit);

    Offset strPoint = Offset(centerX, centerY - strR);
    Offset agiPoint = Offset(centerX + agiR, centerY);
    Offset endPoint = Offset(centerX, centerY + endR);
    Offset intPoint = Offset(centerX - intR, centerY);

    // 4. Draw the actual Stat Polygon
    Path statPath = Path();
    statPath.moveTo(strPoint.dx, strPoint.dy);
    statPath.lineTo(agiPoint.dx, agiPoint.dy);
    statPath.lineTo(endPoint.dx, endPoint.dy);
    statPath.lineTo(intPoint.dx, intPoint.dy);
    statPath.close();

    canvas.drawPath(statPath, fillPaint);
    canvas.drawPath(statPath, outlinePaint);

    // 5. Draw the Labels (STR, AGI, END, INT)
    _drawText(canvas, "STR", Offset(centerX, centerY - radius - 15));
    _drawText(canvas, "AGI", Offset(centerX + radius + 15, centerY));
    _drawText(canvas, "END", Offset(centerX, centerY + radius + 10));
    _drawText(canvas, "INT", Offset(centerX - radius - 20, centerY));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, Offset(position.dx - (painter.width / 2), position.dy - (painter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
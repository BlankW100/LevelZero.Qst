import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';
import '../data/monster_data.dart';

class CombatScreen extends StatefulWidget {
  final Monster enemy;

  const CombatScreen({super.key, required this.enemy});

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;
  
  late int _enemyHp;
  final List<String> _battleLog = [];
  bool _isPlayerTurn = true;
  bool _isGameOver = false;
  bool _isDefending = false;

  @override
  void initState() {
    super.initState();
    _enemyHp = widget.enemy.maxHp;
    _log("=== ENGAGING: ${widget.enemy.name.toUpperCase()} ===");
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _storage.init();
    setState(() {
      _profile = _storage.loadProfile();
      _profile?.updateHpMp(); 
    });
  }

  void _log(String msg) {
    setState(() => _battleLog.insert(0, msg));
  }

  // --- COMMAND: ATTACK ---
  void _playerAttack() async {
    setState(() { _isPlayerTurn = false; _isDefending = false; });
    
    _log("> Hero tries to: SLASH");
    await Future.delayed(const Duration(milliseconds: 500));

    int roll = Random().nextInt(20) + 1;
    int damage = 0;
    
    if (roll == 1) {
      _log("- Effect: Critical Miss! Attack diverted.");
    } else if (roll == 20) {
      damage = _profile!.strength * 3;
      _log("- Effect: CRITICAL HIT! Massive damage dealt.");
      _log("* Base damage: $damage");
    } else {
      damage = max(1, (_profile!.strength * (roll / 10)).toInt());
      _log("- Effect: Direct hit on ${widget.enemy.name}.");
      _log("* Base damage: $damage");
    }

    setState(() => _enemyHp = max(0, _enemyHp - damage));

    if (_enemyHp <= 0) {
      await Future.delayed(const Duration(seconds: 1));
      _victory();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      _enemyTurn();
    }
  }

  // --- COMMAND: MAGIC ---
  void _playerMagic() async {
    if (_profile!.currentMp < 20) {
      _log("> INSUFFICIENT MP!");
      return;
    }
    
    setState(() { 
      _isPlayerTurn = false; 
      _isDefending = false; 
      _profile!.currentMp -= 20; 
    });

    _log("> Hero tries to: CAST SPELL");
    await Future.delayed(const Duration(milliseconds: 500));

    int roll = Random().nextInt(10) + 1;
    int damage = (_profile!.intelligence * 1.5).toInt() + roll;
    
    _log("- Effect: Arcane energy strikes ${widget.enemy.name}.");
    _log("* Magic damage: $damage");
    
    setState(() => _enemyHp = max(0, _enemyHp - damage));

    if (_enemyHp <= 0) {
      await Future.delayed(const Duration(seconds: 1));
      _victory();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      _enemyTurn();
    }
  }

  // --- COMMAND: DEFEND ---
  void _playerDefend() async {
    setState(() {
      _isPlayerTurn = false;
      _isDefending = true;
    });
    
    _log("> Hero tries to: BRACE");
    _log("- Effect: Stance shifted. Endurance effectively tripled.");
    await Future.delayed(const Duration(seconds: 1));
    _enemyTurn();
  }

  // --- COMMAND: RUN ---
  void _playerRun() async {
    setState(() => _isPlayerTurn = false);
    
    _log("> Hero tries to: FLEE");
    await Future.delayed(const Duration(milliseconds: 500));

    int escapeChance = 50 + (_profile!.agility * 2);
    int roll = Random().nextInt(100);

    if (roll < escapeChance) {
      _log("- Effect: Escape successful. Disengaging...");
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } else {
      _log("- Effect: Escape failed! Enemy blocking the path.");
      await Future.delayed(const Duration(seconds: 1));
      _enemyTurn();
    }
  }

  // --- ENEMY TURN ---
  void _enemyTurn() async {
    if (_isGameOver) return;

    _log("=== ENEMY TURN ===");
    await Future.delayed(const Duration(milliseconds: 500));

    int roll = Random().nextInt(20) + 1;
    int dodgeChance = min(50, _profile!.agility * 2); 
    int dodgeRoll = Random().nextInt(100);

    if (dodgeRoll < dodgeChance) {
      _log("! ${widget.enemy.name.toUpperCase()} strikes, but misses entirely! (Dodge)");
    } else if (roll < 4) {
      _log("! ${widget.enemy.name.toUpperCase()} fumbles its attack.");
    } else {
      int rawDamage = widget.enemy.baseAtk + (roll ~/ 2);
      int block = (_profile!.endurance * 0.5).toInt();
      if (_isDefending) block *= 3; 

      int finalDamage = max(1, rawDamage - block);
      
      _log("! ${widget.enemy.name.toUpperCase()} lands a blow.");
      _log("- Damage taken: $finalDamage (Mitigated: $block)");
      
      setState(() => _profile!.currentHp = max(0, _profile!.currentHp - finalDamage));
    }

    if (_profile!.currentHp <= 0) {
      await Future.delayed(const Duration(seconds: 1));
      _defeat();
    } else {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isPlayerTurn = true;
        _log("=== HERO TURN ===");
      });
    }
  }

  void _victory() {
    setState(() => _isGameOver = true);
    int xpGained = widget.enemy.maxHp;
    int coinsGained = widget.enemy.maxHp ~/ 2;
    
    _profile!.currentXp += xpGained;
    _profile!.coins += coinsGained;
    _storage.saveProfile(_profile!); 
    
    _log("=== TARGET DESTROYED ===");
    _log("+ Gained $xpGained XP");
    _log("+ Found $coinsGained Coins");
  }

  void _defeat() {
    setState(() => _isGameOver = true);
    _log("=== CRITICAL FAILURE ===");
    _log("SYSTEM: Emergency teleport activated.");
    _profile!.currentHp = _profile!.maxHp; 
    _storage.saveProfile(_profile!);
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

    const retroFont = 'Courier';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // TOP HALF: ASCII ARENA
            // ==========================================
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PLAYER INFO (Left) ---
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_profile!.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontFamily: retroFont, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Lv ${_profile!.level}", style: const TextStyle(color: Colors.white70, fontFamily: retroFont, fontSize: 12)),
                          const SizedBox(height: 12),
                          const Text("HP", style: TextStyle(color: Colors.redAccent, fontFamily: retroFont, fontSize: 14)),
                          Text("${_profile!.currentHp}/${_profile!.maxHp}", style: const TextStyle(color: Colors.white, fontFamily: retroFont, fontSize: 14)),
                          const SizedBox(height: 8),
                          const Text("MP", style: TextStyle(color: Colors.blueAccent, fontFamily: retroFont, fontSize: 14)),
                          Text("${_profile!.currentMp}/${_profile!.maxMp}", style: const TextStyle(color: Colors.white, fontFamily: retroFont, fontSize: 14)),
                        ],
                      ),
                    ),
                    
                    // --- ENEMY ASCII & INFO (Right) ---
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(widget.enemy.name.toUpperCase(), style: TextStyle(color: widget.enemy.colorTheme, fontFamily: retroFont, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("HP: $_enemyHp/${widget.enemy.maxHp}", style: const TextStyle(color: Colors.redAccent, fontFamily: retroFont, fontSize: 14)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                widget.enemy.asciiArt,
                                style: TextStyle(color: widget.enemy.colorTheme, fontFamily: retroFont, fontSize: 14, height: 1.2),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // MIDDLE HALF: TERMINAL LOG
            // ==========================================
            Expanded(
              flex: 4,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white38, width: 1),
                    bottom: BorderSide(color: Colors.white38, width: 1),
                  ),
                ),
                child: ListView.builder(
                  reverse: true, // Auto-scrolls to the newest message at the bottom
                  padding: const EdgeInsets.all(12),
                  itemCount: _battleLog.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        _battleLog[index], 
                        style: TextStyle(
                          color: index == 0 ? Colors.white : Colors.white54, // Highlight newest text
                          fontFamily: retroFont, 
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ==========================================
            // BOTTOM HALF: SPACED BUTTON CONTROLS
            // ==========================================
            Container(
              height: 220,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: _isGameOver 
                ? Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text("CLOSE TERMINAL", style: TextStyle(fontFamily: retroFont, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                    ),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _buildActionButton("SLASH", "STR", _isPlayerTurn ? _playerAttack : null),
                            const SizedBox(width: 16),
                            _buildActionButton("CAST", "INT", _isPlayerTurn ? _playerMagic : null),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Row(
                          children: [
                            _buildActionButton("BRACE", "END", _isPlayerTurn ? _playerDefend : null),
                            const SizedBox(width: 16),
                            _buildActionButton("FLEE", "AGI", _isPlayerTurn ? _playerRun : null),
                          ],
                        ),
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, String stat, VoidCallback? onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: onTap == null ? Colors.white24 : Colors.white, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Sharp terminal edges
          backgroundColor: Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: onTap == null ? Colors.white24 : Colors.white, fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            Text("[$stat]", style: TextStyle(color: onTap == null ? Colors.transparent : Colors.amber, fontFamily: 'Courier', fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
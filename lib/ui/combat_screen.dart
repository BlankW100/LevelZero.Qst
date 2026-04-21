import 'dart:math';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/local_storage.dart';

class CombatScreen extends StatefulWidget {
  final String monsterName;
  final int enemyMaxHp;
  final int enemyAtk;
  final Color colorTheme;

  const CombatScreen({
    super.key, required this.monsterName, required this.enemyMaxHp, 
    required this.enemyAtk, required this.colorTheme
  });

  @override
  State<CombatScreen> createState() => _CombatScreenState();
}

class _CombatScreenState extends State<CombatScreen> {
  final StorageService _storage = StorageService();
  HunterProfile? _profile;
  
  late int _enemyHp;
  String _battleMessage = "";
  bool _isPlayerTurn = true;
  bool _isGameOver = false;
  bool _isDefending = false;

  @override
  void initState() {
    super.initState();
    _enemyHp = widget.enemyMaxHp;
    _battleMessage = "Wild ${widget.monsterName.toUpperCase()} appeared!";
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _storage.init();
    setState(() {
      _profile = _storage.loadProfile();
      _profile?.updateHpMp(); // Ensure HP/MP limits are correct
    });
  }

  void _typeMessage(String msg) {
    setState(() => _battleMessage = msg);
  }

  // --- COMMAND: ATTACK (Uses STR) ---
  void _playerAttack() async {
    setState(() { _isPlayerTurn = false; _isDefending = false; });
    
    int roll = Random().nextInt(20) + 1;
    int damage = 0;
    
    if (roll == 1) {
      _typeMessage("You attacked... but missed!");
    } else if (roll == 20) {
      damage = _profile!.strength * 3;
      _typeMessage("CRITICAL HIT! Dealt $damage damage!");
    } else {
      damage = (_profile!.strength * (roll / 10)).toInt();
      if (damage < 1) damage = 1;
      _typeMessage("You attacked! Dealt $damage damage.");
    }

    setState(() => _enemyHp = max(0, _enemyHp - damage));

    if (_enemyHp <= 0) {
      await Future.delayed(const Duration(seconds: 2));
      _victory();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _enemyTurn();
    }
  }

  // --- COMMAND: MAGIC/SKILL (Uses INT & MP) ---
  void _playerMagic() async {
    if (_profile!.currentMp < 20) {
      _typeMessage("Not enough MP!");
      return;
    }
    
    setState(() { 
      _isPlayerTurn = false; 
      _isDefending = false; 
      _profile!.currentMp -= 20; 
    });

    // Magic never misses and scales heavily with INT
    int roll = Random().nextInt(10) + 1;
    int damage = (_profile!.intelligence * 1.5).toInt() + roll;
    
    _typeMessage("You cast a Spell! Dealt $damage damage!");
    setState(() => _enemyHp = max(0, _enemyHp - damage));

    if (_enemyHp <= 0) {
      await Future.delayed(const Duration(seconds: 2));
      _victory();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      _enemyTurn();
    }
  }

  // --- COMMAND: DEFEND (Uses END) ---
  void _playerDefend() async {
    setState(() {
      _isPlayerTurn = false;
      _isDefending = true;
    });
    
    _typeMessage("You took a defensive stance!");
    await Future.delayed(const Duration(seconds: 2));
    _enemyTurn();
  }

  // --- COMMAND: RUN (Uses AGI) ---
  void _playerRun() async {
    setState(() => _isPlayerTurn = false);
    
    // AGI determines run success. 50% base + AGI bonus.
    int escapeChance = 50 + (_profile!.agility * 2);
    int roll = Random().nextInt(100);

    if (roll < escapeChance) {
      _typeMessage("Got away safely!");
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    } else {
      _typeMessage("Can't escape!");
      await Future.delayed(const Duration(seconds: 2));
      _enemyTurn();
    }
  }

  // --- ENEMY TURN (Checked against Player AGI & END) ---
  void _enemyTurn() async {
    if (_isGameOver) return;

    int roll = Random().nextInt(20) + 1;
    
    // 1. Dodge Check (AGI)
    // 5 AGI = 10% dodge chance. Max 50% dodge.
    int dodgeChance = min(50, _profile!.agility * 2); 
    int dodgeRoll = Random().nextInt(100);

    if (dodgeRoll < dodgeChance) {
      _typeMessage("${widget.monsterName} attacked... but you DODGED!");
    } else if (roll < 4) {
      _typeMessage("${widget.monsterName}'s attack missed!");
    } else {
      // 2. Damage Mitigation Check (END)
      int rawDamage = widget.enemyAtk + (roll ~/ 2);
      int block = (_profile!.endurance * 0.5).toInt();
      if (_isDefending) block *= 3; // Defending triples your armor!

      int finalDamage = max(1, rawDamage - block);
      
      _typeMessage("${widget.monsterName} hit you for $finalDamage DMG!");
      setState(() => _profile!.currentHp = max(0, _profile!.currentHp - finalDamage));
    }

    if (_profile!.currentHp <= 0) {
      await Future.delayed(const Duration(seconds: 2));
      _defeat();
    } else {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isPlayerTurn = true;
        _battleMessage = "What will ${_profile!.name.toUpperCase()} do?";
      });
    }
  }

  void _victory() {
    setState(() => _isGameOver = true);
    int xpGained = widget.enemyMaxHp;
    int coinsGained = widget.enemyMaxHp ~/ 2;
    
    _profile!.currentXp += xpGained;
    _profile!.coins += coinsGained;
    _storage.saveProfile(_profile!); 
    
    _typeMessage("VICTORY! Gained $xpGained XP & $coinsGained G.");
  }

  void _defeat() {
    setState(() => _isGameOver = true);
    _typeMessage("YOU BLACKED OUT...");
    _profile!.currentHp = _profile!.maxHp; // Heal to prevent softlock
    _storage.saveProfile(_profile!);
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Retro Styling Variables
    const retroFont = 'Courier';
    final boxBorder = Border.all(color: Colors.white, width: 4);

    return Scaffold(
      backgroundColor: const Color(0xFF202020), // Dark retro grey
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // TOP HALF: THE BATTLEFIELD
            // ==========================================
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- ENEMY ROW (Top Right) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enemy Info Box
                        Container(
                          width: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.black, border: boxBorder, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.monsterName.toUpperCase(), style: const TextStyle(color: Colors.white, fontFamily: retroFont, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text("HP", style: TextStyle(color: Colors.amber, fontFamily: retroFont, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: _enemyHp / widget.enemyMaxHp, color: widget.colorTheme, backgroundColor: Colors.white24, minHeight: 10),
                            ],
                          ),
                        ),
                        // Enemy Sprite (Mockup)
                        Icon(Icons.catching_pokemon, size: 80, color: widget.colorTheme),
                      ],
                    ),
                    
                    // --- PLAYER ROW (Bottom Left) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Player Sprite (Mockup)
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Icon(Icons.person, size: 90, color: Colors.white70),
                        ),
                        // Player Info Box
                        Container(
                          width: 180,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.black, border: boxBorder, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_profile!.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontFamily: retroFont, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text("HP  ${_profile!.currentHp} / ${_profile!.maxHp}", style: const TextStyle(color: Colors.greenAccent, fontFamily: retroFont, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: _profile!.currentHp / _profile!.maxHp, color: Colors.greenAccent, backgroundColor: Colors.white24, minHeight: 8),
                              const SizedBox(height: 8),
                              Text("MP  ${_profile!.currentMp} / ${_profile!.maxMp}", style: const TextStyle(color: Colors.blueAccent, fontFamily: retroFont, fontSize: 12, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(value: _profile!.currentMp / _profile!.maxMp, color: Colors.blueAccent, backgroundColor: Colors.white24, minHeight: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // BOTTOM HALF: THE CONSOLE / MENU
            // ==========================================
            Container(
              height: 200,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white, width: 4))),
              child: Row(
                children: [
                  // TEXT CONSOLE
                  Expanded(
                    flex: _isPlayerTurn && !_isGameOver ? 1 : 1, // Full width if not player turn
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: boxBorder, borderRadius: BorderRadius.circular(8)),
                      alignment: Alignment.topLeft,
                      child: Text(
                        _battleMessage, 
                        style: const TextStyle(color: Colors.white, fontFamily: retroFont, fontSize: 18, height: 1.5, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                  
                  // ACTION MENU (Only shows on Player's Turn)
                  if (_isPlayerTurn && !_isGameOver) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(border: boxBorder, borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  _buildMenuButton("FIGHT", _playerAttack, Colors.redAccent),
                                  _buildMenuButton("MAGIC", _playerMagic, Colors.blueAccent),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  _buildMenuButton("DEFEND", _playerDefend, Colors.orangeAccent),
                                  _buildMenuButton("RUN", _playerRun, Colors.greenAccent),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else if (_isGameOver) ...[
                     // EXIT MENU
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white24, border: boxBorder, borderRadius: BorderRadius.circular(8)),
                          alignment: Alignment.center,
                          child: const Text("TAP TO EXIT", style: TextStyle(color: Colors.white, fontFamily: retroFont, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for the retro 2x2 grid buttons
  Widget _buildMenuButton(String label, VoidCallback onTap, Color hoverColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(border: Border.all(color: Colors.white24, width: 2), borderRadius: BorderRadius.circular(4)),
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white, fontFamily: 'Courier', fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
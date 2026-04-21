import 'package:flutter/material.dart';

class Monster {
  final String id;
  final String name;
  final String rank;
  final String statFocus;
  final int maxHp;
  final int baseAtk;
  final Color colorTheme;
  final String asciiArt;
  final bool isHidden;

  Monster({
    required this.id,
    required this.name,
    required this.rank,
    required this.statFocus,
    required this.maxHp,
    required this.baseAtk,
    required this.colorTheme,
    required this.asciiArt,
    this.isHidden = false,
  });
}

class MonsterDatabase {
  static final List<Monster> initialDungeonMobs = [
    Monster(
      id: 'mob_001',
      name: 'Goblin Scout',
      rank: 'E-Rank',
      statFocus: 'STR',
      maxHp: 50,
      baseAtk: 10,
      colorTheme: Colors.brown,
      asciiArt: '''
  ,      ,
 /(      )\\
|  \\    /  |
|  =.  .=  |
 \\(  oo  )/
   \\____/
      ''',
    ),
    Monster(
      id: 'mob_002',
      name: 'Toxic Slime',
      rank: 'D-Rank',
      statFocus: 'AGI',
      maxHp: 150,
      baseAtk: 25,
      colorTheme: Colors.greenAccent,
      asciiArt: '''
   ______
  /      \\
 |  o  o  |
 |  \\__/  |
  \\______/
      ''',
    ),
    Monster(
      id: 'mob_003',
      name: 'Void Distortion',
      rank: '??-Rank',
      statFocus: 'HIDDEN',
      maxHp: 999,
      baseAtk: 999,
      colorTheme: Colors.purpleAccent,
      isHidden: true,
      asciiArt: '''
  .   * .
 * _     *
    / \\
 * \\_/    *
  .   * .
      ''',
    ),
  ];
}
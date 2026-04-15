import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/quest.dart'; // Added so the vault knows what a Quest is

class StorageService {
  static const String _profileKey = 'hunter_profile';
  static const String _questsKey = 'hunter_quests'; // NEW: The key for our quest list
  SharedPreferences? _prefs;

  // Boots up the connection to the hard drive
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --- THE PROFILE VAULT ---
  Future<void> saveProfile(HunterProfile profile) async {
    if (_prefs == null) return;
    String jsonString = jsonEncode(profile.toJson());
    await _prefs!.setString(_profileKey, jsonString);
  }

  HunterProfile? loadProfile() {
    if (_prefs == null) return null;
    String? jsonString = _prefs!.getString(_profileKey);
    if (jsonString == null) return null;
    return HunterProfile.fromJson(jsonDecode(jsonString));
  }

  // --- THE QUEST VAULT (NEW) ---
  
  // Translates a List of Quests into a List of Text Strings and saves them
  Future<void> saveQuests(List<Quest> quests) async {
    if (_prefs == null) return;
    List<String> jsonList = quests.map((q) => jsonEncode(q.toJson())).toList();
    await _prefs!.setStringList(_questsKey, jsonList);
  }

  // Reads the Text Strings from the hard drive and translates them back into Quests
  List<Quest> loadQuests() {
    if (_prefs == null) return [];
    List<String>? jsonList = _prefs!.getStringList(_questsKey);
    
    // If there are no quests saved yet, return an empty list
    if (jsonList == null) return []; 
    
    return jsonList.map((jsonStr) => Quest.fromJson(jsonDecode(jsonStr))).toList();
  }
}
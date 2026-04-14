import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// These imports are what connect your models to the storage service!
import '../models/user_profile.dart';
import '../models/task.dart';

class StorageService {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveProfile(HunterProfile profile) async {
    final jsonString = jsonEncode(profile.toJson());
    await _prefs!.setString('hunter_profile', jsonString);
  }

  HunterProfile? loadProfile() {
    final jsonString = _prefs?.getString('hunter_profile');
    if (jsonString != null) {
      return HunterProfile.fromJson(jsonDecode(jsonString));
    }
    return null;
  }

  Future<void> saveActiveTasks(List<SystemTask> tasks) async {
    final jsonList = tasks.map((task) => task.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _prefs!.setString('active_tasks', jsonString);
  }

  List<SystemTask> loadActiveTasks() {
    final jsonString = _prefs?.getString('active_tasks');
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.map((item) => SystemTask.fromJson(item)).toList();
    }
    return [];
  }
}
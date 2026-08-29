import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class StorageHelper {
  static const String _keyLoggedIn = 'isLoggedIn';
  static const String _keyTasks = 'user_tasks_list';

  static Future<void> saveLoginState(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, value);
  }

  static Future<bool> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawTasks = tasks.map((t) => t.toJson()).toList();
    await prefs.setStringList(_keyTasks, rawTasks);
  }

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? rawTasks = prefs.getStringList(_keyTasks);
    if (rawTasks == null) return [];
    return rawTasks.map((t) => Task.fromJson(t)).toList();
  }
}
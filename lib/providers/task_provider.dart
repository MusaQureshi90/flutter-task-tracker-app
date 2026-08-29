import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/storage_helper.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = true;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get pendingCount => _tasks.where((t) => !t.isDone).length;

  TaskProvider() {
    _initTasks();
  }

  Future<void> _initTasks() async {
    _tasks = await StorageHelper.loadTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    _tasks.insert(0, newTask);
    notifyListeners();
    await StorageHelper.saveTasks(_tasks);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index].isDone = !_tasks[index].isDone;
      notifyListeners();
      await StorageHelper.saveTasks(_tasks);
    }
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
    await StorageHelper.saveTasks(_tasks);
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((task) => task.isDone);
    notifyListeners();
    await StorageHelper.saveTasks(_tasks);
  }
}
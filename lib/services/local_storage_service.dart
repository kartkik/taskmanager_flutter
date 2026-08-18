import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class LocalStorageService {
  static const String _boxName = 'tasks_box';
  Box<String>? _box;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<String>(_boxName);
      debugPrint('LocalStorageService initialized successfully');
    } catch (e) {
      debugPrint('LocalStorageService initialization error: $e');
    }
  }

  Box<String> get _safeBox {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Local storage is not initialized');
    }
    return _box!;
  }

  List<TaskModel> getAllTasks() {
    try {
      final box = _safeBox;
      final tasks = <TaskModel>[];
      for (var key in box.keys) {
        final jsonStr = box.get(key);
        if (jsonStr != null) {
          try {
            tasks.add(TaskModel.fromJson(jsonStr));
          } catch (e) {
            debugPrint('Failed to parse task $key: $e');
          }
        }
      }
      return tasks;
    } catch (e) {
      debugPrint('Error fetching tasks from local storage: $e');
      return [];
    }
  }

  TaskModel? getTask(String id) {
    try {
      final box = _safeBox;
      final jsonStr = box.get(id);
      if (jsonStr != null) {
        return TaskModel.fromJson(jsonStr);
      }
    } catch (e) {
      debugPrint('Error getting task $id from local storage: $e');
    }
    return null;
  }

  Future<void> saveTask(TaskModel task) async {
    try {
      final box = _safeBox;
      await box.put(task.id, task.toJson());
    } catch (e) {
      debugPrint('Error saving task ${task.id} to local storage: $e');
      rethrow;
    }
  }

  Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final box = _safeBox;
      final map = <String, String>{};
      for (var t in tasks) {
        map[t.id] = t.toJson();
      }
      await box.putAll(map);
    } catch (e) {
      debugPrint('Error bulk saving tasks to local storage: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      final box = _safeBox;
      await box.delete(id);
    } catch (e) {
      debugPrint('Error deleting task $id from local storage: $e');
      rethrow;
    }
  }

  Future<void> clearAll() async {
    try {
      final box = _safeBox;
      await box.clear();
    } catch (e) {
      debugPrint('Error clearing local storage: $e');
    }
  }
}

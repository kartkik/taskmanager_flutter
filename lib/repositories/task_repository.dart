import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/task_priority.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

class TaskRepository {
  final LocalStorageService localStorageService;
  final FirebaseService firebaseService;
  final ConnectivityService connectivityService;
  final SyncService syncService;
  final Uuid _uuid = const Uuid();

  TaskRepository({
    required this.localStorageService,
    required this.firebaseService,
    required this.connectivityService,
    required this.syncService,
  }) {
    // Listen for network reconnect to trigger auto-sync
    connectivityService.connectionStatusStream.listen((isOnline) {
      if (isOnline) {
        syncService.syncPendingTasks();
      }
    });
  }

  Future<List<TaskModel>> getInitialTasks() async {
    try {
      var localTasks = localStorageService.getAllTasks();

      // Seed initial tasks if completely empty for demonstration
      if (localTasks.isEmpty) {
        localTasks = _generateInitialSeedTasks();
        await localStorageService.saveTasks(localTasks);
      }

      // If online, perform background sync
      if (connectivityService.isOnline && firebaseService.isFirebaseInitialized) {
        syncService.syncPendingTasks().catchError((e) {
          debugPrint('Background sync error: $e');
        });
      }

      return localTasks;
    } catch (e) {
      debugPrint('Error getting initial tasks: $e');
      return [];
    }
  }

  Future<TaskModel> createTask({
    required String title,
    required String description,
    required TaskPriority priority,
    required DateTime dueDate,
  }) async {
    final now = DateTime.now();
    final newId = _uuid.v4();

    final isOnline = connectivityService.isOnline && firebaseService.isFirebaseInitialized;

    final newTask = TaskModel(
      id: newId,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      isSynced: isOnline,
      pendingAction: isOnline ? null : 'create',
    );

    // Save locally first (instant UI update)
    await localStorageService.saveTask(newTask);

    // Try remote sync if online
    if (isOnline) {
      try {
        await firebaseService.createTask(newTask);
      } catch (e) {
        debugPrint('Failed remote create, task flagged for offline sync: $e');
        final unsynced = newTask.copyWith(isSynced: false, pendingAction: 'create');
        await localStorageService.saveTask(unsynced);
        return unsynced;
      }
    }

    return newTask;
  }

  Future<TaskModel> updateTask(TaskModel task) async {
    final now = DateTime.now();
    final isOnline = connectivityService.isOnline && firebaseService.isFirebaseInitialized;

    final updatedTask = task.copyWith(
      updatedAt: now,
      isSynced: isOnline,
      pendingAction: isOnline ? null : 'update',
    );

    // Save locally first
    await localStorageService.saveTask(updatedTask);

    // Sync remote if online
    if (isOnline) {
      try {
        await firebaseService.updateTask(updatedTask);
      } catch (e) {
        debugPrint('Failed remote update, task flagged for offline sync: $e');
        final unsynced = updatedTask.copyWith(isSynced: false, pendingAction: 'update');
        await localStorageService.saveTask(unsynced);
        return unsynced;
      }
    }

    return updatedTask;
  }

  Future<void> deleteTask(String id) async {
    final isOnline = connectivityService.isOnline && firebaseService.isFirebaseInitialized;
    final existingTask = localStorageService.getTask(id);

    if (existingTask != null) {
      if (isOnline) {
        await localStorageService.deleteTask(id);
        try {
          await firebaseService.deleteTask(id);
        } catch (e) {
          debugPrint('Failed remote delete: $e');
        }
      } else {
        // Mark for deletion on next sync or remove locally
        final markedTask = existingTask.copyWith(
          isSynced: false,
          pendingAction: 'delete',
        );
        await localStorageService.saveTask(markedTask);
      }
    }
  }

  Future<TaskModel> toggleTaskCompletion(TaskModel task) async {
    return await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> triggerManualSync() async {
    await syncService.syncPendingTasks();
  }

  List<TaskModel> _generateInitialSeedTasks() {
    final now = DateTime.now();
    return [
      TaskModel(
        id: _uuid.v4(),
        title: 'Welcome to Task Manager',
        description: 'Create, edit, search, and manage your daily tasks offline and online with Firestore sync.',
        priority: TaskPriority.high,
        dueDate: now.add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        isSynced: true,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Test Offline Capability',
        description: 'Try creating a task when offline! It will automatically sync to Firestore when internet is restored.',
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(days: 3)),
        isCompleted: false,
        createdAt: now,
        updatedAt: now,
        isSynced: true,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Review Project Architecture',
        description: 'Clean design using Provider, Hive Local Storage, and Cloud Firestore.',
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 5)),
        isCompleted: true,
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now,
        isSynced: true,
      ),
    ];
  }
}

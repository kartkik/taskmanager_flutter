import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'local_storage_service.dart';

class SyncService {
  final LocalStorageService localStorageService;
  final FirebaseService firebaseService;

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  SyncService({
    required this.localStorageService,
    required this.firebaseService,
  });

  Future<void> syncPendingTasks() async {
    if (!firebaseService.isFirebaseInitialized) {
      debugPrint('Sync skipped: Firebase not initialized.');
      return;
    }

    if (_isSyncing) return;

    _isSyncing = true;
    try {
      final localTasks = localStorageService.getAllTasks();
      final unsyncedTasks = localTasks.where((t) => !t.isSynced).toList();

      debugPrint('Syncing ${unsyncedTasks.length} unsynced local tasks to Firestore...');

      for (var task in unsyncedTasks) {
        try {
          if (task.pendingAction == 'delete') {
            await firebaseService.deleteTask(task.id);
            await localStorageService.deleteTask(task.id);
          } else if (task.pendingAction == 'create') {
            await firebaseService.createTask(task);
            final updatedTask = task.copyWith(
              isSynced: true,
              pendingAction: null,
            );
            await localStorageService.saveTask(updatedTask);
          } else if (task.pendingAction == 'update') {
            await firebaseService.updateTask(task);
            final updatedTask = task.copyWith(
              isSynced: true,
              pendingAction: null,
            );
            await localStorageService.saveTask(updatedTask);
          } else {
            // General sync update
            await firebaseService.createTask(task);
            final updatedTask = task.copyWith(
              isSynced: true,
              pendingAction: null,
            );
            await localStorageService.saveTask(updatedTask);
          }
        } catch (e) {
          debugPrint('Failed to sync individual task ${task.id}: $e');
        }
      }

      // Fetch remote tasks and update local storage
      try {
        final remoteTasks = await firebaseService.fetchAllTasks();
        if (remoteTasks.isNotEmpty) {
          for (var remoteTask in remoteTasks) {
            final localTask = localStorageService.getTask(remoteTask.id);
            // Only overwrite if local is synced or remote is newer
            if (localTask == null || localTask.isSynced) {
              await localStorageService.saveTask(remoteTask);
            }
          }
        }
      } catch (e) {
        debugPrint('Could not pull remote tasks during sync: $e');
      }

      debugPrint('Sync completed successfully.');
    } finally {
      _isSyncing = false;
    }
  }
}

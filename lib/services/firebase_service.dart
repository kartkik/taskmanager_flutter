import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

class FirebaseService {
  static const String collectionPath = 'tasks';

  bool get isFirebaseInitialized => Firebase.apps.isNotEmpty;

  FirebaseFirestore? get _db {
    if (!isFirebaseInitialized) return null;
    return FirebaseFirestore.instance;
  }

  CollectionReference<Map<String, dynamic>>? get _tasksCollection {
    final db = _db;
    if (db == null) return null;
    return db.collection(collectionPath);
  }

  Stream<List<TaskModel>> getTasksStream() {
    final col = _tasksCollection;
    if (col == null) {
      debugPrint('Firebase not initialized. Returning empty stream.');
      return Stream.value([]);
    }

    return col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    }).handleError((error) {
      debugPrint('Error listening to Firestore tasks stream: $error');
      return <TaskModel>[];
    });
  }

  Future<List<TaskModel>> fetchAllTasks() async {
    final col = _tasksCollection;
    if (col == null) return [];

    try {
      final snapshot = await col.get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks from Firestore: $e');
      rethrow;
    }
  }

  Future<void> createTask(TaskModel task) async {
    final col = _tasksCollection;
    if (col == null) {
      debugPrint('Firebase not ready. Task saved locally only.');
      return;
    }

    try {
      await col.doc(task.id).set(task.toFirestore());
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException creating task ${task.id}: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error creating task in Firestore: $e');
      rethrow;
    }
  }

  Future<void> updateTask(TaskModel task) async {
    final col = _tasksCollection;
    if (col == null) return;

    try {
      await col.doc(task.id).update(task.toFirestore());
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException updating task ${task.id}: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error updating task in Firestore: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    final col = _tasksCollection;
    if (col == null) return;

    try {
      await col.doc(id).delete();
    } on FirebaseException catch (e) {
      debugPrint('FirebaseException deleting task $id: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Unexpected error deleting task in Firestore: $e');
      rethrow;
    }
  }
}

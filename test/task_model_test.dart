import 'package:flutter_test/flutter_test.dart';
import 'package:taskmanager/models/task_model.dart';
import 'package:taskmanager/models/task_priority.dart';

void main() {
  group('TaskModel Serialization Tests', () {
    final now = DateTime.now();

    final task = TaskModel(
      id: 'test-123',
      title: 'Complete Flutter Assignment',
      description: 'Build task manager with Firestore & Hive',
      priority: TaskPriority.high,
      dueDate: now.add(const Duration(days: 2)),
      isCompleted: false,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
      pendingAction: null,
    );

    test('toMap and fromMap conversion preserves data accurately', () {
      final map = task.toMap();
      expect(map['id'], 'test-123');
      expect(map['title'], 'Complete Flutter Assignment');
      expect(map['priority'], 'high');
      expect(map['isCompleted'], false);
      expect(map['isSynced'], true);

      final deserializedTask = TaskModel.fromMap(map);
      expect(deserializedTask.id, task.id);
      expect(deserializedTask.title, task.title);
      expect(deserializedTask.description, task.description);
      expect(deserializedTask.priority, task.priority);
      expect(deserializedTask.isCompleted, task.isCompleted);
    });

    test('toJson and fromJson string serialization works correctly', () {
      final jsonStr = task.toJson();
      final fromJsonTask = TaskModel.fromJson(jsonStr);

      expect(fromJsonTask.id, task.id);
      expect(fromJsonTask.title, task.title);
      expect(fromJsonTask.priority, task.priority);
    });

    test('copyWith produces updated instance without mutating original', () {
      final updatedTask = task.copyWith(
        isCompleted: true,
        priority: TaskPriority.low,
      );

      expect(updatedTask.id, task.id);
      expect(updatedTask.isCompleted, true);
      expect(updatedTask.priority, TaskPriority.low);
      expect(task.isCompleted, false);
      expect(task.priority, TaskPriority.high);
    });

    test('isOverdue correctly identifies overdue tasks', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final overdueTask = task.copyWith(dueDate: pastDate, isCompleted: false);
      expect(overdueTask.isOverdue, isTrue);

      final completedOverdueTask = overdueTask.copyWith(isCompleted: true);
      expect(completedOverdueTask.isOverdue, isFalse);
    });
  });
}

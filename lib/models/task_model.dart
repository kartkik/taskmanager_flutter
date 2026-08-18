import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'task_priority.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final String? pendingAction; // 'create', 'update', 'delete', or null

  const TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = true,
    this.pendingAction,
  });

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    return dueDate.isBefore(now);
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    String? pendingAction,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      pendingAction: pendingAction ?? this.pendingAction,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'pendingAction': pendingAction,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      priority: TaskPriority.fromString(map['priority']),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isSynced: map['isSynced'] ?? true,
      pendingAction: map['pendingAction'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dueDate': Timestamp.fromDate(dueDate),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    
    DateTime parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priority: TaskPriority.fromString(data['priority']),
      dueDate: parseTimestamp(data['dueDate']),
      isCompleted: data['isCompleted'] ?? false,
      createdAt: parseTimestamp(data['createdAt']),
      updatedAt: parseTimestamp(data['updatedAt']),
      isSynced: true,
      pendingAction: null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskModel.fromJson(String source) =>
      TaskModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.priority == priority &&
        other.dueDate == dueDate &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isSynced == isSynced &&
        other.pendingAction == pendingAction;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        priority.hashCode ^
        dueDate.hashCode ^
        isCompleted.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isSynced.hashCode ^
        pendingAction.hashCode;
  }
}

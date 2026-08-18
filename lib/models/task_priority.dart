import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFF10B981); // Emerald Green
      case TaskPriority.medium:
        return const Color(0xFFF59E0B); // Amber / Warm Orange
      case TaskPriority.high:
        return const Color(0xFFEF4444); // Crimson / Rose Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.low:
        return const Color(0xFFD1FAE5);
      case TaskPriority.medium:
        return const Color(0xFFFEF3C7);
      case TaskPriority.high:
        return const Color(0xFFFEE2E2);
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.remove_rounded;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up_rounded;
    }
  }

  int get rank {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }

  static TaskPriority fromString(String? value) {
    if (value == null) return TaskPriority.medium;
    switch (value.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

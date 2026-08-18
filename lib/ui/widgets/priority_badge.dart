import 'package:flutter/material.dart';
import '../../models/task_priority.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: priority.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: priority.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priority.icon,
            size: isCompact ? 12 : 14,
            color: priority.color,
          ),
          const SizedBox(width: 4),
          Text(
            priority.label,
            style: TextStyle(
              color: priority.color,
              fontSize: isCompact ? 11 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

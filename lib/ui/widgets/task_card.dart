import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../utils/date_formatter.dart';
import '../theme/app_colors.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final ValueChanged<bool?> onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = task.isOverdue;

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.priorityHigh,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        elevation: task.isCompleted ? 0 : 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: task.isCompleted,
                        onChanged: onToggleComplete,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Title & Description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: task.isCompleted
                                  ? (isThemeDark
                                      ? AppColors.darkTextMuted
                                      : AppColors.lightTextMuted)
                                  : (isThemeDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: isThemeDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // More / Edit button
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit Task',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                // Footer: Priority Badge, Due Date, Sync Status
                Row(
                  children: [
                    PriorityBadge(priority: task.priority, isCompact: true),
                    const Spacer(),
                    // Due Date
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isOverdue
                              ? AppColors.priorityHigh
                              : (isThemeDark
                                  ? AppColors.darkTextMuted
                                  : AppColors.lightTextMuted),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatTaskDate(task.dueDate),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isOverdue
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isOverdue
                                ? AppColors.priorityHigh
                                : (isThemeDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    // Sync icon
                    Tooltip(
                      message: task.isSynced ? 'Synced to Cloud' : 'Stored Locally (Pending Sync)',
                      child: Icon(
                        task.isSynced
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_off_rounded,
                        size: 16,
                        color: task.isSynced
                            ? AppColors.accent
                            : AppColors.syncWarning,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

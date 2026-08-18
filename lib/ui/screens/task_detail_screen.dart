import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/date_formatter.dart';
import '../theme/app_colors.dart';
import '../widgets/priority_badge.dart';
import 'add_edit_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final taskList = provider.tasks;
    final taskIndex = taskList.indexWhere((t) => t.id == taskId);

    final isThemeDark = Theme.of(context).brightness == Brightness.dark;

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task Details')),
        body: const Center(child: Text('Task not found or was deleted.')),
      );
    }

    final task = taskList[taskIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Task',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(task: task),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete Task',
            onPressed: () async {
              final confirm = await showDialog<bool>(
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

              if (confirm == true && context.mounted) {
                await provider.deleteTask(task.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner / Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? AppColors.accent.withOpacity(0.12)
                    : (isThemeDark ? AppColors.darkSurface : AppColors.lightSurface),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: task.isCompleted
                      ? AppColors.accent
                      : (isThemeDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: task.isCompleted ? AppColors.accent : AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.isCompleted ? 'Status: Completed' : 'Status: Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: task.isCompleted ? AppColors.accent : null,
                          ),
                        ),
                        Text(
                          task.isCompleted
                              ? 'This task has been completed.'
                              : 'Tap to mark task as completed.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isThemeDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: task.isCompleted,
                    onChanged: (_) {
                      provider.toggleTaskCompletion(task);
                    },
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              task.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),

            const SizedBox(height: 14),

            // Metadata Chips Row (Priority, Sync Status)
            Row(
              children: [
                PriorityBadge(priority: task.priority),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: (task.isSynced ? AppColors.accent : AppColors.syncWarning)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (task.isSynced ? AppColors.accent : AppColors.syncWarning)
                          .withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        task.isSynced
                            ? Icons.cloud_done_rounded
                            : Icons.cloud_off_rounded,
                        size: 14,
                        color: task.isSynced
                            ? AppColors.accent
                            : AppColors.syncWarning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.isSynced ? 'Cloud Synced' : 'Local Only',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: task.isSynced
                              ? AppColors.accent
                              : AppColors.syncWarning,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Description Section
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isThemeDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description.isNotEmpty
                  ? task.description
                  : 'No detailed description provided for this task.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: task.description.isNotEmpty
                    ? (isThemeDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)
                    : AppColors.lightTextMuted,
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Dates & Metadata Info List
            _buildInfoRow(
              context,
              icon: Icons.event_rounded,
              title: 'Due Date',
              value: DateFormatter.formatTaskDate(task.dueDate),
              isAlert: task.isOverdue,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.history_rounded,
              title: 'Created Date',
              value: DateFormatter.formatTaskDate(task.createdAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.update_rounded,
              title: 'Last Updated',
              value: DateFormatter.formatTaskDate(task.updatedAt),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.fingerprint_rounded,
              title: 'Task ID',
              value: task.id,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isAlert = false,
  }) {
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isAlert
              ? AppColors.priorityHigh
              : (isThemeDark
                  ? AppColors.darkTextMuted
                  : AppColors.lightTextMuted),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isThemeDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const Spacer(),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isAlert ? FontWeight.bold : FontWeight.w500,
              color: isAlert
                  ? AppColors.priorityHigh
                  : (isThemeDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

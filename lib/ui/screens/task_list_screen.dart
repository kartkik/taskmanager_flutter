import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_filter.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/empty_task_state.dart';
import '../widgets/filter_bar.dart';
import '../widgets/sync_banner.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 28),
            SizedBox(width: 10),
            Text(
              'Task Manager',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Manual Sync Action Button
          Consumer<TaskProvider>(
            builder: (context, provider, _) => IconButton(
              icon: provider.isSyncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded),
              tooltip: 'Sync Now',
              onPressed: provider.isSyncing ? null : () => provider.syncManual(),
            ),
          ),
          // Theme Toggle Action
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) => IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              tooltip: 'Toggle Theme',
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
          // Settings Action
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncBanner(),
          const FilterBar(),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (provider.errorMessage != null && provider.tasks.isEmpty) {
                  return EmptyTaskState(
                    title: 'Something Went Wrong',
                    message: provider.errorMessage!,
                    icon: Icons.error_outline_rounded,
                    actionLabel: 'Retry',
                    onActionPressed: () => provider.loadTasks(),
                  );
                }

                final tasks = provider.tasks;

                if (tasks.isEmpty) {
                  final isSearching = provider.searchQuery.isNotEmpty;
                  final isFilterPending =
                      provider.filterStatus == TaskFilterStatus.pending;
                  final isFilterCompleted =
                      provider.filterStatus == TaskFilterStatus.completed;

                  String title = 'No tasks found';
                  String message = 'Tap the + button below to create your first task!';
                  IconData icon = Icons.task_alt_rounded;

                  if (isSearching) {
                    title = 'No Matching Tasks';
                    message = 'No tasks match "${provider.searchQuery}". Try a different keyword.';
                    icon = Icons.search_off_rounded;
                  } else if (isFilterPending) {
                    title = 'All Caught Up!';
                    message = 'You have no pending tasks right now. Great job!';
                    icon = Icons.verified_rounded;
                  } else if (isFilterCompleted) {
                    title = 'No Completed Tasks';
                    message = 'Complete tasks to see them listed here.';
                    icon = Icons.checklist_rounded;
                  }

                  return EmptyTaskState(
                    title: title,
                    message: message,
                    icon: icon,
                    actionLabel: isSearching ? 'Clear Search' : 'Add New Task',
                    onActionPressed: () {
                      if (isSearching) {
                        provider.clearSearch();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddEditTaskScreen(),
                          ),
                        );
                      }
                    },
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.syncManual(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TaskDetailScreen(taskId: task.id),
                            ),
                          );
                        },
                        onToggleComplete: (_) {
                          provider.toggleTaskCompletion(task);
                        },
                        onDelete: () {
                          provider.deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Deleted "${task.title}"'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(task: task),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

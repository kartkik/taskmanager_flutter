import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final taskProvider = context.watch<TaskProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Section
          _buildSectionHeader(context, 'Appearance'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme Mode',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('System'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {themeProvider.themeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      themeProvider.setThemeMode(newSelection.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Connectivity & Sync Info
          _buildSectionHeader(context, 'Sync & Cloud Connection'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      taskProvider.isOnline
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      color: taskProvider.isOnline
                          ? AppColors.accent
                          : AppColors.syncOffline,
                    ),
                    title: const Text('Network Status'),
                    subtitle: Text(
                      taskProvider.isOnline ? 'Online (Connected)' : 'Offline (Local Storage Mode)',
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      taskProvider.unsyncedCount == 0
                          ? Icons.cloud_done_rounded
                          : Icons.cloud_upload_outlined,
                      color: taskProvider.unsyncedCount == 0
                          ? AppColors.accent
                          : AppColors.syncWarning,
                    ),
                    title: const Text('Sync Status'),
                    subtitle: Text(
                      taskProvider.unsyncedCount == 0
                          ? 'All local tasks are synced with Firestore'
                          : '${taskProvider.unsyncedCount} tasks waiting to sync',
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: taskProvider.isSyncing
                          ? null
                          : () => taskProvider.syncManual(),
                      icon: taskProvider.isSyncing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync_rounded),
                      label: Text(
                        taskProvider.isSyncing
                            ? 'Syncing...'
                            : 'Trigger Manual Sync',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Statistics Overview
          _buildSectionHeader(context, 'Task Statistics'),
          Row(
            children: [
              _buildStatCard(
                context,
                title: 'Total',
                count: taskProvider.totalTasksCount.toString(),
                color: AppColors.primary,
                icon: Icons.assignment_rounded,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                context,
                title: 'Pending',
                count: taskProvider.pendingTasksCount.toString(),
                color: AppColors.priorityMedium,
                icon: Icons.hourglass_empty_rounded,
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                context,
                title: 'Completed',
                count: taskProvider.completedTasksCount.toString(),
                color: AppColors.accent,
                icon: Icons.check_circle_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isThemeDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

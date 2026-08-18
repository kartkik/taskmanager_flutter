import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../theme/app_colors.dart';

class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, _) {
        final isOnline = provider.isOnline;
        final isSyncing = provider.isSyncing;
        final unsyncedCount = provider.unsyncedCount;

        if (isOnline && unsyncedCount == 0 && !isSyncing) {
          return const SizedBox.shrink(); // All synchronized clean state
        }

        Color bgColor;
        IconData iconData;
        String statusText;

        if (!isOnline) {
          bgColor = AppColors.syncOffline;
          iconData = Icons.wifi_off_rounded;
          statusText = unsyncedCount > 0
              ? 'Offline Mode • $unsyncedCount changes saved locally'
              : 'Offline Mode • Working from local storage';
        } else if (isSyncing) {
          bgColor = AppColors.primary;
          iconData = Icons.sync_rounded;
          statusText = 'Synchronizing with Firestore...';
        } else {
          bgColor = AppColors.syncWarning;
          iconData = Icons.cloud_upload_outlined;
          statusText = '$unsyncedCount unsynced changes ready to sync';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: bgColor,
          child: Row(
            children: [
              if (isSyncing)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                Icon(iconData, size: 18, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isOnline && unsyncedCount > 0 && !isSyncing)
                InkWell(
                  onTap: () => provider.syncManual(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Sync Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyTaskState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onActionPressed;
  final String? actionLabel;

  const EmptyTaskState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.task_alt_rounded,
    this.onActionPressed,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isThemeDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isThemeDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isThemeDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onActionPressed,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

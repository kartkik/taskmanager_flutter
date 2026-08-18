import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTaskDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat('h:mm a').format(date);

    if (targetDate == today) {
      return 'Today at $timeStr';
    } else if (targetDate == tomorrow) {
      return 'Tomorrow at $timeStr';
    } else if (targetDate.isBefore(today)) {
      final diff = today.difference(targetDate).inDays;
      if (diff == 1) {
        return 'Yesterday at $timeStr';
      }
      return '${DateFormat('MMM d, y').format(date)} (Overdue)';
    } else {
      return DateFormat('MMM d, y • h:mm a').format(date);
    }
  }

  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}

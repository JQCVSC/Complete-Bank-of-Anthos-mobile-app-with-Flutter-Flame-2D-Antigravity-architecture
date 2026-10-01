import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _shortDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _dateTime = DateFormat('MMM dd, yyyy • hh:mm a');
  static final DateFormat _timeOnly = DateFormat('hh:mm a');

  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return _shortDate.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return _dateTime.format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return _timeOnly.format(date);
  }

  static String formatRelativeOrDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes <= 1) {
          return 'Just now';
        }
        return '${difference.inMinutes} mins ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    }
    return _shortDate.format(date);
  }
}

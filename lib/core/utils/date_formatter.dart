import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dateFormat = DateFormat('dd MMM yyyy');
  static final _dateTimeFormat = DateFormat('dd MMM yyyy, HH:mm');
  static final _timeFormat = DateFormat('HH:mm');

  static String date(DateTime dt) => _dateFormat.format(dt.toLocal());
  static String dateTime(DateTime dt) => _dateTimeFormat.format(dt.toLocal());
  static String time(DateTime dt) => _timeFormat.format(dt.toLocal());

  static String relative(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return date(dt);
  }
}

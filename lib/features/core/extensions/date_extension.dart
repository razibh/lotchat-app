import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  // Format date
  String format({String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(this);
  }

  // Format time
  String formatTime({bool withSeconds = false}) {
    final String pattern = withSeconds ? 'HH:mm:ss' : 'HH:mm';
    return DateFormat(pattern).format(this);
  }

  // Format date and time
  String formatDateTime({String pattern = 'dd/MM/yyyy HH:mm'}) {
    return DateFormat(pattern).format(this);
  }

  // Get time ago
  String get timeAgo {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get day name
  String get dayName {
    return DateFormat('EEEE').format(this);
  }

  // Get month name
  String get monthName {
    return DateFormat('MMMM').format(this);
  }

  // Is today
  bool get isToday {
    final DateTime now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Is yesterday
  bool get isYesterday {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  // Is tomorrow
  bool get isTomorrow {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  // Is same day as another date
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Is weekend
  bool get isWeekend {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  // Is weekday
  bool get isWeekday => !isWeekend;

  // Start of day
  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  // End of day
  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  // Start of week (Monday)
  DateTime get startOfWeek {
    return subtract(Duration(days: weekday - 1)).startOfDay;
  }

  // End of week (Sunday)
  DateTime get endOfWeek {
    return add(Duration(days: 7 - weekday)).endOfDay;
  }

  // Start of month
  DateTime get startOfMonth {
    return DateTime(year, month);
  }

  // End of month
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0).endOfDay;
  }

  // Start of year
  DateTime get startOfYear {
    return DateTime(year);
  }

  // End of year
  DateTime get endOfYear {
    return DateTime(year, 12, 31).endOfDay;
  }

  // Add business days (skip weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int remaining = days;
    while (remaining > 0) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) remaining--;
    }
    return result;
  }

  // Days difference
  int daysUntil(DateTime other) {
    return other.difference(this).inDays;
  }

  // Hours difference
  int hoursUntil(DateTime other) {
    return other.difference(this).inHours;
  }

  // Minutes difference
  int minutesUntil(DateTime other) {
    return other.difference(this).inMinutes;
  }

  // Age calculation
  int get age {
    final DateTime now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  // Get date range
  List<DateTime> get daysInMonth {
    final List<DateTime> days = <DateTime>[];
    for (var i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(year, month, i));
    }
    return days;
  }

  // Get quarter
  int get quarter {
    return ((month - 1) / 3).floor() + 1;
  }

  // Get week number
  int get weekNumber {
    final DateTime firstDayOfYear = DateTime(year);
    final int daysPassed = difference(firstDayOfYear).inDays;
    return ((daysPassed + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  // Check if between dates
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }

  // Get nearest future date
  DateTime nearestFuture() {
    final DateTime now = DateTime.now();
    return isAfter(now) ? this : now;
  }

  // Get nearest past date
  DateTime nearestPast() {
    final DateTime now = DateTime.now();
    return isBefore(now) ? this : now;
  }

  // Format for API
  String toApiString() {
    return toIso8601String();
  }

  // Format for display
  String toDisplayString() {
    if (isToday) return 'Today, ${formatTime()}';
    if (isYesterday) return 'Yesterday, ${formatTime()}';
    if (year == DateTime.now().year) {
      return format(pattern: 'dd MMM, HH:mm');
    }
    return format(pattern: 'dd MMM yyyy, HH:mm');
  }

  // Format for chat
  String toChatString() {
    if (isToday) return formatTime();
    if (isYesterday) return 'Yesterday';
    if (year == DateTime.now().year) {
      return format(pattern: 'dd MMM');
    }
    return format(pattern: 'dd/MM/yy');
  }
}
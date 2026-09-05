import 'package:intl/intl.dart';

/// Extension methods for DateTime
/// All UTC-based operations
extension DateTimeExt on DateTime {
  /// Returns this date at midnight UTC
  DateTime toDateOnlyUtc() {
    return DateTime.utc(year, month, day);
  }

  /// Returns true if this date is today in UTC
  bool get isTodayUtc {
    final now = DateTime.now().toUtc();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is tomorrow in UTC
  bool get isTomorrowUtc {
    final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Returns true if this date is yesterday in UTC
  bool get isYesterdayUtc {
    final yesterday = DateTime.now().toUtc().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Returns true if this date is overdue (before now UTC)
  bool get isOverdueUtc {
    return isBefore(DateTime.now().toUtc());
  }

  /// Returns true if this date is in the future (after now UTC)
  bool get isInFutureUtc {
    return isAfter(DateTime.now().toUtc());
  }

  /// Returns a formatted string for display (local time)
  String formatForDisplay({String? pattern}) {
    return DateFormat(pattern ?? 'yyyy-MM-dd – HH:mm').format(toLocal());
  }

  /// Returns a formatted date string (local time)
  String formatDateForDisplay() {
    return DateFormat('yyyy-MM-dd').format(toLocal());
  }

  /// Returns a formatted time string (local time)
  String formatTimeForDisplay() {
    return DateFormat('HH:mm').format(toLocal());
  }

  /// Returns a relative date string for display
  String get relativeDateString {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    final dateOnly = toDateOnlyUtc();

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else if (dateOnly.isAfter(today) && dateOnly.isBefore(today.add(const Duration(days: 7)))) {
      return DateFormat('EEEE').format(toLocal());
    } else {
      return DateFormat('MMM dd, yyyy').format(toLocal());
    }
  }

  /// Returns milliseconds since epoch in UTC
  int get millisSinceEpochUtc {
    return toUtc().millisecondsSinceEpoch;
  }

  /// Creates a DateTime from milliseconds since epoch in UTC
  static DateTime fromMillisSinceEpochUtc(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }
}

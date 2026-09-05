/// Pure Dart утилиты для дат. Без Flutter зависимостей.
class AppDateUtils {
  AppDateUtils._();

  /// Текущее время в UTC
  static DateTime nowUtc() => DateTime.now().toUtc();

  /// Возвращает дату без времени в UTC
  static DateTime dateOnlyUtc(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Создаёт DateTime из миллисекунд в UTC
  static DateTime fromMillisUtc(int millis) {
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  /// Преобразует DateTime в миллисекунды UTC
  static int toMillisUtc(DateTime date) {
    return date.toUtc().millisecondsSinceEpoch;
  }

  /// Проверяет, что две даты — один и тот же день в UTC
  static bool isSameDayUtc(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Проверяет, что дата — сегодня в UTC
  static bool isTodayUtc(DateTime? date) {
    return isSameDayUtc(date, dateOnlyUtc(nowUtc()));
  }

  /// Проверяет, что дата — завтра в UTC
  static bool isTomorrowUtc(DateTime? date) {
    final tomorrow = dateOnlyUtc(nowUtc()).add(const Duration(days: 1));
    return isSameDayUtc(date, tomorrow);
  }

  /// Проверяет, что дата — вчера в UTC
  static bool isYesterdayUtc(DateTime? date) {
    final yesterday = dateOnlyUtc(nowUtc()).subtract(const Duration(days: 1));
    return isSameDayUtc(date, yesterday);
  }

  /// Проверяет, что дата просрочена (до текущего момента UTC)
  static bool isOverdueUtc(DateTime? date) {
    if (date == null) return false;
    return date.isBefore(nowUtc());
  }
}

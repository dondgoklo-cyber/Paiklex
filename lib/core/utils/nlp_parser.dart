/// Результат парсинга естественного языка
class NlpParseResult {
  final String content;
  final DateTime? dueDate; // ВСЕГДА UTC!
  final List<String> tags;
  final int? priority; // 1-4
  final String? recurrence; // "daily", "weekly", "monthly"

  const NlpParseResult({
    required this.content,
    this.dueDate,
    this.tags = const [],
    this.priority,
    this.recurrence,
  });
}

/// Парсер естественного языка (RU + EN)
/// Pure Dart — без Flutter зависимостей
class NlpParser {
  NlpParser._();

  static final _tagRegex = RegExp(r'#(\w+)');
  static final _priorityRegex = RegExp(r'\bp([1-4])\b', caseSensitive: false);
  static final _timeRegex = RegExp(r'\b(?:v\s+)?(\d{1,2})[:.](\d{2})\b');

  /// Парсит строку на естественном языке
  static NlpParseResult parse(String input, {String locale = 'ru'}) {
    final now = DateTime.now(); // Локальное время пользователя
    var text = input;
    final tags = <String>[];
    int? priority;
    String? recurrence;

    // 1. Теги
    for (final match in _tagRegex.allMatches(text)) {
      tags.add(match.group(1)!);
    }
    text = text.replaceAll(_tagRegex, ' ');

    // 2. Приоритет
    final pMatch = _priorityRegex.firstMatch(text);
    if (pMatch != null) {
      priority = int.parse(pMatch.group(1)!);
      text = text.replaceFirst(_priorityRegex, ' ');
    }

    // 3. Recurrence
    final recResult = _parseRecurrence(text, locale);
    if (recResult != null) {
      recurrence = recResult.type;
      text = recResult.remainingText;
    }

    // 4. Время
    int? hour;
    int? minute;
    final timeMatch = _timeRegex.firstMatch(text);
    if (timeMatch != null) {
      hour = int.parse(timeMatch.group(1)!);
      minute = int.parse(timeMatch.group(2)!);
      text = text.replaceFirst(_timeRegex, ' ');
    }

    // 5. Относительная дата
    final dateResult = _parseRelativeDate(text, now, locale);
    DateTime? dueDate = dateResult.date;
    if (dateResult.matchedText != null) {
      text = text.replaceFirst(
        RegExp(RegExp.escape(dateResult.matchedText!), caseSensitive: false),
        ' ',
      );
    }

    // 6. Применяем время
    if (dueDate != null && hour != null) {
      // Создаём в ЛОКАЛЬНОМ времени пользователя
      final localDate = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        hour,
        minute ?? 0,
      );
      dueDate = localDate.toUtc();
    } else if (dueDate == null && hour != null) {
      final todayLocal = DateTime(now.year, now.month, now.day);
      var candidate = DateTime(
        todayLocal.year,
        todayLocal.month,
        todayLocal.day,
        hour,
        minute ?? 0,
      );
      if (candidate.isBefore(now)) {
        candidate = candidate.add(const Duration(days: 1));
      }
      dueDate = candidate.toUtc();
    } else if (dueDate != null) {
      // Без времени -> полночь UTC
      dueDate = DateTime.utc(dueDate.year, dueDate.month, dueDate.day);
    }

    return NlpParseResult(
      content: text.replaceAll(RegExp(r'\s+'), ' ').trim(),
      dueDate: dueDate,
      tags: tags,
      priority: priority,
      recurrence: recurrence,
    );
  }

  static _DateParseResult _parseRelativeDate(
    String text,
    DateTime base,
    String locale,
  ) {
    final lower = text.toLowerCase();
    final isRu = locale == 'ru';
    final today = DateTime(base.year, base.month, base.day);

    // Сегодня/завтра/послезавтра
    final todayWords = isRu ? ['сегодня'] : ['today'];
    final tomorrowWords = isRu ? ['завтра'] : ['tomorrow', 'tmr'];
    final dayAfterWords = isRu ? ['послезавтра'] : ['day after tomorrow'];

    for (final w in todayWords) {
      if (lower.contains(w)) return _DateParseResult(today, w);
    }
    for (final w in tomorrowWords) {
      if (lower.contains(w)) {
        return _DateParseResult(today.add(const Duration(days: 1)), w);
      }
    }
    for (final w in dayAfterWords) {
      if (lower.contains(w)) {
        return _DateParseResult(today.add(const Duration(days: 2)), w);
      }
    }

    // Дни недели
    final weekdays = isRu
        ? {
            'пн': 1,
            'вт': 2,
            'ср': 3,
            'чт': 4,
            'пт': 5,
            'сб': 6,
            'вс': 7,
          }
        : {
            'mon': 1,
            'tue': 2,
            'wed': 3,
            'thu': 4,
            'fri': 5,
            'sat': 6,
            'sun': 7,
          };

    for (final entry in weekdays.entries) {
      if (lower.contains(entry.key)) {
        final target = entry.value;
        var daysToAdd = target - base.weekday;
        if (daysToAdd <= 0) daysToAdd += 7;
        return _DateParseResult(
          today.add(Duration(days: daysToAdd)),
          entry.key,
        );
      }
    }

    // "через N дней" / "in N days"
    final inDaysRegex = isRu
        ? RegExp(r'через\s+(\d+)\s+(дн(?:ей|ь|я|)?)')
        : RegExp(r'in\s+(\d+)\s+days?');
    final match = inDaysRegex.firstMatch(lower);
    if (match != null) {
      final days = int.parse(match.group(1)!);
      return _DateParseResult(
        today.add(Duration(days: days)),
        match.group(0)!,
      );
    }

    return const _DateParseResult(null, null);
  }

  static _RecurrenceParseResult? _parseRecurrence(String text, String locale) {
    final isRu = locale == 'ru';
    final patterns = isRu
        ? {
            r'\bкаждый\s+день\b': 'daily',
            r'\bкаждую\s+неделю\b': 'weekly',
            r'\bкаждый\s+месяц\b': 'monthly',
          }
        : {
            r'\bevery\s+day\b': 'daily',
            r'\bevery\s+week\b': 'weekly',
            r'\bevery\s+month\b': 'monthly',
          };

    for (final entry in patterns.entries) {
      final regex = RegExp(entry.key, caseSensitive: false);
      if (regex.hasMatch(text)) {
        return _RecurrenceParseResult(
          entry.value,
          text.replaceFirst(regex, ' '),
        );
      }
    }
    return null;
  }
}

class _DateParseResult {
  final DateTime? date;
  final String? matchedText;

  const _DateParseResult(this.date, this.matchedText);
}

class _RecurrenceParseResult {
  final String type;
  final String remainingText;

  const _RecurrenceParseResult(this.type, this.remainingText);
}

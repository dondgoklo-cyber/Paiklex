import 'package:flutter_test/flutter_test.dart';
import 'package:monolith_tasks/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('nowUtc', () {
      test('should return current UTC time', () {
        final before = DateTime.now().toUtc();
        final result = AppDateUtils.nowUtc();
        final after = DateTime.now().toUtc();

        expect(result.isUtc, true);
        expect(result.millisecondsSinceEpoch >= before.millisecondsSinceEpoch, true);
        expect(result.millisecondsSinceEpoch <= after.millisecondsSinceEpoch, true);
      });
    });

    group('dateOnlyUtc', () {
      test('should return only date part in UTC', () {
        final dateTime = DateTime(2024, 6, 15, 10, 30, 45).toUtc();
        final result = AppDateUtils.dateOnlyUtc(dateTime);

        expect(result.year, 2024);
        expect(result.month, 6);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.millisecond, 0);
        expect(result.isUtc, true);
      });

      test('should handle midnight correctly', () {
        final dateTime = DateTime(2024, 6, 15, 0, 0, 0, 0, 0).toUtc();
        final result = AppDateUtils.dateOnlyUtc(dateTime);

        expect(result, equals(dateTime));
      });
    });

    group('fromMillisUtc', () {
      test('should convert milliseconds since epoch to UTC DateTime', () {
        final millis = 1718448000000; // 2024-06-15 00:00:00 UTC
        final result = AppDateUtils.fromMillisUtc(millis);

        expect(result.year, 2024);
        expect(result.month, 6);
        expect(result.day, 15);
        expect(result.hour, 0);
        expect(result.minute, 0);
        expect(result.second, 0);
        expect(result.isUtc, true);
      });

      test('should handle zero milliseconds', () {
        final result = AppDateUtils.fromMillisUtc(0);

        expect(result.year, 1970);
        expect(result.month, 1);
        expect(result.day, 1);
        expect(result.isUtc, true);
      });
    });

    group('toMillisUtc', () {
      test('should convert UTC DateTime to milliseconds since epoch', () {
        final dateTime = DateTime(2024, 6, 15, 0, 0, 0).toUtc();
        final result = AppDateUtils.toMillisUtc(dateTime);

        expect(result, 1718448000000);
      });

      test('should handle epoch', () {
        final dateTime = DateTime(1970, 1, 1, 0, 0, 0).toUtc();
        final result = AppDateUtils.toMillisUtc(dateTime);

        expect(result, 0);
      });
    });

    group('isSameDayUtc', () {
      test('should return true for same day in UTC', () {
        final date1 = DateTime(2024, 6, 15, 10, 0, 0).toUtc();
        final date2 = DateTime(2024, 6, 15, 20, 0, 0).toUtc();

        expect(AppDateUtils.isSameDayUtc(date1, date2), true);
      });

      test('should return false for different days in UTC', () {
        final date1 = DateTime(2024, 6, 15, 23, 59, 59).toUtc();
        final date2 = DateTime(2024, 6, 16, 0, 0, 0).toUtc();

        expect(AppDateUtils.isSameDayUtc(date1, date2), false);
      });

      test('should return true for same date with different times', () {
        final date1 = DateTime(2024, 6, 15, 0, 0, 0).toUtc();
        final date2 = DateTime(2024, 6, 15, 23, 59, 59).toUtc();

        expect(AppDateUtils.isSameDayUtc(date1, date2), true);
      });
    });

    group('isTodayUtc', () {
      test('should return true for today in UTC', () {
        final today = AppDateUtils.nowUtc();
        final result = AppDateUtils.isTodayUtc(today);

        expect(result, true);
      });

      test('should return false for yesterday in UTC', () {
        final yesterday = AppDateUtils.nowUtc().subtract(const Duration(days: 1));
        final result = AppDateUtils.isTodayUtc(yesterday);

        expect(result, false);
      });

      test('should return false for tomorrow in UTC', () {
        final tomorrow = AppDateUtils.nowUtc().add(const Duration(days: 1));
        final result = AppDateUtils.isTodayUtc(tomorrow);

        expect(result, false);
      });
    });

    group('isTomorrowUtc', () {
      test('should return true for tomorrow in UTC', () {
        final tomorrow = AppDateUtils.dateOnlyUtc(
          AppDateUtils.nowUtc().add(const Duration(days: 1)),
        );
        final result = AppDateUtils.isTomorrowUtc(tomorrow);

        expect(result, true);
      });

      test('should return false for today in UTC', () {
        final today = AppDateUtils.nowUtc();
        final result = AppDateUtils.isTomorrowUtc(today);

        expect(result, false);
      });

      test('should return false for day after tomorrow in UTC', () {
        final dayAfterTomorrow = AppDateUtils.nowUtc().add(const Duration(days: 2));
        final result = AppDateUtils.isTomorrowUtc(dayAfterTomorrow);

        expect(result, false);
      });
    });

    group('isYesterdayUtc', () {
      test('should return true for yesterday in UTC', () {
        final yesterday = AppDateUtils.dateOnlyUtc(
          AppDateUtils.nowUtc().subtract(const Duration(days: 1)),
        );
        final result = AppDateUtils.isYesterdayUtc(yesterday);

        expect(result, true);
      });

      test('should return false for today in UTC', () {
        final today = AppDateUtils.nowUtc();
        final result = AppDateUtils.isYesterdayUtc(today);

        expect(result, false);
      });

      test('should return false for day before yesterday in UTC', () {
        final dayBeforeYesterday = AppDateUtils.nowUtc().subtract(const Duration(days: 2));
        final result = AppDateUtils.isYesterdayUtc(dayBeforeYesterday);

        expect(result, false);
      });
    });

    group('isOverdueUtc', () {
      test('should return true for past date in UTC', () {
        final pastDate = AppDateUtils.nowUtc().subtract(const Duration(days: 1));
        final result = AppDateUtils.isOverdueUtc(pastDate);

        expect(result, true);
      });

      test('should return false for today in UTC', () {
        final today = AppDateUtils.nowUtc();
        final result = AppDateUtils.isOverdueUtc(today);

        expect(result, false);
      });

      test('should return false for future date in UTC', () {
        final futureDate = AppDateUtils.nowUtc().add(const Duration(days: 1));
        final result = AppDateUtils.isOverdueUtc(futureDate);

        expect(result, false);
      });

      test('should return false for exact current time in UTC', () {
        final now = AppDateUtils.nowUtc();
        final result = AppDateUtils.isOverdueUtc(now);

        expect(result, false);
      });
    });
  });
}

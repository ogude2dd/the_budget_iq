// Represents a selectable date range option in the history screen.
// Each option knows how to compute its start and end dates from "now"
// so the UI doesn't have to do that math itself.
enum DateRangeOption {
  thisMonth,    // default — matches existing behavior
  thisWeek,
  lastWeek,
  last30Days,
  last90Days,
  last6Months,
  lastYear,
}

// CHANGED: New enum describing what each bar in the chart represents,
// so the chart widget knows how to label and bucket data.
enum BarBucket { day, week, month }

// CHANGED: A single bar's data — its bucket start, end, label, and total.
class ChartBar {
  final DateTime start;
  final DateTime end; // exclusive
  final String label;
  final double total;

  ChartBar({
    required this.start,
    required this.end,
    required this.label,
    required this.total,
  });
}

extension DateRangeOptionExtension on DateRangeOption {
  String get label {
    switch (this) {
      case DateRangeOption.thisMonth:
        return 'This month';
      case DateRangeOption.thisWeek:
        return 'This week';
      case DateRangeOption.lastWeek:
        return 'Last week';
      case DateRangeOption.last30Days:
        return 'Last 30 days';
      case DateRangeOption.last90Days:
        return 'Last 90 days';
      case DateRangeOption.last6Months:
        return 'Last 6 months';
      case DateRangeOption.lastYear:
        return 'Last year';
    }
  }

  ({DateTime start, DateTime end}) range(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    switch (this) {
      case DateRangeOption.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start: start, end: end);
      case DateRangeOption.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final nextMonday = monday.add(const Duration(days: 7));
        return (start: monday, end: nextMonday);
      case DateRangeOption.lastWeek:
        final thisMonday = today.subtract(Duration(days: today.weekday - 1));
        final lastMonday = thisMonday.subtract(const Duration(days: 7));
        return (start: lastMonday, end: thisMonday);
      case DateRangeOption.last30Days:
        final start = today.subtract(const Duration(days: 29));
        final end = today.add(const Duration(days: 1));
        return (start: start, end: end);
      case DateRangeOption.last90Days:
        final start = today.subtract(const Duration(days: 89));
        final end = today.add(const Duration(days: 1));
        return (start: start, end: end);
      case DateRangeOption.last6Months:
        final start = DateTime(now.year, now.month - 5, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start: start, end: end);
      case DateRangeOption.lastYear:
        final start = DateTime(now.year, now.month - 11, 1);
        final end = DateTime(now.year, now.month + 1, 1);
        return (start: start, end: end);
    }
  }

  // CHANGED: Replaces the old `showsMonthlyChart` flag.
  // Returns what kind of bars the chart should show for this range.
  BarBucket get bucketType {
    switch (this) {
      case DateRangeOption.thisWeek:
      case DateRangeOption.lastWeek:
        return BarBucket.day;
      case DateRangeOption.last30Days:
      case DateRangeOption.last90Days:
        return BarBucket.week;
      case DateRangeOption.thisMonth:
      case DateRangeOption.last6Months:
      case DateRangeOption.lastYear:
        return BarBucket.month;
    }
  }

  // CHANGED: Whether tapping bars in the chart should switch the
  // selected month. Only true for views that show months as bars.
  // For day-bucket and week-bucket views, bars are info-only.
  bool get barsAreTappable {
    switch (this) {
      case DateRangeOption.thisMonth:
      case DateRangeOption.last6Months:
      case DateRangeOption.lastYear:
        return true;
      case DateRangeOption.thisWeek:
      case DateRangeOption.lastWeek:
      case DateRangeOption.last30Days:
      case DateRangeOption.last90Days:
        return false;
    }
  }

  // CHANGED: Build the chart bars for this range.
  // Returns an empty list for ranges where the chart should be hidden,
  // but the way we have things set up now, every range has bars.
  List<ChartBar> buildBars(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);

    switch (bucketType) {
      case BarBucket.day:
        return _buildDayBars(today);
      case BarBucket.week:
        return _buildWeekBars(today);
      case BarBucket.month:
        return _buildMonthBars(now);
    }
  }

  // 7 daily bars for "This week" / "Last week".
  List<ChartBar> _buildDayBars(DateTime today) {
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final r = range(today);
    return List.generate(7, (i) {
      final start = r.start.add(Duration(days: i));
      final end = start.add(const Duration(days: 1));
      return ChartBar(
        start: start,
        end: end,
        label: dayLetters[i],
        total: 0, // filled in by the screen with actual expenses
      );
    });
  }

  // Weekly bars for "Last 30 days" (5 weeks) and "Last 90 days" (~13 weeks).
  // Each bar covers 7 days, working backwards from today.
  List<ChartBar> _buildWeekBars(DateTime today) {
    final r = range(today);
    final totalDays = r.end.difference(r.start).inDays;
    final weekCount = (totalDays / 7).ceil();
    final bars = <ChartBar>[];

    for (int i = 0; i < weekCount; i++) {
      final start = r.start.add(Duration(days: i * 7));
      final end = start.add(const Duration(days: 7));
      // Clip to the range end so the last week doesn't extend past today.
      final clippedEnd = end.isAfter(r.end) ? r.end : end;
      bars.add(ChartBar(
        start: start,
        end: clippedEnd,
        // Label like "W1", "W2"... shorter than "Week 1".
        label: 'W${i + 1}',
        total: 0,
      ));
    }
    return bars;
  }

  // Monthly bars. For "This month" we still show the trailing 12-month
  // context so users can pick a different month. For "Last 6 months"
  // we show 6 bars, "Last year" shows 12.
  List<ChartBar> _buildMonthBars(DateTime now) {
    const monthLetters = [
      'J', 'F', 'M', 'A', 'M', 'J',
      'J', 'A', 'S', 'O', 'N', 'D',
    ];
    int count;
    switch (this) {
      case DateRangeOption.thisMonth:
      case DateRangeOption.lastYear:
        count = 12;
        break;
      case DateRangeOption.last6Months:
        count = 6;
        break;
      default:
        count = 12;
    }

    return List.generate(count, (i) {
      final m = DateTime(now.year, now.month - (count - 1 - i));
      final start = DateTime(m.year, m.month);
      final end = DateTime(m.year, m.month + 1);
      return ChartBar(
        start: start,
        end: end,
        label: monthLetters[start.month - 1],
        total: 0,
      );
    });
  }
}
class DateCalculator {
  static int totalDays(DateTime date) {
    final today = DateTime.now();
    final from = DateTime(date.year, date.month, date.day);
    final to = DateTime(today.year, today.month, today.day);
    return to.difference(from).inDays;
  }

  /// 精确计算年月日差值
  static ({int years, int months, int days}) breakdown(DateTime date) {
    final today = DateTime.now();
    int years = today.year - date.year;
    int months = today.month - date.month;
    int days = today.day - date.day;

    if (days < 0) {
      months -= 1;
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return (years: years, months: months, days: days);
  }
}

class DatetimeUtils {
  static (int, int, int) calculateAge(String? dob) {
    if (dob == null || dob.isEmpty) return (0, 0, 0);
    try {
      final birthDate = DateTime.parse(dob);
      final now = DateTime.now();
      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;
      int days = now.day - birthDate.day;

      if (days < 0) {
        months -= 1;
        final prevMonth = DateTime(now.year, now.month, 0);
        days += prevMonth.day;
      }
      if (months < 0) {
        years -= 1;
        months += 12;
      }
      if (years < 0) {
        return (0, 0, 0);
      }
      return (years, months, days);
    } catch (_) {
      return (0, 0, 0);
    }
  }

  static String getDateStringFromAge(int years, int months, int days) {
    final now = DateTime.now();
    final birthDate = DateTime(
      now.year - years,
      now.month - months,
      now.day - days,
    );
    return getDateStringYYYYMMDD(
      birthDate.year,
      birthDate.month,
      birthDate.day,
    );
  }

  static String getDateStringYYYYMMDD(int year, int month, int day) {
    final buffer = StringBuffer();
    buffer.write(year.toString());
    buffer.write('-');
    buffer.write(month.toString().padLeft(2, '0'));
    buffer.write('-');
    buffer.write(day.toString().padLeft(2, '0'));
    return buffer.toString();
  }

  static String formatTimeToString(String hour, String minute, String period) {
    int hr = int.tryParse(hour) ?? 0;
    int min = int.tryParse(minute) ?? 0;
    assert(hr >= 1 && hr <= 12, 'Hour must be between 1 and 12');
    assert(min >= 0 && min <= 59, 'Minute must be between 0 and 59');
    String ampm = switch (period.toUpperCase()) {
      'AM' => 'AM',
      'PM' => 'PM',
      _ => '',
    };
    assert(ampm.isNotEmpty, 'Period must be either AM or PM');
    return '${hr.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} $ampm';
  }

  // return a record (hour, minute, period)
  static Map<String, String> parseTimeFromString(String time) {
    final parts = time.split(' ');
    assert(parts.length == 2, 'Time must be in the format HH:MM AM/PM');
    final timeParts = parts[0].split(':');
    assert(timeParts.length == 2, 'Time must be in the format HH:MM');
    final hour = timeParts[0].padLeft(2, '0');
    final minute = timeParts[1].padLeft(2, '0');
    final period = parts[1].toUpperCase();
    assert(period == 'AM' || period == 'PM', 'Period must be either AM or PM');
    return {'hour': hour, 'minute': minute, 'period': period};
  }
}

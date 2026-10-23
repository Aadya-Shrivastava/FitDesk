import 'package:intl/intl.dart';

/// Values the app can work out from data it already has (DOB → age,
/// start + package → expiry, check-in/out → duration), so nobody has to type
/// or wait for them. Kept identical in gymadmin and gymtrainee.
class DateCalc {
  DateCalc._();

  static final _formats = [
    DateFormat('yyyy-MM-dd'),
    DateFormat('dd-MM-yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('yyyy/MM/dd'),
  ];

  /// Parses API dates (yyyy-MM-dd, ISO) and form dates (dd-MM-yyyy).
  static DateTime? parse(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null;
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso.toLocal();
    for (final f in _formats) {
      try {
        return f.parseStrict(v);
      } catch (_) {}
    }
    return null;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Completed years between [dob] and today.
  static int? ageFrom(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    var age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age < 0 ? null : age;
  }

  static int? ageFromString(String? dob) => ageFrom(parse(dob));

  /// "12 Mar 1994 • 32 yrs"
  static String dobWithAge(String? dob) {
    final d = parse(dob);
    if (d == null) return (dob ?? '').trim().isEmpty ? '-' : dob!.trim();
    final age = ageFrom(d);
    return '${DateFormat('dd MMM yyyy').format(d)}${age != null ? ' • $age yrs' : ''}';
  }

  /// Membership end date from its start and package
  /// (weekly / monthly / quarterly / half_yearly / yearly).
  static DateTime? expiryFor(DateTime? start, String? package) {
    if (start == null || package == null) return null;
    final p = package.toLowerCase().replaceAll(RegExp(r'[\s-]'), '_');
    DateTime addMonths(int m) {
      final target = DateTime(start.year, start.month + m, 1);
      final lastDay = DateTime(target.year, target.month + 1, 0).day;
      return DateTime(target.year, target.month,
          start.day > lastDay ? lastDay : start.day);
    }

    final DateTime end;
    if (p.contains('week')) {
      end = start.add(const Duration(days: 7));
    } else if (p.contains('half')) {
      end = addMonths(6);
    } else if (p.contains('quarter')) {
      end = addMonths(3);
    } else if (p.contains('year') || p.contains('annual')) {
      end = addMonths(12);
    } else if (p.contains('month')) {
      end = addMonths(1);
    } else {
      return null;
    }
    // Last valid day is the day before the next period starts.
    return end.subtract(const Duration(days: 1));
  }

  /// Days from today until [date] (negative once it has passed).
  static int? daysUntil(DateTime? date) {
    if (date == null) return null;
    return _day(date).difference(_day(DateTime.now())).inDays;
  }

  static String daysLeftLabel(DateTime? date) {
    final d = daysUntil(date);
    if (d == null) return '';
    if (d < 0) return 'Expired ${-d} day${d == -1 ? '' : 's'} ago';
    if (d == 0) return 'Expires today';
    return '$d day${d == 1 ? '' : 's'} left';
  }

  /// "07:05" / "07:05:00" on the same day → minutes between them.
  static Duration? between(String? checkIn, String? checkOut) {
    Duration? parseTime(String? t) {
      final parts = (t ?? '').trim().split(':');
      if (parts.length < 2) return null;
      final h = int.tryParse(parts[0]), m = int.tryParse(parts[1]);
      if (h == null || m == null) return null;
      return Duration(hours: h, minutes: m);
    }

    final a = parseTime(checkIn), b = parseTime(checkOut);
    if (a == null || b == null) return null;
    var diff = b - a;
    if (diff.isNegative) diff += const Duration(days: 1); // past midnight
    return diff;
  }

  /// 95 min → "1h 35m"
  static String fmtDuration(Duration? d) {
    if (d == null) return '-';
    final h = d.inHours, m = d.inMinutes % 60;
    if (h == 0) return '${m}m';
    return m == 0 ? '${h}h' : '${h}h ${m}m';
  }
}

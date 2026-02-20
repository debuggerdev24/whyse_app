/// Centralized date/time formatting for the app.
/// Parses ISO 8601 strings (e.g. from API) and returns readable date/time.
class DateFormatter {
  DateFormatter._();

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Formats an ISO 8601 date-time string (e.g. "2026-02-19T13:13:22.322Z")
  /// to a readable form like "Feb 19, 2026, 1:13 PM".
  /// Returns [fallback] (default "—") if parsing fails.
  static String formatDateTime(String? isoDateString, {String fallback = '—'}) {
    if (isoDateString == null || isoDateString.isEmpty) return fallback;
    try {
      final dt = DateTime.parse(isoDateString);
      return formatDateTimeFrom(dt);
    } catch (_) {
      return fallback;
    }
  }

  /// Formats a [DateTime] to a readable string like "Feb 19, 2026, 1:13 PM".
  /// Uses local timezone.
  static String formatDateTimeFrom(DateTime dateTime) {
    final local = dateTime.toLocal();
    final month = _monthNames[local.month - 1];
    final day = local.day;
    final year = local.year;
    final hour = local.hour;
    final minute = local.minute;

    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final amPm = hour < 12 ? 'AM' : 'PM';
    final minStr = minute.toString().padLeft(2, '0');

    return '$month $day, $year, $h:$minStr $amPm';
  }
}

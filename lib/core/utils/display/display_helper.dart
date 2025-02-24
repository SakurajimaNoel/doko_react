import 'package:characters/characters.dart';
import 'package:intl/intl.dart';

String getUsernameFromCommentInput(String username) {
  // trimming initial @ and end zero-width-whitespace
  return username.substring(1, username.length - 1);
}

String trimText(String text, {int len = 50}) {
  return text.characters.length > len
      ? '${text.characters.take(len)}...'
      : text;
}

/// Format a `DateTime` object to a readable string.
/// Default format: "Thursday, 11 October 2001"
/// - Use `format: 'd MMM y'` for "11 Oct 2001"
String dateString(DateTime date, {String format = 'EEEE, d MMMM y'}) {
  return DateFormat(format).format(date);
}

/// Converts `DateTime` to ISO format but returns only the date part.
String dateToIsoString(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

/// Returns a human-readable time difference.
String displayDateDifference(DateTime date, {String format = "EEEE, d MMM y"}) {
  Duration difference = DateTime.now().difference(date);

  if (difference.inSeconds < 60) return 'a few seconds ago';
  if (difference.inMinutes < 5) return 'a few minutes ago';
  if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
  if (difference.inHours < 24) return '${difference.inHours} hours ago';

  return DateFormat(format).format(date); // "Friday, 6 Aug 2024"
}

/// Formats `DateTime` into a relative week-based format.
String formatDateToWeekDays(DateTime date) {
  DateTime now = DateTime.now();
  if (areSameDay(date, now)) return "Today";
  if (areSameDay(date, now.subtract(const Duration(days: 1)))) {
    return "Yesterday";
  }

  return DateFormat('d MMM y').format(date);
}

/// Converts `DateTime` to a formatted time string like "3:45 PM"
String formatDateTimeToTimeString(DateTime date) {
  return DateFormat('hh:mm a').format(date);
}

/// Checks if two `DateTime` objects represent the same calendar day.
bool areSameDay(DateTime date1, DateTime date2) {
  return DateFormat('yyyy-MM-dd').format(date1) ==
      DateFormat('yyyy-MM-dd').format(date2);
}

/// Formats large numbers into a short format like 1.2K, 3.4M, etc.
String displayNumberFormat(int num) {
  if (num < 1000) return num.toString();
  if (num < 1000000) {
    return '${(num / 1000).toStringAsFixed(num % 1000 == 0 ? 0 : 1)}K';
  }
  if (num < 1000000000) {
    return '${(num / 1000000).toStringAsFixed(num % 1000000 == 0 ? 0 : 1)}M';
  }
  return '${(num / 1000000000).toStringAsFixed(num % 1000000000 == 0 ? 0 : 1)}B';
}

/// get poll status
String getPollStatusText(DateTime dateTime) {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('EEEE, MMM d y, hh:mm a').format(dateTime);

  if (dateTime.isAfter(now)) {
    return 'Ends on $formattedDate';
  } else {
    return 'Ended on $formattedDate';
  }
}

String getPercentage(int voteCount, int totalVotes) {
  if (totalVotes == 0) return "0.00%"; // Avoid division by zero
  double percentage = (voteCount / totalVotes) * 100;
  return "${percentage.toStringAsFixed(2)}%";
}

double getPercentageDouble(int voteCount, int totalVotes) {
  if (totalVotes == 0) return 0.0; // Avoid division by zero
  double percentage = (voteCount / totalVotes);
  return double.parse(
      percentage.toStringAsFixed(1)); // Round to 1 decimal place
}

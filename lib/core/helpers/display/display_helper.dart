part 'display_helper_lib.dart';

String trimText(String text, {int len = 50}) {
  if (text.length > len) {
    return '${text.substring(0, len)}...';
  }
  return text;
}

String dateString(
  DateTime date, {
  bool full = true,
}) {
  /// format date to weekday, day month year
  /// eg: Thursday, 11 October 2001
  int monthIndex = date.month - 1;
  String month = full ? _months[monthIndex] : _monthsAbbr[monthIndex];

  int weekDayIndex = date.weekday - 1;
  String weekDay =
      full ? _daysOfWeek[weekDayIndex] : _daysOfWeekAbbr[weekDayIndex];

  int day = date.day;
  int year = date.year;

  return "$weekDay, $day $month $year";
}

// used when adding node to graph
String dateToIsoString(DateTime date) {
  String dateOnly = date.toIso8601String().split('T').first;
  return dateOnly;
}

String displayDateDifference(DateTime date) {
  Duration difference = DateTime.now().difference(date);

  if (difference.inSeconds < 60) {
    return 'a few seconds ago';
  } else if (difference.inMinutes < 5) {
    return 'a few minutes ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else {
    // For dates older than 24 hours, format as "Fri, 6 Aug 2024"
    return dateString(
      date,
      full: false,
    );
  }
}

String displayNumberFormat(int likes) {
  if (likes < 1000) {
    return likes.toString();
  } else if (likes < 10000) {
    return "${(likes / 1000).toStringAsFixed(0)},${likes % 1000}";
  } else if (likes < 1000000) {
    return '${(likes / 1000).toStringAsFixed(likes % 1000 == 0 ? 0 : 1)}k';
  } else if (likes < 1000000000) {
    return '${(likes / 1000000).toStringAsFixed(likes % 1000000 == 0 ? 0 : 1)}M';
  } else {
    return '${(likes / 1000000000).toStringAsFixed(likes % 1000000000 == 0 ? 0 : 1)}B';
  }
}

String getUsernameFromCommentInput(String username) {
  // trimming initial @ and end zero-width-whitespace
  return username.substring(1, username.length - 1);
}

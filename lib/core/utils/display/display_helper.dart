import 'package:characters/characters.dart';

part 'display_helper_lib.dart';

String trimText(String text, {int len = 50}) {
  if (text.characters.length > len) {
    return '${text.characters.take(len)}...';
  }
  return text;
}

String dateString(
  DateTime date, {
  bool full = true,
  bool small = false,
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

  if (small) return "$day $month $year";
  return "$weekDay, $day $month $year";
}

// used when adding node to graph
String dateToIsoString(DateTime date) {
  String dateOnly = date.toIso8601String().split('T').first;
  return dateOnly;
}

String displayDateDifference(
  DateTime date, {
  bool small = false,
}) {
  if (small) {
    return dateString(
      date,
      full: false,
      small: small,
    );
  }

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

String formatDateToWeekDays(DateTime date) {
  // Convert UTC to local time
  DateTime localDate = date.toLocal();

  // Get the current local date
  DateTime now = DateTime.now();
  DateTime today = DateTime(now.year, now.month, now.day);
  DateTime yesterday = today.subtract(const Duration(
    days: 1,
  ));

  // Start of the current week (assuming week starts on Monday)
  DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

  // Check for Today or Yesterday
  if (localDate.year == today.year &&
      localDate.month == today.month &&
      localDate.day == today.day) {
    return "Today";
  } else if (localDate.year == yesterday.year &&
      localDate.month == yesterday.month &&
      localDate.day == yesterday.day) {
    return "Yesterday";
  }

  // Check if the date is within the current week
  if (localDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
      localDate.isBefore(startOfWeek.add(const Duration(days: 7)))) {
    return _daysOfWeek[localDate.weekday - 1];
  } // Weekday name

  // Otherwise, format as "12 Dec 2024"
  String day = localDate.day.toString();
  String month = _monthsAbbr[localDate.month - 1];
  String year = localDate.year.toString();

  return "$day $month $year";
}

String formatDateTimeToTimeString(DateTime date) {
  DateTime now = DateTime.now();
  DateTime localDateTime = date.toLocal();

  // Check if the given date is today
  bool isToday = now.year == localDateTime.year &&
      now.month == localDateTime.month &&
      now.day == localDateTime.day;

  // Extract the hour, minute, and period (AM/PM)
  int hour = localDateTime.hour;
  String period = hour >= 12 ? "PM" : "AM";
  hour = hour % 12 == 0
      ? 12
      : hour % 12; // Convert 0 or 24 to 12 in 12-hour format
  String minute =
      localDateTime.minute.toString().padLeft(2, '0'); // Ensure two digits

  String timeString = "$hour:$minute $period";

  if (!isToday) {
    // Format the date as "MMM d, yyyy"
    String dateString =
        "${localDateTime.day.toString().padLeft(2, '0')}-${localDateTime.month.toString().padLeft(2, '0')}-${localDateTime.year.toString()}";
    return "$dateString $timeString";
  }

  return timeString;
}

bool areSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

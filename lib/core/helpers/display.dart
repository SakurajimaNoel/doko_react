class DisplayText {
  static const List<String> daysOfWeek = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  static String trimText(String text, {int? len}) {
    int trimLen = len ?? 50;

    if (text.length > trimLen) {
      return '${text.substring(0, trimLen)}...';
    }
    return text;
  }

  static String _getMonthName(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'January';
    }
  }

  static String _getWeekDayName(int dayNumber) {
    switch (dayNumber) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  static String dateString(DateTime date) {
    // format date to weekday, day month year
    // eg: Thursday, 11 October 2001
    int month = date.month;
    int day = date.day;
    int year = date.year;
    int weekDay = date.weekday;

    return "${_getWeekDayName(weekDay)}, $day ${_getMonthName(month)} $year";
  }

  static String date(DateTime date) {
    String dateOnly = date.toIso8601String().split('T').first;
    return dateOnly;
  }

  static String displayDateDiff(DateTime date) {
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
      // For dates older than 24 hours, format as "Fri, 6 Aug"

      String dayOfWeek = daysOfWeek[date.weekday % 7];
      String month = months[date.month - 1];
      String day = date.day.toString();
      String year = date.year.toString();

      return '$dayOfWeek, $day $month $year';
    }
  }
}

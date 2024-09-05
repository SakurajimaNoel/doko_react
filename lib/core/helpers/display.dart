class DisplayText {
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
}

enum ResponseStatus { success, error }

class EnumHelpers {
  static String enumToString<T>(T value) {
    return value.toString();
  }

  static T stringToEnum<T>(String value, List<T> values) {
    return values.firstWhere((val) => val.toString() == value);
  }
}

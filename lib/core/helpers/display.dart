class DisplayText {
  static String trimText(String text, {int? len}) {
    int trimLen = len ?? 50;

    if (text.length > trimLen) {
      return '${text.substring(0, trimLen)}...';
    }
    return text;
  }
}

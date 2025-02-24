import 'package:doko_react/core/utils/uuid/uuid_helper.dart';

class PollPublishPageData {
  const PollPublishPageData({
    required this.question,
    required this.activeFor,
    required this.options,
  });

  final String question;
  final int activeFor;
  final List<String> options;
}

// used in polls create page
class PollOptionInput {
  PollOptionInput({
    this.value = "",
  }) : key = generateUniqueString();

  final String key;
  String value;

  void updateValue(String newValue) {
    value = newValue;
  }
}

class PollCreateInput {
  PollCreateInput({
    required this.username,
    required this.question,
    required int activeFor,
    required this.options,
    required this.usersTagged,
  }) : activeTill = DateTime.now().add(Duration(
          days: activeFor,
        ));

  final String username;
  final String question;
  final DateTime activeTill;
  final List<String> options;
  final List<String> usersTagged;
}

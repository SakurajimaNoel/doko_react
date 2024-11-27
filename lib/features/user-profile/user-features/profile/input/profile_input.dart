import 'package:doko_react/core/validation/input.dart';

class GetProfileInput extends Input {
  GetProfileInput({
    required this.username,
    required this.currentUsername,
  });

  final String username;
  final String currentUsername;

  @override
  String invalidateReason() {
    return "";
  }

  @override
  bool validate() {
    return true;
  }
}

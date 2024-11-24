import 'package:doko_react/core/validation/input.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';

class UsernameInput extends Input {
  UsernameInput({
    required this.username,
  });

  final String username;

  @override
  String invalidateReason() {
    if (!validate()) return "Invalid username.";

    return "";
  }

  @override
  bool validate() {
    return validateUsername(username);
  }
}

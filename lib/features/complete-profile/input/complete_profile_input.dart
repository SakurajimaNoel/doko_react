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

class CompleteProfileInput extends Input {
  CompleteProfileInput({
    required this.userId,
    required this.username,
    required this.email,
    required this.profilePath,
    required this.name,
    required this.dob,
  });

  final String userId;
  final String username;
  final String email;
  final String profilePath;
  final String name;
  final DateTime dob;

  @override
  String invalidateReason() {
    if (!validateUsername(username)) return "Invalid username.";

    if (userId.isEmpty || !validateEmail(email)) return "User is invalid.";

    if (name.isEmpty) return "Invalid name.";

    return "";
  }

  @override
  bool validate() {
    return validateUsername(username) &&
        userId.isNotEmpty &&
        validateEmail(email) &&
        name.isNotEmpty;
  }
}

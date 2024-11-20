import 'package:password_strength/password_strength.dart';

bool validateEmail(String email) {
  final RegExp emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  return emailRegex.hasMatch(email);
}

bool validatePassword(String password) {
  final RegExp passwordRegex =
      RegExp(r"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$");

  return passwordRegex.hasMatch(password);
}

bool validatePasswordStrength(String password) {
  return estimatePasswordStrength(password) < 0.5;
}

// used for checking if both passwords are equal
bool compareString(String stringOne, String stringTwo) {
  return stringOne == stringTwo;
}

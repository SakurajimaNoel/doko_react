import 'package:doko_react/core/constants/constants.dart';
import 'package:password_strength/password_strength.dart';

bool validateEmail(String? email) {
  if (email == null) return false;

  final RegExp emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  return emailRegex.hasMatch(email);
}

bool validatePassword(String? password) {
  if (password == null) return false;

  final RegExp digitRegex = RegExp(r"\d");
  final RegExp lowercaseRegex = RegExp(r"[a-z]");
  final RegExp uppercaseRegex = RegExp(r"[A-Z]");
  final RegExp specialCharRegex = RegExp(r"\W");
  final RegExp whitespaceRegex = RegExp(r"\s");

  return uppercaseRegex.hasMatch(password) &&
      lowercaseRegex.hasMatch(password) &&
      digitRegex.hasMatch(password) &&
      specialCharRegex.hasMatch(password) &&
      !whitespaceRegex.hasMatch(password) &&
      password.length >= 8 &&
      password.length <= 24 &&
      _validatePasswordStrength(password);
}

String passwordInvalidateReason(String? password) {
  if (password == null) return "Password can't be empty";

  final RegExp digitRegex = RegExp(r"\d");
  final RegExp lowercaseRegex = RegExp(r"[a-z]");
  final RegExp uppercaseRegex = RegExp(r"[A-Z]");
  final RegExp specialCharRegex = RegExp(r"\W");
  final RegExp whitespaceRegex = RegExp(r"\s");

  if (!uppercaseRegex.hasMatch(password)) {
    return "Password must contain at least one uppercase letter";
  }
  if (!lowercaseRegex.hasMatch(password)) {
    return "Password must contain at least one lowercase letter";
  }

  if (!digitRegex.hasMatch(password)) {
    return "Password must contain at least one digit";
  }

  if (!specialCharRegex.hasMatch(password)) {
    return "Password must contain at least one special character";
  }

  if (whitespaceRegex.hasMatch(password)) {
    return "Password must not contain spaces";
  }

  // Check the length of the password
  if (password.length < 8 || password.length > 24) {
    return "Password must be 8-24 characters long";
  }

  return "Password too weak. Please try again.";
}

bool _validatePasswordStrength(String? password) {
  if (password == null) return false;

  return estimatePasswordStrength(password) > 0.5;
}

// used for checking if both passwords are equal
bool compareString(String stringOne, String stringTwo) {
  return stringOne == stringTwo;
}

bool validateUsername(String? username) {
  if (username == null || username.isEmpty) return false;

  final RegExp usernameRegex = RegExp(r"^" + Constants.usernameRegex + r"$");
  return usernameRegex.hasMatch(username);
}

/// used for comment media check
bool validateUrl(String url) {
  return url.startsWith("http");
}

bool validateDate(String dateString) {
  return DateTime.tryParse(dateString) != null;
}

bool validateBio(String? bio) {
  if (bio != null && bio.length > 160) {
    return false;
  }

  return true;
}

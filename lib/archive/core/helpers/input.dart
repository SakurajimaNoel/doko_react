import 'package:doko_react/archive/core/helpers/constants.dart';

class InputStatus {
  final bool isValid;
  final String? message;

  InputStatus({required this.isValid, this.message});
}

class ValidateInput {
  static InputStatus validateEmail(String? email) {
    final RegExp emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (email == null || email.isEmpty) {
      return InputStatus(isValid: false, message: "Email field can't be empty");
    }

    if (!emailRegex.hasMatch(email)) {
      return InputStatus(
          isValid: false, message: "Invalid email address provided");
    }

    return InputStatus(isValid: true);
  }

  static InputStatus validatePassword(String? password) {
    // Define the regular expressions for different requirements
    final RegExp digitRegex = RegExp(r"\d");
    final RegExp lowercaseRegex = RegExp(r"[a-z]");
    final RegExp uppercaseRegex = RegExp(r"[A-Z]");
    final RegExp specialCharRegex = RegExp(r"\W");
    final RegExp whitespaceRegex = RegExp(r"\s");

    // Check for null or empty password
    if (password == null || password.isEmpty) {
      return InputStatus(isValid: false, message: "Password can't be empty");
    }

    if (!uppercaseRegex.hasMatch(password)) {
      return InputStatus(
          isValid: false,
          message: "Password must contain at least one uppercase letter");
    }
    if (!lowercaseRegex.hasMatch(password)) {
      return InputStatus(
          isValid: false,
          message: "Password must contain at least one lowercase letter");
    }

    if (!digitRegex.hasMatch(password)) {
      return InputStatus(
          isValid: false, message: "Password must contain at least one digit");
    }

    if (!specialCharRegex.hasMatch(password)) {
      return InputStatus(
          isValid: false,
          message: "Password must contain at least one special character");
    }

    if (whitespaceRegex.hasMatch(password)) {
      return InputStatus(
          isValid: false, message: "Password must not contain spaces");
    }

    // Check the length of the password
    if (password.length < 8 || password.length > 16) {
      return InputStatus(
          isValid: false, message: "Password must be 8-16 characters long");
    }

    // If all checks pass
    return InputStatus(isValid: true);
  }

  static InputStatus validateConfirmPassword(
      String password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return InputStatus(
          isValid: false, message: "Confirm password can't be empty");
    }

    if (password != confirmPassword) {
      return InputStatus(
          isValid: false, message: "Both passwords should match");
    }

    return InputStatus(isValid: true);
  }

  static InputStatus validateConfirmCode(String? code) {
    if (code == null || code.isEmpty) {
      return InputStatus(
        isValid: false,
        message: "MFA code can't be empty",
      );
    }

    if (code.length != 6) {
      return InputStatus(
        isValid: false,
        message: "Invalid confirm code.",
      );
    }

    return InputStatus(isValid: true);
  }

  static InputStatus validateUsername(String? username) {
    final RegExp usernameRegex = RegExp(r"^" + Constants.usernameRegex + r"$");

    if (username == null || username.isEmpty) {
      return InputStatus(
        isValid: false,
        message: "Username can't be empty.",
      );
    }

    if (!usernameRegex.hasMatch(username)) {
      return InputStatus(
        isValid: false,
        message: "Username is invalid.",
      );
    }

    return InputStatus(isValid: true);
  }

  static InputStatus validateName(String? name) {
    final nameRegex = RegExp(r'^[A-Za-z\s]{2,30}$');

    if (name == null || name.isEmpty) {
      return InputStatus(
        isValid: false,
        message: "Name can't be empty.",
      );
    }

    if (name.length > 30) {
      return InputStatus(
        isValid: false,
        message: "Name too long.",
      );
    }

    if (!nameRegex.hasMatch(name)) {
      return InputStatus(
        isValid: false,
        message: "Invalid name.",
      );
    }

    return InputStatus(isValid: true);
  }

  static InputStatus validateBio(String? bio) {
    if (bio != null && bio.length > 160) {
      return InputStatus(
        isValid: false,
        message: "Bio too long.",
      );
    }

    return InputStatus(isValid: true);
  }
}

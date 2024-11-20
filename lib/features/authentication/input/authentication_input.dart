import 'package:doko_react/core/validation/input.dart';
import 'package:doko_react/core/validation/input_validation/input_validation.dart';

class LoginInput implements Input {
  const LoginInput({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  bool validate() {
    // no need to check for password during login
    return validateEmail(email);
  }

  @override
  String invalidateReason() {
    if (!validateEmail(email)) return "Please provide a valid email address.";

    return "";
  }
}

class SignupInput implements Input {
  const SignupInput({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  bool validate() {
    return validateEmail(email) &&
        validatePassword(password) &&
        validatePasswordStrength(password);
  }

  @override
  String invalidateReason() {
    if (!validateEmail(email)) return "Please provide a valid email address.";

    if (!validatePassword(password)) {
      return "Incorrect password. Please try again.";
    }

    if (!validatePasswordStrength(password)) {
      return "Password too weak. Please try again.";
    }

    return "";
  }
}

class ResetPasswordInput implements Input {
  const ResetPasswordInput({
    required this.email,
  });

  final String email;

  @override
  bool validate() {
    return validateEmail(email);
  }

  @override
  String invalidateReason() {
    if (!validateEmail(email)) return "Please provide a valid email address.";

    return "";
  }
}

class ConfirmResetPasswordInput implements Input {
  const ConfirmResetPasswordInput({
    required this.email,
    required this.password,
    required this.code,
  });

  final String email;
  final String password;
  final String code;

  @override
  bool validate() {
    return validateEmail(email) &&
        validatePassword(password) &&
        validatePasswordStrength(password);
  }

  @override
  String invalidateReason() {
    if (!validateEmail(email)) return "Please provide a valid email address.";
    
    if (!validatePassword(password)) {
      return "Incorrect password. Please try again.";
    }

    if (!validatePasswordStrength(password)) {
      return "Password too weak. Please try again.";
    }

    return "";
  }
}

class UpdatePasswordInput implements Input {
  const UpdatePasswordInput({
    required this.oldPassword,
    required this.newPassword,
  });

  final String oldPassword;
  final String newPassword;

  @override
  bool validate() {
    return validatePassword(newPassword) &&
        validatePasswordStrength(newPassword);
  }

  @override
  String invalidateReason() {
    if (!validatePassword(newPassword)) {
      return "Incorrect password. Please try again.";
    }

    if (!validatePasswordStrength(newPassword)) {
      return "Password too weak. Please try again.";
    }
    return "";
  }
}

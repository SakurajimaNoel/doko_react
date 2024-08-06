import 'package:flutter/widgets.dart';

enum AuthenticationStatus { loading, signedIn, signedOut }

class AuthenticationProvider extends ChangeNotifier {
  AuthenticationStatus authStatus = AuthenticationStatus.loading;

  void setAuthStatus(AuthenticationStatus status) {
    authStatus = status;
    notifyListeners();
  }
}

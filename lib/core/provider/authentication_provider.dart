import 'package:flutter/widgets.dart';

enum AuthenticationStatus { loading, signedIn, signedOut }

enum AuthenticationMFAStatus { undefined, setUpped, notSetUpped }

class AuthenticationProvider extends ChangeNotifier {
  AuthenticationStatus _authStatus = AuthenticationStatus.loading;
  AuthenticationMFAStatus _mfaStatus = AuthenticationMFAStatus.undefined;

  AuthenticationMFAStatus get mfaStatus => _mfaStatus;

  AuthenticationStatus get authStatus => _authStatus;

  void setAuthStatus(AuthenticationStatus status) {
    _authStatus = status;

    notifyListeners();
  }

  void setMFAStatus(AuthenticationMFAStatus mfaStatus) {
    _mfaStatus = mfaStatus;
    notifyListeners();
  }
}

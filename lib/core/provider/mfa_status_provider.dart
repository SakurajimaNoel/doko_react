import 'package:flutter/widgets.dart';

enum AuthenticationMFAStatus { undefined, setUpped, notSetUpped }

class AuthenticationMFAProvider extends ChangeNotifier {
  AuthenticationMFAStatus _mfaStatus = AuthenticationMFAStatus.undefined;

  AuthenticationMFAStatus get mfaStatus => _mfaStatus;

  void setMFAStatus(AuthenticationMFAStatus mfaStatus) {
    _mfaStatus = mfaStatus;
    notifyListeners();
  }
}

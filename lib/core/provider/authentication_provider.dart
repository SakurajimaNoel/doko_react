import 'package:flutter/widgets.dart';

enum AuthenticationStatus { loading, signedIn, signedOut }



class AuthenticationProvider extends ChangeNotifier {
  AuthenticationStatus _authStatus = AuthenticationStatus.loading;

  AuthenticationStatus get authStatus => _authStatus;


  void setAuthStatus(AuthenticationStatus status) {
    _authStatus = status;



    notifyListeners();
  }


}

import 'package:doko_react/core/router/router_constants.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

enum AuthenticationStatus { loading, signedIn, signedOut }

class AuthenticationProvider extends ChangeNotifier {
  AuthenticationStatus _authStatus = AuthenticationStatus.loading;

  AuthenticationStatus get authStatus => _authStatus;

  void setAuthStatus(AuthenticationStatus status, BuildContext context) {
    _authStatus = status;
    notifyListeners();

    if (status == AuthenticationStatus.signedIn) {
      GoRouter.of(context).goNamed(RouterConstants.userFeed);
    } else if (status == AuthenticationStatus.signedOut) {
      GoRouter.of(context).goNamed(RouterConstants.login);
    }
  }
}

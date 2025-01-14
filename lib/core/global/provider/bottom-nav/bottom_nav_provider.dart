import 'package:flutter/cupertino.dart';

class BottomNavProvider extends ChangeNotifier {
  bool _show;

  BottomNavProvider() : _show = true;

  bool get show => _show;

  bool get hide => !_show;

  void showBottomNav() {
    if (show) return;

    _show = true;
    notifyListeners();
  }

  void hideBottomNav() {
    if (hide) return;

    _show = false;
    notifyListeners();
  }
}

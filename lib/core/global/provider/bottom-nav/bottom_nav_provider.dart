import 'package:flutter/cupertino.dart';

class BottomNavProvider extends ChangeNotifier {
  bool _show;

  BottomNavProvider() : _show = true;

  bool get show => _show;

  void showBottomNav() {
    if (_show) return;

    _show = true;
    notifyListeners();
  }

  void hideBottomNav() {
    if (!_show) return;

    _show = false;
    notifyListeners();
  }
}

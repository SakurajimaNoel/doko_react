import 'package:flutter/material.dart';

class UserPreferencesProvider extends ChangeNotifier {
  bool _isMuted = true;
  bool _profileRefresh = false;

  bool get profileRefresh => _profileRefresh;

  bool get mute => _isMuted;

  void toggleAudio() {
    _isMuted = !_isMuted;

    notifyListeners();
  }

  void needsProfileRefresh() {
    _profileRefresh = !_profileRefresh;

    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class VideoProvider extends ChangeNotifier {
  bool _isMuted = true;

  bool get mute => _isMuted;

  void toggleAudio() {
    _isMuted = !_isMuted;

    notifyListeners();
  }
}

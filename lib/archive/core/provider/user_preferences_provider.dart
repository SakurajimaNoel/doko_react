import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _videoPlayerAudioPrefKey = "audio";

class UserPreferencesProvider extends ChangeNotifier {
  late SharedPreferences _preferences;
  bool _isMuted = true;
  bool _profileRefresh = false;

  bool get profileRefresh => _profileRefresh;

  bool get mute => _isMuted;

  UserPreferencesProvider(SharedPreferences prefs) {
    _preferences = prefs;
    _loadPreferences();
  }

  void _loadPreferences() {
    _isMuted = _preferences.getBool(_videoPlayerAudioPrefKey) ?? false;
    notifyListeners();
  }

  void toggleAudio() async {
    _isMuted = !_isMuted;

    notifyListeners();

    await _preferences.setBool(_videoPlayerAudioPrefKey, _isMuted);
  }

  void needsProfileRefresh() {
    _profileRefresh = !_profileRefresh;

    notifyListeners();
  }
}

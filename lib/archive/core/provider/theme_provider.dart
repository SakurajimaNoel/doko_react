import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserTheme { system, light, dark }

const String _themePrefKey = "theme";
const String _colorPrefKey = "color";

class ThemeProvider extends ChangeNotifier {
  late SharedPreferences _preferences;

  UserTheme _themeMode = UserTheme.system;
  Color _accentColor = Colors.red;

  UserTheme get themeMode => _themeMode;

  Color get accent => _accentColor;

  ThemeProvider(SharedPreferences prefs) {
    _preferences = prefs;
    _loadTheme();
  }

  void _loadTheme() async {
    String storedTheme =
        _preferences.getString(_themePrefKey) ?? _themeMode.toString();
    _themeMode = EnumHelpers.stringToEnum(storedTheme, UserTheme.values);

    int storedAccent = _preferences.getInt(_colorPrefKey) ?? _accentColor.value;
    _accentColor = Color(storedAccent);
    notifyListeners();
  }

  void toggleTheme(UserTheme theme) async {
    _themeMode = theme;
    notifyListeners();

    await _preferences.setString(
        _themePrefKey, EnumHelpers.enumToString(theme));
  }

  void changeAccent(Color color) async {
    _accentColor = color;
    notifyListeners();
    
    await _preferences.setInt(_colorPrefKey, color.value);
  }
}

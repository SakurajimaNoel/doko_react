import 'package:doko_react/core/helpers/enum.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserTheme { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = "theme";
  static const String _colorPrefKey = "color";

  UserTheme _themeMode = UserTheme.system;
  Color _accentColor = Colors.red;

  UserTheme get themeMode => _themeMode;

  Color get accent => _accentColor;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedTheme =
        prefs.getString(_themePrefKey) ?? _themeMode.toString();
    _themeMode = EnumHelpers.stringToEnum(storedTheme, UserTheme.values);

    int storedAccent = prefs.getInt(_colorPrefKey) ?? _accentColor.value;
    _accentColor = Color(storedAccent);
    notifyListeners();
  }

  void toggleTheme(UserTheme theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, EnumHelpers.enumToString(theme));

    _themeMode = theme;
    notifyListeners();
  }

  void changeAccent(Color color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorPrefKey, color.value);

    _accentColor = color;
    notifyListeners();
  }
}

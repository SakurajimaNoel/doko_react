import 'package:doko_react/core/helpers/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserTheme { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = "theme";

  UserTheme themeMode = UserTheme.system;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedTheme =
        prefs.getString(_themePrefKey) ?? UserTheme.system.toString();
    themeMode = EnumHelpers.stringToEnum(storedTheme, UserTheme.values);
    notifyListeners();
  }

  void toggleTheme(UserTheme theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, EnumHelpers.enumToString(theme));

    themeMode = theme;
    notifyListeners();
  }
}

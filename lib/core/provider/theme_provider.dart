import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  List<String> themeModeList = ["light", "dark", "system default"];
  static const String _themePrefKey = "theme";

  String themeMode = "system default";

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedTheme = prefs.getString(_themePrefKey) ?? "system default";
    themeMode = storedTheme;
    notifyListeners();
  }

  void toggleTheme(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themePrefKey, theme);

    themeMode = theme;
    notifyListeners();
  }
}

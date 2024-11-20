import 'package:flutter/material.dart';

class GlobalThemeData {
  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      colorScheme: colorScheme,
      // focusColor: focusColor,
      // canvasColor: colorScheme.surface,
      // scaffoldBackgroundColor: colorScheme.surface,
      // highlightColor: Colors.transparent,
      fontFamily: "Rubik",
      useMaterial3: true,
    );
  }

  static final Color _lightFocusColor = Colors.black.withOpacity(0.12);
  static final Color _darkFocusColor = Colors.white.withOpacity(0.12);

  // fixed color
  static ThemeData lightThemeData = themeData(_light, _lightFocusColor);
  static ThemeData darkThemeData = themeData(_dark, _darkFocusColor);

  static final ColorScheme _light = ColorScheme.fromSeed(
      seedColor: Colors.green, brightness: Brightness.light);

  static final ColorScheme _dark = ColorScheme.fromSeed(
      seedColor: Colors.green, brightness: Brightness.dark);

  // custom color
  static ThemeData lightCustomThemeData(Color color) {
    return themeData(_lightCustom(color), _lightFocusColor);
  }

  static ThemeData darkCustomThemeData(Color color) {
    return themeData(_darkCustom(color), _darkFocusColor);
  }

  static ColorScheme _lightCustom(Color color) {
    return ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);
  }

  static ColorScheme _darkCustom(Color color) {
    return ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color.fromRGBO(211, 85, 165, 1),
    onPrimary: Color.fromRGBO(37, 10, 41, 1),
    secondary: Color.fromRGBO(191, 49, 68, 1),
    onSecondary: Color.fromRGBO(37, 10, 41, 1),
    error: Colors.redAccent,
    onError: Colors.white,
    surface: Color.fromRGBO(244, 222, 247, 1),
    onSurface: Color.fromRGBO(37, 10, 41, 1),
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color.fromRGBO(170, 44, 124, 1),
    onPrimary: Color.fromRGBO(241, 214, 245, 1),
    secondary: Color.fromRGBO(206, 64, 83, 1),
    onSecondary: Color.fromRGBO(241, 214, 245, 1),
    error: Colors.redAccent,
    onError: Colors.white,
    surface: Color.fromRGBO(30, 8, 33, 1),
    onSurface: Color.fromRGBO(241, 214, 245, 1),
    brightness: Brightness.dark,
  );
}

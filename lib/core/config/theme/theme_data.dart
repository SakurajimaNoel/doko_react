import 'package:flutter/material.dart';

class GlobalThemeData {
  static ThemeData themeData(ColorScheme colorScheme) {
    return ThemeData(
      colorScheme: colorScheme,
      fontFamily: "Rubik",
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // custom color
  static ThemeData lightCustomThemeData(Color color) {
    return themeData(
      _lightCustom(color),
    );
  }

  static ThemeData darkCustomThemeData(Color color) {
    return themeData(
      _darkCustom(color),
    );
  }

  static ColorScheme _lightCustom(Color color) {
    return ColorScheme.fromSeed(seedColor: color, brightness: Brightness.light);
  }

  static ColorScheme _darkCustom(Color color) {
    return ColorScheme.fromSeed(seedColor: color, brightness: Brightness.dark);
  }
}

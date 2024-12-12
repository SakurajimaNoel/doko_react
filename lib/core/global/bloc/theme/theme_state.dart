part of 'theme_bloc.dart';

class ThemeState extends Equatable {
  const ThemeState({
    required this.mode,
    required this.accent,
  });

  final ThemeMode mode;
  final Color accent;

  @override
  List<Object?> get props => [mode, accent];

  ThemeState copyWith({
    ThemeMode? mode,
    Color? accent,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
    );
  }

  static int _floatToInt8(double x) {
    return (x * 255.0).round() & 0xff;
  }

  int getAccentValue() {
    return _floatToInt8(accent.a) << 24 |
        _floatToInt8(accent.r) << 16 |
        _floatToInt8(accent.g) << 8 |
        _floatToInt8(accent.b) << 0;
  }

  Map<String, dynamic>? toJson() {
    return {
      "mode": mode.toString(),
      "accent": getAccentValue(),
    };
  }

  static ThemeState? fromJson(Map<String, dynamic> json) {
    List<ThemeMode> modes = ThemeMode.values;
    ThemeMode mode = modes.firstWhere((val) => val.toString() == json["mode"]);

    Color accent = Color(json["accent"] as int);

    return ThemeState(
      mode: mode,
      accent: accent,
    );
  }
}

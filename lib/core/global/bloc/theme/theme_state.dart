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

  Map<String, dynamic>? toJson() {
    return {
      "mode": mode.toString(),
      "accent": accent.value,
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

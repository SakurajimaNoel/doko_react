part of 'theme_bloc.dart';

@immutable
sealed class ThemeEvent {}

final class ThemeChangeEvent extends ThemeEvent {
  ThemeChangeEvent({required this.selectedMode});

  final ThemeMode selectedMode;
}

final class ThemeChangeAccentEvent extends ThemeEvent {
  ThemeChangeAccentEvent({required this.selectedAccent});

  final Color selectedAccent;
}

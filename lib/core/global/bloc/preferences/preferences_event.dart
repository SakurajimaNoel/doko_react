part of 'preferences_bloc.dart';

@immutable
sealed class PreferencesEvent {}

final class PreferencesAudioToggleEvent extends PreferencesEvent {}

final class PreferencesSaveMediaToggleEvent extends PreferencesEvent {}

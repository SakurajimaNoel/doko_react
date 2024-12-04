part of 'preferences_bloc.dart';

class PreferencesState extends Equatable {
  const PreferencesState({
    required this.audio,
  });

  final bool audio;

  @override
  List<Object?> get props => [audio];

  PreferencesState copyWith({
    bool? audio,
  }) {
    return PreferencesState(
      audio: audio ?? this.audio,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      "audio": audio.toString(),
    };
  }

  static PreferencesState? fromJson(Map<String, dynamic> json) {
    return PreferencesState(
      audio: bool.parse(json["audio"]),
    );
  }
}

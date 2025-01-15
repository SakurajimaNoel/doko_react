part of 'preferences_bloc.dart';

class PreferencesState extends Equatable {
  const PreferencesState({
    required this.audio,
    required this.saveCapturedMedia,
  });

  final bool audio;
  final bool saveCapturedMedia;

  @override
  List<Object?> get props => [audio, saveCapturedMedia];

  PreferencesState copyWith({
    bool? audio,
    bool? saveCapturedMedia,
  }) {
    return PreferencesState(
      audio: audio ?? this.audio,
      saveCapturedMedia: saveCapturedMedia ?? this.saveCapturedMedia,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      "audio": audio.toString(),
      "saveCapturedMedia": saveCapturedMedia.toString(),
    };
  }

  static PreferencesState? fromJson(Map<String, dynamic> json) {
    return PreferencesState(
      audio: bool.parse(json["audio"]),
      saveCapturedMedia: bool.parse(json["saveCapturedMedia"]),
    );
  }
}

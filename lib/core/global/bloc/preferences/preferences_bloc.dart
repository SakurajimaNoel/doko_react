import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';

part 'preferences_event.dart';
part 'preferences_state.dart';

class PreferencesBloc extends HydratedBloc<PreferencesEvent, PreferencesState> {
  PreferencesBloc()
      : super(
          // default preferences
          const PreferencesState(
            audio: true,
          ),
        ) {
    on<PreferencesAudioToggleEvent>((event, emit) {
      emit(state.copyWith(
        audio: !state.audio,
      ));
    });
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return PreferencesState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(state) {
    return state.toJson();
  }
}

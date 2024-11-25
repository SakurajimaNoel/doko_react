import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeState> {
  ThemeBloc()
      : super(
          // default theme data
          const ThemeState(
            mode: ThemeMode.system,
            accent: Colors.deepPurple,
          ),
        ) {
    on<ThemeChangeEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            mode: event.selectedMode,
          ),
        );
      },
    );
    on<ThemeChangeAccentEvent>(
      (event, emit) {
        emit(
          state.copyWith(
            accent: event.selectedAccent,
          ),
        );
      },
    );
  }

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    return ThemeState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    return state.toJson();
  }
}

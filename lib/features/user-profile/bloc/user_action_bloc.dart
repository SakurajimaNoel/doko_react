import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'user_action_event.dart';
part 'user_action_state.dart';

class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  UserActionBloc() : super(UserActionInitial()) {
    on<UserActionUpdateEvent>(_handleUserActionUpdateEvent);
  }

  FutureOr<void> _handleUserActionUpdateEvent(
      UserActionUpdateEvent event, Emitter<UserActionState> emit) {
    emit(UserActionUpdateProfile(
      name: event.name,
      bio: event.bio,
      profilePicture: event.profilePicture,
    ));
  }
}

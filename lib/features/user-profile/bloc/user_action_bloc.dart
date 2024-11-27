import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'user_action_event.dart';
part 'user_action_state.dart';

class UserActionBloc extends Bloc<UserActionEvent, UserActionState> {
  UserActionBloc() : super(UserActionInitial()) {
    on<UserActionEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

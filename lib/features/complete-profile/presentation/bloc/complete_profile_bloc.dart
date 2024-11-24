import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/bloc/event_transformer.dart';
import 'package:doko_react/features/complete-profile/domain/use-case/username-use-case/username_use_case.dart';
import 'package:doko_react/features/complete-profile/input/complete_profile_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'complete_profile_event.dart';
part 'complete_profile_state.dart';

class CompleteProfileBloc
    extends Bloc<CompleteProfileEvent, CompleteProfileState> {
  final UsernameUseCase _usernameUseCase;

  CompleteProfileBloc({
    required UsernameUseCase usernameUseCase,
  })  : _usernameUseCase = usernameUseCase,
        super(CompleteProfileInitialState()) {
    on<CompleteProfileUsernameEvent>(
      _handleCompleteProfileUsernameEvent,
      transformer: debounce(
        const Duration(
          milliseconds: 500,
        ),
      ),
    );
  }

  FutureOr<void> _handleCompleteProfileUsernameEvent(
      CompleteProfileUsernameEvent event,
      Emitter<CompleteProfileState> emit) async {
    try {
      emit(CompleteProfileLoadingState());
      String username = event.usernameInput.username;

      bool available = await _usernameUseCase(event.usernameInput);

      emit(CompleteProfileUsernameStatusState(
        available: available,
        username: username,
      ));
    } on ApplicationException catch (e) {
      emit(CompleteProfileErrorState(
        message: e.reason,
      ));
    } catch (_) {
      emit(CompleteProfileErrorState(
        message: Constants.errorMessage,
      ));
    }
  }
}
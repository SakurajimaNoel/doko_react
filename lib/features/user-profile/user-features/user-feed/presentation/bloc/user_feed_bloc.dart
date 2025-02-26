import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/domain/use-case/user-feed-content/content_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/user-feed/input/user_feed_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_feed_event.dart';
part 'user_feed_state.dart';

class UserFeedBloc extends Bloc<UserFeedEvent, UserFeedState> {
  final ContentUseCase contentUseCase;

  UserFeedBloc({
    required this.contentUseCase,
  }) : super(UserFeedLoading()) {
    on<UserFeedGetEvent>(_handleUserFeedGetEvent);
  }

  FutureOr<void> _handleUserFeedGetEvent(
      UserFeedGetEvent event, Emitter<UserFeedState> emit) async {
    try {
      await contentUseCase(event.details);
      emit(UserFeedGetResponseSuccessState());
    } catch (e) {
      String reason = Constants.errorMessage;
      if (e is ApplicationException) {
        reason = e.reason;
      }

      emit(UserFeedGetResponseErrorState(
        message: reason,
      ));
    }
  }
}

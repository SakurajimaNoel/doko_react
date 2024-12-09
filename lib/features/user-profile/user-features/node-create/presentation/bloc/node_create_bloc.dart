import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/domain/use-case/post-create-use-case/post_create_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/node_create_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'node_create_event.dart';
part 'node_create_state.dart';

class NodeCreateBloc extends Bloc<NodeCreateEvent, NodeCreateState> {
  final PostCreateUseCase _postCreateUseCase;

  NodeCreateBloc({
    required PostCreateUseCase postCreateUseCase,
  })  : _postCreateUseCase = postCreateUseCase,
        super(NodeCreateInitial()) {
    on<PostCreateEvent>(_handlePostCreateEvent);
  }

  FutureOr<void> _handlePostCreateEvent(
      PostCreateEvent event, Emitter<NodeCreateState> emit) async {
    try {
      emit(NodeCreateLoading());

      await _postCreateUseCase(event.postDetails);
      emit(NodeCreateSuccess());
    } on ApplicationException catch (e) {
      emit(NodeCreateError(
        message: e.reason,
      ));
    } catch (_) {
      emit(NodeCreateError(
        message: Constants.errorMessage,
      ));
    }
  }
}

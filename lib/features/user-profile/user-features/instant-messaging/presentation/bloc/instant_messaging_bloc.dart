import 'package:bloc/bloc.dart';
import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:equatable/equatable.dart';

part 'instant_messaging_event.dart';
part 'instant_messaging_state.dart';

class InstantMessagingBloc
    extends Bloc<InstantMessagingEvent, InstantMessagingState> {
  InstantMessagingBloc() : super(InstantMessagingInitial()) {
    on<InstantMessagingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}

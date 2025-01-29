import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/debounce/debounce.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/typing-status/typing_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TypingStatusWidgetWrapper extends StatefulWidget {
  const TypingStatusWidgetWrapper({
    super.key,
    required this.username,
    this.child,
  }) : canHide = false;

  const TypingStatusWidgetWrapper.canHide({
    super.key,
    required this.username,
    this.child,
  }) : canHide = true;

  final String username;

  /// will username be hidden when screen size become small
  final bool canHide;

  /// child will be rendered instead of typing when typing ends
  final Widget? child;

  @override
  State<TypingStatusWidgetWrapper> createState() =>
      _TypingStatusWidgetWrapperState();
}

class _TypingStatusWidgetWrapperState extends State<TypingStatusWidgetWrapper> {
  final typingStatusEndDebounce = Debounce(Constants.typingStatusEventDuration);

  @override
  void dispose() {
    typingStatusEndDebounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RealTimeBloc, RealTimeState>(
      listenWhen: (previousState, state) {
        return state is RealTimeTypingStatusState &&
            state.archiveUser == widget.username &&
            state.typing == true;
      },
      listener: (context, state) {
        // this will only work if start is called
        typingStatusEndDebounce(() {
          context.read<RealTimeBloc>().add(RealTimeTypingStatusEndEvent(
                username: widget.username,
              ));
        });
      },
      buildWhen: (previousState, state) {
        return state is RealTimeTypingStatusState &&
            state.archiveUser == widget.username;
      },
      builder: (context, state) {
        bool show = state is RealTimeTypingStatusState && state.typing;

        if (widget.canHide && show) {
          return TypingStatusWidget.canHide(
            username: widget.username,
          );
        }

        if (show) {
          return TypingStatusWidget(
            username: widget.username,
          );
        }

        return widget.child != null ? widget.child! : const SizedBox.shrink();
      },
    );
  }
}

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/utils/debounce/debounce.dart';
import 'package:doko_react/features/user-profile/bloc/real-time/real_time_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/instant-messaging/presentation/widgets/typing-status/typing_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TypingStatusWidgetWrapper extends StatefulWidget {
  const TypingStatusWidgetWrapper.sticker({
    super.key,
    required this.username,
    this.child,
  })  : sticker = true,
        text = false;

  const TypingStatusWidgetWrapper.text({
    super.key,
    required this.username,
    this.child,
  })  : text = true,
        sticker = false;

  final String username;

  /// sticker and text defines type of typing widget that will be displayed
  /// in case of sticker overlay will be there
  final bool sticker;
  final bool text;

  /// child will be rendered instead of typing when typing ends
  /// child will be present when it is rendered in inbox page
  final Widget? child;

  @override
  State<TypingStatusWidgetWrapper> createState() =>
      _TypingStatusWidgetWrapperState();
}

class _TypingStatusWidgetWrapperState extends State<TypingStatusWidgetWrapper> {
  final typingStatusEndDebounce = Debounce(Constants.typingStatusEventDuration);

  final link = LayerLink();
  final OverlayPortalController overlayPortalController =
      OverlayPortalController();

  @override
  void dispose() {
    typingStatusEndDebounce.dispose();

    if (widget.sticker && overlayPortalController.isShowing) {
      overlayPortalController.hide();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RealTimeBloc, RealTimeState>(
      listenWhen: (previousState, state) {
        return state is RealTimeTypingStatusState &&
            state.archiveUser == widget.username;
      },
      listener: (context, state) {
        if (state is RealTimeTypingStatusState && !state.typing) {
          if (overlayPortalController.isShowing) overlayPortalController.hide();
          return;
        }
        if (!overlayPortalController.isShowing && widget.sticker) {
          overlayPortalController.show();
        }

        // this will only work if start is called
        typingStatusEndDebounce(() {
          if (overlayPortalController.isShowing) {
            overlayPortalController.hide();
          }

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

        if (widget.text && show) {
          return TypingStatusWidget.text(
            username: widget.username,
          );
        }

        Widget child =
            widget.child == null ? const SizedBox.shrink() : widget.child!;

        return CompositedTransformTarget(
          link: link,
          child: OverlayPortal(
            controller: overlayPortalController,
            overlayChildBuilder: (context) {
              return CompositedTransformFollower(
                link: link,
                targetAnchor: Alignment.topLeft,
                followerAnchor: Alignment.bottomLeft,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: TypingStatusWidget.sticker(
                    username: widget.username,
                  ),
                ),
              );
            },
            child: child,
          ),
        );
      },
    );
  }
}

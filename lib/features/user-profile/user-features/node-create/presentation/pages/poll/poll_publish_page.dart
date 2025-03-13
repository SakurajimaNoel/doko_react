import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/global/provider/websocket-client/websocket_client_provider.dart';
import 'package:doko_react/core/utils/notifications/notifications.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/input/poll_create_input.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/bloc/node_create_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/node-create/presentation/widgets/users_tagged/users_tagged_widget.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PollPublishPage extends StatefulWidget {
  const PollPublishPage({
    super.key,
    required this.pollDetails,
  });

  final PollPublishPageData pollDetails;

  @override
  State<PollPublishPage> createState() => _PollPublishPageState();
}

class _PollPublishPageState extends State<PollPublishPage> {
  List<String> usersTagged = [];

  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Publish poll"),
      ),
      body: BlocProvider(
        create: (context) => serviceLocator<NodeCreateBloc>(),
        child: BlocConsumer<NodeCreateBloc, NodeCreateState>(
          listenWhen: (previousState, state) {
            return (state is NodeCreateSuccess || state is NodeCreateError);
          },
          listener: (context, state) {
            if (state is NodeCreateSuccess) {
              String message = "Successfully created new poll.";
              showSuccess(message);

              context.read<UserActionBloc>().add(
                    UserActionNewPollEvent(
                      pollId: state.nodeId,
                      username: username,
                      usersTagged: usersTagged,
                    ),
                  );

              // send to remote users
              final client = context.read<WebsocketClientProvider>().client;
              if (client != null && client.isActive) {
                // ignore if client is null
                UserCreateRootNode payload = UserCreateRootNode(
                  from: username,
                  id: state.nodeId,
                  nodeType: NodeType.poll,
                  usersTagged: usersTagged,
                );
                client.sendPayload(payload);
              }

              context.goNamed(RouterConstants.userFeed);
              return;
            }

            showError((state as NodeCreateError).message);
          },
          builder: (context, state) {
            bool uploading = state is NodeCreateLoading;

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: CompactBox(
                          child: Container(
                            padding: const EdgeInsets.all(Constants.padding),
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: UsersTaggedWidget(
                              onRemove: (String user) {
                                usersTagged.remove(user);
                              },
                              onSelected: (List<String> selected) {
                                usersTagged = selected;
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                CompactBox(
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.padding),
                    child: FilledButton(
                      onPressed: uploading
                          ? null
                          : () {
                              // call bloc
                              final pollInfo = widget.pollDetails;
                              final pollInput = PollCreateInput(
                                username: username,
                                question: pollInfo.question,
                                activeFor: pollInfo.activeFor,
                                options: pollInfo.options,
                                usersTagged: usersTagged,
                              );

                              context
                                  .read<NodeCreateBloc>()
                                  .add(PollCreateEvent(
                                    pollDetails: pollInput,
                                  ));
                            },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: uploading
                          ? const LoadingWidget.small()
                          : const Text("Upload"),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

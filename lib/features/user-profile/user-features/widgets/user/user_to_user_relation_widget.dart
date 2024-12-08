import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/helpers/relation/user_to_user_relation.dart';
import 'package:doko_react/features/user-profile/bloc/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserToUserRelationWidget extends StatefulWidget {
  const UserToUserRelationWidget({
    super.key,
    required this.username,
  }) : label = false;

  const UserToUserRelationWidget.label({
    super.key,
    required this.username,
  }) : label = true;

  final String username;
  final bool label;

  @override
  State<UserToUserRelationWidget> createState() =>
      _UserToUserRelationWidgetState();
}

class _UserToUserRelationWidgetState extends State<UserToUserRelationWidget> {
  bool updating = false;
  final UserGraph graph = UserGraph();

  late final String currentUsername;
  late final String username;
  late final String graphKey;
  late final bool label;

  @override
  void initState() {
    super.initState();

    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;
    username = widget.username;
    graphKey = generateUserNodeKey(username);
    label = widget.label;
  }

  // create
  void createFriendRelation() {
    if (updating) return;
    updating = true;

    final userActionBloc = context.read<UserActionBloc>();

    userActionBloc.add(UserActionCreateFriendRelationEvent(
      currentUsername: currentUsername,
      username: username,
    ));
  }

  // update
  void acceptFriendRelation(UserEntity user) {
    if (updating) return;
    updating = true;

    final userActionBloc = context.read<UserActionBloc>();
    userActionBloc.add(UserActionAcceptFriendRelationEvent(
      currentUsername: currentUsername,
      username: username,
      requestedBy: user.relationInfo!.requestedBy,
    ));
  }

  // delete
  void removeFriendRelation(UserEntity user) {
    if (updating) return;
    updating = true;

    final userActionBloc = context.read<UserActionBloc>();
    userActionBloc.add(UserActionRemoveFriendRelationEvent(
      currentUsername: currentUsername,
      username: username,
      requestedBy: user.relationInfo!.requestedBy,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    if (username == currentUsername) {
      return const SizedBox.shrink();
    }

    return BlocConsumer<UserActionBloc, UserActionState>(
      listenWhen: (previousState, state) {
        return (state is UserActionUserRelationState &&
            state.username == username);
      },
      listener: (BuildContext context, UserActionState state) {
        updating = false;
      },
      buildWhen: (previousState, state) {
        return (state is UserActionUserRelationState &&
                state.username == username) ||
            (state is UserActionUserRefreshState && state.username == username);
      },
      builder: (context, state) {
        final user = graph.getValueByKey(graphKey)! as UserEntity;
        final status = getUserToUserRelation(
          user.relationInfo,
          currentUsername: currentUsername,
        );

        // unrelated
        if (status == UserToUserRelation.unrelated) {
          if (label) {
            return FilledButton.tonalIcon(
              onPressed: () => createFriendRelation(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Add"),
            );
          }

          return IconButton(
            onPressed: () => createFriendRelation(),
            icon: Icon(
              Icons.person_add_alt_1,
              color: currTheme.primary,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: currTheme.primary,
              ),
            ),
          );
        }

        // outgoing req
        if (status == UserToUserRelation.outgoingReq) {
          if (label) {
            return FilledButton.tonalIcon(
              onPressed: () => removeFriendRelation(user),
              label: Text(
                "Cancel request",
                style: TextStyle(
                  color: currTheme.onError,
                ),
              ),
              icon: Icon(
                Icons.close,
                color: currTheme.onError,
              ),
              style: FilledButton.styleFrom(
                backgroundColor: currTheme.error,
              ),
            );
          }

          return IconButton(
            onPressed: () => removeFriendRelation(user),
            icon: Icon(
              Icons.close,
              color: currTheme.error,
            ),
            style: IconButton.styleFrom(
              side: BorderSide(
                color: currTheme.error,
              ),
            ),
          );
        }

        // incoming req
        if (status == UserToUserRelation.incomingReq) {
          if (label) {
            return Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => acceptFriendRelation(user),
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                ),
                const SizedBox(
                  width: Constants.gap,
                ),
                FilledButton.tonalIcon(
                  onPressed: () => removeFriendRelation(user),
                  label: Text(
                    "Cancel request",
                    style: TextStyle(
                      color: currTheme.onError,
                    ),
                  ),
                  icon: Icon(
                    Icons.close,
                    color: currTheme.onError,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: currTheme.error,
                  ),
                )
              ],
            );
          }

          return Row(
            children: [
              IconButton(
                onPressed: () => acceptFriendRelation(user),
                icon: Icon(
                  Icons.check,
                  color: currTheme.primary,
                ),
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: currTheme.primary,
                  ),
                ),
              ),
              const SizedBox(
                width: Constants.gap * 0.5,
              ),
              IconButton(
                onPressed: () => removeFriendRelation(user),
                icon: Icon(
                  Icons.close,
                  color: currTheme.error,
                ),
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: currTheme.error,
                  ),
                ),
              )
            ],
          );
        }

        // friends
        if (label) {
          return OutlinedButton.icon(
            onPressed: () => removeFriendRelation(user),
            icon: Icon(
              Icons.close,
              color: currTheme.error,
            ),
            label: Text(
              "Unfriend",
              style: TextStyle(
                color: currTheme.error,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: currTheme.error,
              ),
            ),
          );
        }

        return IconButton(
          onPressed: () => removeFriendRelation(user),
          icon: Icon(
            Icons.person_remove_alt_1,
            color: currTheme.error,
          ),
          style: IconButton.styleFrom(
            side: BorderSide(
              color: currTheme.error,
            ),
          ),
        );
      },
    );
  }
}

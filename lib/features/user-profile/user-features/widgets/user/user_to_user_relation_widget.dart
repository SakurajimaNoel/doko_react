import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/utils/relation/user_to_user_relation.dart';
import 'package:doko_react/features/user-profile/bloc/user-action/user_action_bloc.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserToUserRelationWidget extends StatefulWidget {
  const UserToUserRelationWidget({
    super.key,
    required this.username,
    this.disabled = false,
  })  : label = false,
        info = false;

  const UserToUserRelationWidget.label({
    super.key,
    required this.username,
    this.disabled = false,
  })  : label = true,
        info = false;

  const UserToUserRelationWidget.info({
    super.key,
    required this.username,
    this.disabled = false,
  })  : label = false,
        info = true;

  final String username;
  final bool label;
  final bool disabled;
  final bool info;

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
  late final bool label = widget.label;
  late final bool info = widget.info;
  late final bool disabled = widget.disabled;

  @override
  void initState() {
    super.initState();

    currentUsername =
        (context.read<UserBloc>().state as UserCompleteState).username;
    username = widget.username;
    graphKey = generateUserNodeKey(username);
  }

  // create
  void createFriendRelation() {
    if (updating || disabled) return;
    updating = true;

    final userActionBloc = context.read<UserActionBloc>();

    userActionBloc.add(UserActionCreateFriendRelationEvent(
      currentUsername: currentUsername,
      username: username,
    ));
  }

  // update
  void acceptFriendRelation(UserEntity user) {
    if (updating || disabled) return;
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
    if (updating || disabled) return;
    updating = true;

    final userActionBloc = context.read<UserActionBloc>();
    userActionBloc.add(UserActionRemoveFriendRelationEvent(
      currentUsername: currentUsername,
      username: username,
      requestedBy: user.relationInfo!.requestedBy,
    ));
  }

  void goToMessageArchive() {
    context.pushNamed(
      RouterConstants.messageArchive,
      pathParameters: {
        "username": username,
      },
    );
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

        bool disabled = false;
        if (state is UserActionUserRelationState) {
          disabled = (state.relation == UserToUserRelation.optimisticFriends) ||
              (state.relation == UserToUserRelation.optimisticOutgoingReq) ||
              (state.relation == UserToUserRelation.optimisticUnrelated);
        }

        // unrelated
        if (status == UserToUserRelation.unrelated) {
          if (info) {
            return Text(
                "You both don't have a friend relation with @$username.");
          }

          if (label) {
            return FilledButton.tonalIcon(
              onPressed: disabled ? null : () => createFriendRelation(),
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text("Add"),
            );
          }

          return IconButton.outlined(
            onPressed: disabled ? null : () => createFriendRelation(),
            color: currTheme.primary,
            icon: const Icon(
              Icons.person_add_alt_1,
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
          if (info) {
            return Text("You have send request to @$username.");
          }

          if (label) {
            return FilledButton.tonalIcon(
              onPressed: disabled ? null : () => removeFriendRelation(user),
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
            onPressed: disabled ? null : () => removeFriendRelation(user),
            color: currTheme.error,
            icon: const Icon(
              Icons.close,
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
          if (info) {
            return Text("@$username has send friend request to you.");
          }

          if (label) {
            return Row(
              spacing: Constants.gap,
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: disabled ? null : () => acceptFriendRelation(user),
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                ),
                FilledButton.tonalIcon(
                  onPressed: disabled ? null : () => removeFriendRelation(user),
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
            mainAxisSize: MainAxisSize.min,
            spacing: Constants.gap * 0.5,
            children: [
              IconButton(
                onPressed: disabled ? null : () => acceptFriendRelation(user),
                color: currTheme.primary,
                icon: const Icon(
                  Icons.check,
                ),
                style: IconButton.styleFrom(
                  side: BorderSide(
                    color: currTheme.primary,
                  ),
                ),
              ),
              IconButton(
                onPressed: disabled ? null : () => removeFriendRelation(user),
                color: currTheme.error,
                icon: const Icon(
                  Icons.close,
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
        if (info) {
          return Text("You and @$username are friends.");
        }

        if (label) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Constants.gap,
            children: [
              OutlinedButton.icon(
                onPressed: disabled ? null : () => removeFriendRelation(user),
                icon: Icon(
                  Icons.person_remove_alt_1,
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
              ),
              OutlinedButton.icon(
                onPressed: disabled ? null : goToMessageArchive,
                icon: const Icon(
                  Icons.chat_outlined,
                ),
                label: const Text(
                  "Message",
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: currTheme.primary,
                  ),
                ),
              ),
            ],
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Constants.gap * 0.5,
          children: [
            IconButton(
              onPressed: disabled ? null : () => removeFriendRelation(user),
              color: currTheme.error,
              icon: const Icon(
                Icons.person_remove_alt_1,
              ),
              style: IconButton.styleFrom(
                side: BorderSide(
                  color: currTheme.error,
                ),
              ),
            ),
            IconButton(
              onPressed: disabled ? null : goToMessageArchive,
              color: currTheme.primary,
              icon: const Icon(
                Icons.chat_outlined,
              ),
              style: IconButton.styleFrom(
                side: BorderSide(
                  color: currTheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

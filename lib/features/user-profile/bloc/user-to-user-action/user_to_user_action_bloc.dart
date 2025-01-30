import 'dart:async';
import 'dart:collection';

import 'package:doko_react/core/config/graphql/graphql_constants.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/core/utils/relation/user_to_user_relation.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_accepts_friend_relation_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_create_friend_relation_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/user-to-user-relation/user_remove_friend_relation_use_case.dart';
import 'package:doko_react/features/user-profile/domain/use-case/user/user_get.dart';
import 'package:doko_react/features/user-profile/input/user_profile_input.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/user-graph/user_graph.dart';

part 'user_to_user_action_event.dart';
part 'user_to_user_action_state.dart';

class UserToUserActionBloc
    extends Bloc<UserToUserActionEvent, UserToUserActionState> {
  final UserGraph graph = UserGraph();
  final Set<String> userToUserRelation = HashSet();
  final Set<String> getUserRequest = HashSet();

  final UserCreateFriendRelationUseCase _userCreateFriendRelationUseCase;
  final UserAcceptFriendRelationUseCase _userAcceptFriendRelationUseCase;
  final UserRemoveFriendRelationUseCase _userRemoveFriendRelationUseCase;
  final UserGetUseCase _userGetUseCase;

  UserToUserActionBloc({
    required UserCreateFriendRelationUseCase userCreateFriendRelationUseCase,
    required UserAcceptFriendRelationUseCase userAcceptFriendRelationUseCase,
    required UserRemoveFriendRelationUseCase userRemoveFriendRelationUseCase,
    required UserGetUseCase userGetUseCase,
  })  : _userCreateFriendRelationUseCase = userCreateFriendRelationUseCase,
        _userAcceptFriendRelationUseCase = userAcceptFriendRelationUseCase,
        _userRemoveFriendRelationUseCase = userRemoveFriendRelationUseCase,
        _userGetUseCase = userGetUseCase,
        super(UserToUserActionInitial()) {
    on<UserToUserUpdateProfileEvent>(_handleUserToUserUpdateProfileEvent);
    on<UserToUserActionFriendLoadEvent>(_handleUserToUserActionFriendLoadEvent);
    on<UserToUserActionCreateFriendRelationEvent>(
        _handleUserToUserActionCreateFriendRelationEvent);
    on<UserToUserActionAcceptFriendRelationEvent>(
        _handleUserToUserActionAcceptFriendRelationEvent);
    on<UserToUserActionRemoveFriendRelationEvent>(
        _handleUserToUserActionRemoveFriendRelationEvent);
    on<UserToUserActionUserRefreshEvent>(
        _handleUserToUserActionUserRefreshEvent);
    on<UserToUserActionGetUserByUsernameEvent>(
        _handleUserToUserActionGetUserByUsernameEvent);
  }

  FutureOr<void> _handleUserToUserUpdateProfileEvent(
      UserToUserUpdateProfileEvent event, Emitter<UserToUserActionState> emit) {
    emit(
      UserToUserActionUpdateProfileState(
        name: event.name,
        bio: event.bio,
        profilePicture: event.profilePicture,
      ),
    );
  }

  FutureOr<void> _handleUserToUserActionFriendLoadEvent(
      UserToUserActionFriendLoadEvent event,
      Emitter<UserToUserActionState> emit) {
    emit(
      UserToUserActionLoadFriendsState(
        loadedFriendsCount: event.friendsCount,
        username: event.username,
      ),
    );
  }

  FutureOr<void> _handleUserToUserActionCreateFriendRelationEvent(
      UserToUserActionCreateFriendRelationEvent event,
      Emitter<UserToUserActionState> emit) async {
    String currentUsername = event.currentUsername;
    String username = event.username;
    String setKey = "$currentUsername@$username";

    if (userToUserRelation.contains(setKey)) return;

    userToUserRelation.add(setKey);

    /// optimistically update only affected user relation status
    /// friends list, friends count and pending request list
    /// will be handled by data source
    String friendKey = generateUserNodeKey(event.username);
    final user = graph.getValueByKey(friendKey)! as UserEntity;

    final initRelation = user.relationInfo;

    try {
      UserToUserRelationDetails details = UserToUserRelationDetails(
        initiator: event.currentUsername,
        participant: event.username,
        username: event.username,
        currentUsername: event.currentUsername,
      );

      final tempRelation = UserRelationInfo(
        requestedBy: details.currentUsername,
        status: FriendStatus.pending,
        addedOn: DateTime.now(),
      );
      user.updateRelationInfo(tempRelation);
      emit(UserToUserActionUserRelationState(
        username: details.username,
        relation: UserToUserRelation.optimisticOutgoingReq,
      ));

      await _userCreateFriendRelationUseCase(details);

      emit(UserToUserActionUserRelationState(
        username: details.username,
        relation: UserToUserRelation.outgoingReq,
      ));

      // update current user pending list
      emit(UserToUserActionUpdateUserPendingFriendsListState(
        currentUsername: details.currentUsername,
        username: details.username,
      ));

      emit(UserToUserActionUpdateUserAcceptedFriendsListState(
        currentUsername: details.currentUsername,
        username: details.username,
      ));
    } catch (_) {
      // optimistic failure
      user.updateRelationInfo(initRelation);

      emit(UserToUserActionUserRelationState(
        username: event.username,
        relation: getUserToUserRelation(
          initRelation,
          currentUsername: event.currentUsername,
        ),
      ));
    }
    userToUserRelation.remove(setKey);
  }

  FutureOr<void> _handleUserToUserActionAcceptFriendRelationEvent(
      UserToUserActionAcceptFriendRelationEvent event,
      Emitter<UserToUserActionState> emit) async {
    String currentUsername = event.currentUsername;
    String username = event.username;
    String setKey = "$currentUsername@$username";

    if (userToUserRelation.contains(setKey)) return;

    userToUserRelation.add(setKey);

    /// optimistically update only affected user relation status
    /// friends list, friends count and pending request list
    /// will be handled by data source
    String friendKey = generateUserNodeKey(event.username);
    final user = graph.getValueByKey(friendKey)! as UserEntity;

    final initRelation = user.relationInfo;

    try {
      UserToUserRelationDetails details = UserToUserRelationDetails(
        initiator: event.requestedBy,
        participant: event.currentUsername,
        username: event.username,
        currentUsername: event.currentUsername,
      );
      final tempRelation = initRelation!.copyWith(
        status: FriendStatus.accepted,
      );
      user.updateRelationInfo(tempRelation);
      emit(UserToUserActionUserRelationState(
        username: details.username,
        relation: UserToUserRelation.optimisticFriends,
      ));

      await _userAcceptFriendRelationUseCase(details);

      emit(UserToUserActionUserRelationState(
        username: details.username,
        relation: UserToUserRelation.friends,
      ));

      // update current user friends list and involved user friends list
      emit(UserToUserActionUpdateUserPendingFriendsListState(
        currentUsername: details.currentUsername,
        username: details.username,
      ));

      emit(UserToUserActionUpdateUserAcceptedFriendsListState(
        currentUsername: details.currentUsername,
        username: details.username,
      ));
    } catch (_) {
      // optimistic failure
      user.updateRelationInfo(initRelation);

      emit(UserToUserActionUserRelationState(
        username: event.username,
        relation: getUserToUserRelation(
          initRelation,
          currentUsername: event.currentUsername,
        ),
      ));
    }
    userToUserRelation.remove(setKey);
  }

  FutureOr<void> _handleUserToUserActionRemoveFriendRelationEvent(
      UserToUserActionRemoveFriendRelationEvent event,
      Emitter<UserToUserActionState> emit) async {
    String currentUsername = event.currentUsername;
    String username = event.username;
    String setKey = "$currentUsername@$username";

    if (userToUserRelation.contains(setKey)) return;

    userToUserRelation.add(setKey);

    /// optimistically update only affected user relation status
    /// friends list, friends count and pending request list
    /// will be handled by data source
    String friendKey = generateUserNodeKey(event.username);
    final user = graph.getValueByKey(friendKey)! as UserEntity;

    final initRelation = user.relationInfo;

    try {
      UserToUserRelationDetails details = UserToUserRelationDetails(
        initiator: event.requestedBy,
        participant: event.requestedBy == event.username
            ? event.currentUsername
            : event.username,
        username: event.username,
        currentUsername: event.currentUsername,
      );

      user.updateRelationInfo(null);
      emit(UserToUserActionUserRelationState(
        username: details.username,
        relation: UserToUserRelation.optimisticUnrelated,
      ));

      await _userRemoveFriendRelationUseCase(details);

      emit(UserToUserActionUserRelationState(
        username: details.username,
        relation: UserToUserRelation.unrelated,
      ));

      // update current user pending list, current user friend list and involved user friend list
      emit(UserToUserActionUpdateUserPendingFriendsListState(
        currentUsername: details.currentUsername,
        username: details.username,
      ));

      emit(UserToUserActionUpdateUserAcceptedFriendsListState(
        currentUsername: details.currentUsername,
        username: details.username,
      ));
    } catch (_) {
      // optimistic failure
      user.updateRelationInfo(initRelation);

      emit(UserToUserActionUserRelationState(
        username: event.username,
        relation: getUserToUserRelation(
          initRelation,
          currentUsername: event.currentUsername,
        ),
      ));
    }
    userToUserRelation.remove(setKey);
  }

  FutureOr<void> _handleUserToUserActionUserRefreshEvent(
      UserToUserActionUserRefreshEvent event,
      Emitter<UserToUserActionState> emit) {
    emit(
      UserToUserActionUserRefreshState(
        username: event.username,
      ),
    );
  }

  FutureOr<void> _handleUserToUserActionGetUserByUsernameEvent(
      UserToUserActionGetUserByUsernameEvent event,
      Emitter<UserToUserActionState> emit) async {
    try {
      if (getUserRequest.contains(event.username)) return;

      String key = generateUserNodeKey(event.username);
      if (graph.containsKey(key)) return;

      getUserRequest.add(event.username);
      await _userGetUseCase(GetProfileInput(
        username: event.username,
        currentUsername: event.currentUser,
      ));

      emit(UserToUserActionUserDataFetchedState(
        username: event.username,
      ));
    } catch (_) {}

    getUserRequest.remove(event.username);
  }
}

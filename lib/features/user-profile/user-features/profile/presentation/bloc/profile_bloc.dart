import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/edit-profile-use-case/edit_profile_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/profile-use-case/profile_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-friends-use-case/user_friends_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-post-use-case/user_post_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserGraph graph = UserGraph();
  final ProfileUseCase _profileUseCase;
  final EditProfileUseCase _editProfileUseCase;
  final UserPostUseCase _userPostUseCase;
  final UserFriendsUseCase _userFriendsUseCase;

  ProfileBloc({
    required ProfileUseCase profileUseCase,
    required EditProfileUseCase editProfileUseCase,
    required UserPostUseCase userPostUseCase,
    required UserFriendsUseCase userFriendsUseCase,
  })  : _profileUseCase = profileUseCase,
        _editProfileUseCase = editProfileUseCase,
        _userPostUseCase = userPostUseCase,
        _userFriendsUseCase = userFriendsUseCase,
        super(ProfileInitial()) {
    on<GetUserProfileEvent>(_handleGetUserProfileEvent);
    on<EditUserProfileEvent>(_handleEditUserProfileEvent);
    on<LoadMoreProfilePostEvent>(_handleLoadMoreProfilePostEvent);
    on<GetUserFriendsEvent>(_handleGetUserFriendsEvent);
    on<LoadMoreProfileFriendsEvent>(_handleMoreProfileFriendsEvent);
    on<GetUserProfileRefreshEvent>(_handleGetUserProfileRefreshEvent);
    on<GetUserFriendsRefreshEvent>(_handleGetUserFriendsRefreshEvent);
  }

  FutureOr<void> _handleGetUserProfileEvent(
      GetUserProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.userDetails.username);
      if (graph.containsKey(userKey)) {
        // check if user exists
        final user = graph.getValueByKey(userKey)!;

        if (user is CompleteUserEntity) {
          emit(ProfileSuccess());
          return;
        }
      }

      emit(ProfileLoading());
      await _profileUseCase(event.userDetails);
      if (event.indirect) {
        add(GetUserFriendsEvent(
          userDetails: event.userDetails,
        ));
      } else {
        emit(ProfileSuccess());
      }
    } on ApplicationException catch (e) {
      emit(ProfileError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleEditUserProfileEvent(
      EditUserProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      emit(ProfileLoading());
      await _editProfileUseCase(event.editDetails);
      emit(ProfileEditSuccess());
    } on ApplicationException catch (e) {
      emit(ProfileError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleLoadMoreProfilePostEvent(
      LoadMoreProfilePostEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.postDetails.username);
      final CompleteUserEntity user =
          graph.getValueByKey(userKey)! as CompleteUserEntity;

      // load more post
      await _userPostUseCase(event.postDetails);
      emit(ProfilePostLoadSuccess(
        cursor: user.posts.pageInfo.endCursor,
      ));
    } on ApplicationException catch (e) {
      emit(ProfilePostLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfilePostLoadError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserFriendsEvent(
      GetUserFriendsEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.userDetails.username);
      if (graph.containsKey(userKey)) {
        // check if user exists
        final user = graph.getValueByKey(userKey)!;

        if (user is CompleteUserEntity && !user.friends.isEmpty) {
          emit(ProfileSuccess());
          return;
        }
      } else {
        // if user doesn't exist first fetch user
        add(GetUserProfileEvent(
          userDetails: event.userDetails,
          indirect: true,
        ));
        return;
      }

      emit(ProfileLoading());
      await _userFriendsUseCase(UserProfileNodesInput(
        username: event.userDetails.username,
        cursor: "",
        currentUsername: event.userDetails.currentUsername,
      ));
      emit(ProfileSuccess());
    } on ApplicationException catch (e) {
      emit(ProfileError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleMoreProfileFriendsEvent(
      LoadMoreProfileFriendsEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.friendDetails.username);
      final CompleteUserEntity user =
          graph.getValueByKey(userKey)! as CompleteUserEntity;

      // load more post
      await _userFriendsUseCase(event.friendDetails);
      emit(ProfileFriendLoadSuccess(
        cursor: user.friends.pageInfo.endCursor,
      ));
    } on ApplicationException catch (e) {
      emit(ProfileFriendLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileFriendLoadError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserProfileRefreshEvent(
      GetUserProfileRefreshEvent event, Emitter<ProfileState> emit) async {
    try {
      await _profileUseCase(event.userDetails);
      emit(ProfileSuccess());
    } on ApplicationException catch (e) {
      emit(ProfileRefreshError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileRefreshError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserFriendsRefreshEvent(
      GetUserFriendsRefreshEvent event, Emitter<ProfileState> emit) async {
    try {
      await _userFriendsUseCase(UserProfileNodesInput(
        username: event.userDetails.username,
        cursor: "",
        currentUsername: event.userDetails.currentUsername,
      ));
      emit(ProfileSuccess());
    } on ApplicationException catch (e) {
      emit(ProfileRefreshError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileRefreshError(
        message: Constants.errorMessage,
      ));
    }
  }
}

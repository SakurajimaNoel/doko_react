import 'dart:async';

import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/exceptions/application_exceptions.dart';
import 'package:doko_react/core/global/bloc/event_transformer.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';
import 'package:doko_react/features/user-profile/domain/user-graph/user_graph.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/edit-profile-use-case/edit_profile_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/pending-request-use-case/pending_incoming_request_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/pending-request-use-case/pending_outgoing_request_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/profile-use-case/profile_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-discussion-use-case/user_discussion_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-friends-use-case/user_friends_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-post-use-case/user_post_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/comments_mention_search_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/user_friend_search_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/domain/use-case/user-search-use-case/user_search_use_case.dart';
import 'package:doko_react/features/user-profile/user-features/profile/input/profile_input.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserGraph graph = UserGraph();
  final ProfileUseCase _profileUseCase;
  final EditProfileUseCase _editProfileUseCase;
  final UserPostUseCase _userPostUseCase;
  final UserDiscussionUseCase _userDiscussionUseCase;
  final UserFriendsUseCase _userFriendsUseCase;
  final UserSearchUseCase _userSearchUseCase;
  final UserFriendsSearchUseCase _userFriendsSearchUseCase;
  final PendingIncomingRequestUseCase _pendingIncomingRequestUseCase;
  final PendingOutgoingRequestUseCase _pendingOutgoingRequestUseCase;
  final CommentsMentionSearchUseCase _commentsMentionSearchUseCase;

  ProfileBloc({
    required ProfileUseCase profileUseCase,
    required EditProfileUseCase editProfileUseCase,
    required UserPostUseCase userPostUseCase,
    required UserDiscussionUseCase userDiscussionUseCase,
    required UserFriendsUseCase userFriendsUseCase,
    required UserSearchUseCase userSearchUseCase,
    required UserFriendsSearchUseCase userFriendsSearchUseCase,
    required PendingIncomingRequestUseCase pendingIncomingRequestUseCase,
    required PendingOutgoingRequestUseCase pendingOutgoingRequestUseCase,
    required CommentsMentionSearchUseCase commentMentionSearchUseCase,
  })  : _profileUseCase = profileUseCase,
        _editProfileUseCase = editProfileUseCase,
        _userPostUseCase = userPostUseCase,
        _userDiscussionUseCase = userDiscussionUseCase,
        _userFriendsUseCase = userFriendsUseCase,
        _userSearchUseCase = userSearchUseCase,
        _userFriendsSearchUseCase = userFriendsSearchUseCase,
        _pendingIncomingRequestUseCase = pendingIncomingRequestUseCase,
        _pendingOutgoingRequestUseCase = pendingOutgoingRequestUseCase,
        _commentsMentionSearchUseCase = commentMentionSearchUseCase,
        super(ProfileInitial()) {
    on<GetUserProfileEvent>(_handleGetUserProfileEvent);
    on<EditUserProfileEvent>(_handleEditUserProfileEvent);
    on<LoadMoreProfilePostEvent>(_handleLoadMoreProfilePostEvent);
    on<GetUserFriendsEvent>(_handleGetUserFriendsEvent);
    on<GetUserPostsEvent>(_handleGetUserPostsEvent);
    on<GetUserDiscussionEvent>(_handleGetUserDiscussionEvent);
    on<GetUserProfileRefreshEvent>(_handleGetUserProfileRefreshEvent);
    on<GetUserFriendsRefreshEvent>(_handleGetUserFriendsRefreshEvent);
    on<GetUserPostsRefreshEvent>(_handleGetUserPostsRefreshEvent);
    on<GetUserDiscussionRefreshEvent>(_handleGetUserDiscussionRefreshEvent);
    on<UserSearchEvent>(
      _handleUserSearchEvent,
      transformer: debounce(
        const Duration(
          milliseconds: 500,
        ),
      ),
    );
    on<UserFriendsSearchEvent>(
      _handleUserFriendsSearchEvent,
      transformer: debounce(
        const Duration(
          milliseconds: 500,
        ),
      ),
    );
    on<GetUserPendingIncomingRequest>(_handleGetUserPendingIncomingRequest);
    on<GetUserPendingOutgoingRequest>(_handleGetUserPendingOutgoingRequest);
    on<CommentMentionSearchEvent>(_handleCommentMentionSearchEvent);
  }

  FutureOr<void> _handleGetUserDiscussionEvent(
      GetUserDiscussionEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.userDetails.username);
      final user = graph.getValueByKey(userKey);

      // either user is not fetched or first time fetching user friends
      if (event.userDetails.cursor.isEmpty) {
        if (user is CompleteUserEntity) {
          // if user is already fetched check if friends exists or not
          if (user.discussions.isNotEmpty) {
            emit(ProfileSuccess());
            return;
          }
        } else {
          // fetch complete user
          add(GetUserProfileEvent(
            userDetails: event.userDetails,
            indirect: IndirectProfileFetch.discussions,
          ));
          return;
        }
      }

      if (event.userDetails.cursor.isEmpty) emit(ProfileLoading());
      await _userDiscussionUseCase(event.userDetails);

      // this handles initial success
      if (event.userDetails.cursor.isEmpty) emit(ProfileSuccess());

      emit(ProfileNodeLoadSuccess(
        cursor: event.userDetails.cursor,
      ));
    } on ApplicationException catch (e) {
      emit(ProfileNodeLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileNodeLoadError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserPostsEvent(
      GetUserPostsEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.userDetails.username);
      final user = graph.getValueByKey(userKey);

      // either user is not fetched or first time fetching user friends
      if (event.userDetails.cursor.isEmpty) {
        if (user is CompleteUserEntity) {
          // if user is already fetched check if friends exists or not
          if (user.posts.isNotEmpty) {
            emit(ProfileSuccess());
            return;
          }
        } else {
          // fetch complete user
          add(GetUserProfileEvent(
            userDetails: event.userDetails,
            indirect: IndirectProfileFetch.posts,
          ));
          return;
        }
      }

      if (event.userDetails.cursor.isEmpty) emit(ProfileLoading());
      await _userPostUseCase(event.userDetails);

      // this handles initial success
      if (event.userDetails.cursor.isEmpty) emit(ProfileSuccess());

      emit(ProfileNodeLoadSuccess(
        cursor: event.userDetails.cursor,
      ));
    } on ApplicationException catch (e) {
      emit(ProfileNodeLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileNodeLoadError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleCommentMentionSearchEvent(
      CommentMentionSearchEvent event, Emitter<ProfileState> emit) async {
    try {
      if (event.searchDetails.query.isEmpty) {
        final username = event.searchDetails.username;
        final userKey = generateUserNodeKey(username);
        final user = graph.getValueByKey(userKey);

        // this will check if user has friends fetched and user has friends
        if (user is CompleteUserEntity &&
            user.friends.isNotEmpty &&
            user.friends.items.isNotEmpty) {
          emit(CommentSearchSuccessState(
            query: event.searchDetails.query,
            searchResults: user.friends.items.toList(),
          ));
          return;
        }

        if (user is CompleteUserEntity && user.friends.isEmpty) {
          // not yet fetched
          emit(CommentSearchLoading());
          return;
        }

        // emitted when user has no friends and query is empty
        emit(ProfileInitial());
        return;
      }

      emit(CommentSearchLoading());
      final searchResults =
          await _commentsMentionSearchUseCase(event.searchDetails);

      emit(CommentSearchSuccessState(
        query: event.searchDetails.query,
        searchResults: searchResults,
      ));
    } on ApplicationException catch (e) {
      emit(CommentSearchErrorState(
        message: e.reason,
      ));
    } catch (_) {
      emit(CommentSearchErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserProfileEvent(
      GetUserProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      final userKey = generateUserNodeKey(event.userDetails.username);
      var indirect = event.indirect;

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
      if (indirect != IndirectProfileFetch.direct) {
        if (indirect == IndirectProfileFetch.friends) {
          add(GetUserFriendsEvent(
            userDetails: event.userDetails,
          ));
        }

        if (indirect == IndirectProfileFetch.posts) {
          add(GetUserPostsEvent(
            userDetails: event.userDetails,
          ));
        }
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

  // todo change this
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
      final user = graph.getValueByKey(userKey);

      // either user is not fetched or first time fetching user friends
      if (event.userDetails.cursor.isEmpty) {
        if (user is CompleteUserEntity) {
          // if user is already fetched check if friends exists or not
          if (user.friends.isNotEmpty) {
            add(CommentMentionSearchEvent(
              searchDetails: UserSearchInput(
                username: event.userDetails.currentUsername,
                query: "",
              ),
            ));
            emit(ProfileSuccess());

            return;
          }
        } else {
          // fetch complete user
          add(GetUserProfileEvent(
            userDetails: event.userDetails,
            indirect: IndirectProfileFetch.friends,
          ));
          return;
        }
      }

      if (event.userDetails.cursor.isEmpty) emit(ProfileLoading());

      await _userFriendsUseCase(event.userDetails);

      // this updates profile state too in case of loading friends
      add(CommentMentionSearchEvent(
        searchDetails: UserSearchInput(
          username: event.userDetails.currentUsername,
          query: "",
        ),
      ));

      emit(ProfileNodeLoadSuccess(
        cursor: event.userDetails.cursor,
      ));
    } on ApplicationException catch (e) {
      emit(ProfileNodeLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileNodeLoadError(
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
      await _userFriendsUseCase(event.userDetails);
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

  FutureOr<void> _handleGetUserPostsRefreshEvent(
      GetUserPostsRefreshEvent event, Emitter<ProfileState> emit) async {
    try {
      await _userPostUseCase(event.userDetails);
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

  FutureOr<void> _handleGetUserDiscussionRefreshEvent(
      GetUserDiscussionRefreshEvent event, Emitter<ProfileState> emit) async {
    try {
      await _userDiscussionUseCase(event.userDetails);
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

  FutureOr<void> _handleUserSearchEvent(
      UserSearchEvent event, Emitter<ProfileState> emit) async {
    try {
      if (event.searchDetails.query.isEmpty) {
        emit(ProfileInitial());
        return;
      }

      emit(ProfileUserSearchLoadingState());
      final searchResults = await _userSearchUseCase(event.searchDetails);

      emit(ProfileUserSearchSuccessState(
        searchResults: searchResults,
      ));
    } on ApplicationException catch (e) {
      emit(ProfileUserSearchErrorState(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileUserSearchErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleUserFriendsSearchEvent(
      UserFriendsSearchEvent event, Emitter<ProfileState> emit) async {
    try {
      if (event.searchDetails.query.isEmpty) {
        emit(ProfileSuccess());
        return;
      }
      emit(ProfileUserSearchLoadingState());
      final searchResults =
          await _userFriendsSearchUseCase(event.searchDetails);

      emit(ProfileUserSearchSuccessState(
        searchResults: searchResults,
      ));
    } on ApplicationException catch (e) {
      emit(ProfileUserSearchErrorState(
        message: e.reason,
      ));
    } catch (_) {
      emit(ProfileUserSearchErrorState(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserPendingIncomingRequest(
      GetUserPendingIncomingRequest event, Emitter<ProfileState> emit) async {
    try {
      String key = generatePendingIncomingReqKey();
      final nodes = graph.getValueByKey(key);

      if (!event.refetch &&
          nodes is Nodes &&
          nodes.isNotEmpty &&
          event.cursor.isEmpty) {
        emit(ProfileSuccess());
        return;
      }

      emit(ProfileLoading());
      await _pendingIncomingRequestUseCase(UserProfileNodesInput(
        username: event.username,
        cursor: "",
        currentUsername: event.username,
      ));
      emit(PendingRequestLoadSuccessState(
        cursor: event.cursor,
      ));
    } on ApplicationException catch (e) {
      emit(PendingRequestLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(PendingRequestLoadError(
        message: Constants.errorMessage,
      ));
    }
  }

  FutureOr<void> _handleGetUserPendingOutgoingRequest(
      GetUserPendingOutgoingRequest event, Emitter<ProfileState> emit) async {
    try {
      String key = generatePendingOutgoingReqKey();
      final nodes = graph.getValueByKey(key);

      if (!event.refetch &&
          nodes is Nodes &&
          nodes.isNotEmpty &&
          event.cursor.isEmpty) {
        emit(ProfileSuccess());
        return;
      }

      emit(ProfileLoading());
      await _pendingOutgoingRequestUseCase(UserProfileNodesInput(
        username: event.username,
        cursor: "",
        currentUsername: event.username,
      ));

      emit(PendingRequestLoadSuccessState(
        cursor: event.cursor,
      ));
    } on ApplicationException catch (e) {
      emit(PendingRequestLoadError(
        message: e.reason,
      ));
    } catch (_) {
      emit(PendingRequestLoadError(
        message: Constants.errorMessage,
      ));
    }
  }
}

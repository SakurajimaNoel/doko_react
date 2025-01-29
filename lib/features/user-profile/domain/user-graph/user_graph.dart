import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/core/utils/relation/user_to_user_relation.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/post/post_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/profile_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/user/user_entity.dart';

part "helper.dart";

/// single source of truth for any node information
class UserGraph {
  final Map<String, GraphEntity> _graph;

  // using hashmap because order preservation is not necessary
  UserGraph._internal() : _graph = HashMap();

  static UserGraph? _instance;

  factory UserGraph() {
    _instance ??= UserGraph._internal();
    return _instance!;
  }

  bool containsKey(String key) {
    return _graph.containsKey(key);
  }

  void reset() {
    _graph.clear();
  }

  /// this will be used to get the instance in widgets
  /// to display information
  /// keys are user:username, post:post_id, comment:comment_id
  GraphEntity? getValueByKey(String key) {
    return _graph[key];
  }

  void addEntity(String key, GraphEntity entity) {
    _graph[key] = entity;
  }

  void _addEntityMap(Map<String, GraphEntity> map) {
    _graph.addAll(map);
  }

  /// each individual operation will handle updating the graph
  /// to support their use case and needs
  // void updateValue(ValueSetter<Map<String, GraphEntity>> func) {
  //   func(_graph);
  // }

  /// application specific graph methods
  /// adding posts to user
  void addPostEntityListToUser(
    String username, {
    required List<PostEntity> newPosts,
    required PageInfo pageInfo,
  }) {
    String key = generateUserNodeKey(username);

    /// posts can only be added to complete user entity
    /// if user is null or not a instance of complete user entity
    /// than something is wrong and it will throw error while typecasting
    final CompleteUserEntity user = getValueByKey(key)! as CompleteUserEntity;

    // create temp map to hold all the posts in the map
    Map<String, GraphEntity> tempMap = HashMap();

    /// create list of individual post items key
    /// to store it in user posts
    List<String> postKeys = newPosts.map((postItem) {
      /// check if post already exists
      /// if already exists than just update meta data
      String postKey = generatePostNodeKey(postItem.id);
      PostEntity postToAdd;
      if (containsKey(postKey)) {
        final existsPost = getValueByKey(postKey)! as PostEntity;

        existsPost.updateCommentsCount(postItem.commentsCount);
        existsPost.updateUserLikes(postItem.userLike, postItem.likesCount);

        postToAdd = existsPost;
      } else {
        postToAdd = postItem;
      }

      // adding post entity
      tempMap[postKey] = postToAdd;

      return postKey;
    }).toList();

    // adding all posts to map
    _addEntityMap(tempMap);

    // updating user
    user.posts.addEntityItems(postKeys);
    user.posts.updatePageInfo(pageInfo);
  }

  /// adding newly added post to user
  void addPostEntityToUser(String username, PostEntity newPost) {
    String key = generateUserNodeKey(username);

    String postKey = generatePostNodeKey(newPost.id);
    addEntity(postKey, newPost);

    final user = getValueByKey(key)!;
    if (user is! CompleteUserEntity) return;

    // update user
    user.updatePostCount(user.postsCount + 1);
    user.posts.addItem(postKey);
  }

  /// adding friends to user
  void addUserFriendsListToUser(
    String username, {
    required List<UserEntity> newUsers,
    required PageInfo pageInfo,
  }) {
    String key = generateUserNodeKey(username);

    /// friends can only be added to complete user entity
    /// if user is null or not a instance of complete user entity
    /// than something is wrong and it will throw error while typecasting
    final CompleteUserEntity user = getValueByKey(key)! as CompleteUserEntity;

    // create temp map to hold all the posts in the map
    Map<String, GraphEntity> tempMap = HashMap();

    /// create list of individual friend items key
    /// to store it in user posts
    List<String> friendKeys = newUsers.map((userItem) {
      String userKey = generateUserNodeKey(userItem.username);

      /// check if its complete user entity
      /// if complete just update user relation
      /// and user entity values and rest same
      /// if user entity or null just add it
      if (containsKey(userKey) &&
          getValueByKey(userKey)! is CompleteUserEntity) {
        final completeUser = getValueByKey(userKey)! as CompleteUserEntity;
        tempMap[userKey] = completeUser.updateUserEntityValues(userItem);
      } else {
        tempMap[userKey] = userItem;
      }

      return userKey;
    }).toList();

    // adding all posts to map
    _addEntityMap(tempMap);

    // updating user
    user.friends.addEntityItems(friendKeys);
    user.friends.updatePageInfo(pageInfo);
  }

  /// used to update friends relation
  /// this will also be directly used
  void _updateFriendRelation(
      String friendUsername, UserRelationInfo? relationInfo) {
    String key = generateUserNodeKey(friendUsername);

    final friend = getValueByKey(key)! as UserEntity;
    friend.updateRelationInfo(relationInfo);
  }

  void sendRequest(String friendUsername, UserRelationInfo? relationInfo) {
    // add to outgoing req
    addOutgoingRequest(friendUsername);
    _updateFriendRelation(friendUsername, relationInfo);
  }

  // newly added friend when accepting request
  void addFriendToUser(
    String username, {
    required String friendUsername,
    required UserRelationInfo? relationInfo,
  }) {
    String key = generateUserNodeKey(username);
    String friendKey = generateUserNodeKey(friendUsername);

    // remove from incoming req
    _removeIncomingRequest(friendUsername);

    _updateFriendRelation(friendUsername, relationInfo);

    final user = getValueByKey(key)!;
    if (user is CompleteUserEntity) {
      // update user
      user.friends.addItem(friendKey);
      user.updateFriendsCount(user.friendsCount + 1);
    }

    final friend = getValueByKey(friendKey)!;
    if (friend is! CompleteUserEntity) return;

    // update friend
    friend.friends.addItem(key);
    friend.updateFriendsCount(friend.friendsCount + 1);
  }

  // remove friend
  void removeFriend(String username, String friendUsername) {
    String userKey = generateUserNodeKey(username);
    String friendKey = generateUserNodeKey(friendUsername);

    /// see if existing friends than remove
    /// using prevRelationInfo because of optimistic update
    bool friends = getUserToUserRelation(
          (getValueByKey(friendKey)! as UserEntity).prevRelationInfo,
          currentUsername: username,
        ) ==
        UserToUserRelation.friends;

    // remove from incoming and outgoing if present
    _removeIncomingRequest(friendUsername);
    _removeOutgoingRequest(friendUsername);

    _updateFriendRelation(friendUsername, null);

    // remove friend from friend list
    final user = getValueByKey(userKey)!;
    if (user is CompleteUserEntity) {
      user.friends.removeItem(friendKey);
      if (friends) user.updateFriendsCount(user.friendsCount - 1);
    }

    final friend = getValueByKey(friendKey)!;
    if (friend is! CompleteUserEntity) return;

    friend.friends.removeItem(userKey);
    if (friends) friend.updateFriendsCount(friend.friendsCount - 1);
  }

  void addOutgoingRequest(String friendUsername) {
    String key = generateUserNodeKey(friendUsername);

    // Todo: handle adding user if not present
    if (!containsKey(key)) return;

    String outgoingReqKey = generatePendingOutgoingReqKey();
    final outgoingReq = getValueByKey(outgoingReqKey);

    if (outgoingReq is Nodes) {
      outgoingReq.addItem(key);
    }
  }

  void addIncomingRequest(String friendUsername) {
    String key = generateUserNodeKey(friendUsername);

    // Todo: handle adding user if not present
    if (!containsKey(key)) return;

    String incomingReqKey = generatePendingIncomingReqKey();
    final incomingReq = getValueByKey(incomingReqKey);

    if (incomingReq is Nodes) {
      incomingReq.addItem(key);
    }
  }

  void _removeOutgoingRequest(String friendUsername) {
    String friendKey = generateUserNodeKey(friendUsername);
    String outgoingReqKey = generatePendingOutgoingReqKey();

    final outgoingReq = getValueByKey(outgoingReqKey);
    if (outgoingReq is Nodes) {
      outgoingReq.removeItem(friendKey);
    }
  }

  void _removeIncomingRequest(String friendUsername) {
    String friendKey = generateUserNodeKey(friendUsername);
    String incomingReqKey = generatePendingIncomingReqKey();

    final incomingReq = getValueByKey(incomingReqKey);
    if (incomingReq is Nodes) {
      incomingReq.removeItem(friendKey);
    }
  }

  void addPendingIncomingRequests(
      List<UserEntity> pendingIncomingRequest, PageInfo info) {
    String key = generatePendingIncomingReqKey();

    Map<String, GraphEntity> tempMap = HashMap();

    List<String> friendKeys = pendingIncomingRequest.map((userItem) {
      String userKey = generateUserNodeKey(userItem.username);

      if (containsKey(userKey) &&
          getValueByKey(userKey)! is CompleteUserEntity) {
        final completeUser = getValueByKey(userKey)! as CompleteUserEntity;
        tempMap[userKey] = completeUser.updateUserEntityValues(userItem);
      } else {
        tempMap[userKey] = userItem;
      }

      return userKey;
    }).toList();

    _addEntityMap(tempMap);

    if (!containsKey(key)) {
      addEntity(key, Nodes.empty());
    }

    Nodes items = getValueByKey(key)! as Nodes;
    items.addEntityItems(friendKeys);
    items.updatePageInfo(info);
  }

  void addPendingOutgoingRequests(
      List<UserEntity> pendingOutgoingRequest, PageInfo info) {
    String key = generatePendingOutgoingReqKey();

    Map<String, GraphEntity> tempMap = HashMap();

    List<String> friendKeys = pendingOutgoingRequest.map((userItem) {
      String userKey = generateUserNodeKey(userItem.username);

      if (containsKey(userKey) &&
          getValueByKey(userKey)! is CompleteUserEntity) {
        final completeUser = getValueByKey(userKey)! as CompleteUserEntity;
        tempMap[userKey] = completeUser.updateUserEntityValues(userItem);
      } else {
        tempMap[userKey] = userItem;
      }

      return userKey;
    }).toList();

    _addEntityMap(tempMap);

    if (!containsKey(key)) {
      addEntity(key, Nodes.empty());
    }

    Nodes items = getValueByKey(key)! as Nodes;
    items.addEntityItems(friendKeys);
    items.updatePageInfo(info);
  }

  // adding comment to post
  void addCommentListToPostEntity(
    String postId, {
    required List<CommentEntity> comments,
    required PageInfo pageInfo,
  }) {
    String key = generatePostNodeKey(postId);

    Map<String, GraphEntity> tempMap = HashMap();
    List<String> commentKeys = comments.map((commentItem) {
      String commentKey = generateCommentNodeKey(commentItem.id);
      // adding comment entity
      tempMap[commentKey] = commentItem;

      return commentKey;
    }).toList();

    _addEntityMap(tempMap);

    PostEntity post = getValueByKey(key)! as PostEntity;

    post.comments.updatePageInfo(pageInfo);
    post.comments.addEntityItems(commentKeys);
  }

  void addCommentToPostEntity(
    String postId, {
    required CommentEntity comment,
  }) {
    String key = generatePostNodeKey(postId);
    String commentKey = generateCommentNodeKey(comment.id);

    addEntity(commentKey, comment);

    if (!containsKey(key)) return;

    final PostEntity post = getValueByKey(key) as PostEntity;
    post.comments.addItem(commentKey);
    post.updateCommentsCount(post.commentsCount + 1);
  }

  void addCommentListToReply(
    String commentId, {
    required List<CommentEntity> comments,
    required PageInfo pageInfo,
  }) {
    String key = generateCommentNodeKey(commentId);

    Map<String, GraphEntity> tempMap = HashMap();
    List<String> commentKeys = comments.map((commentItem) {
      String commentKey = generateCommentNodeKey(commentItem.id);
      // adding comment entity
      tempMap[commentKey] = commentItem;

      return commentKey;
    }).toList();

    _addEntityMap(tempMap);

    CommentEntity comment = getValueByKey(key)! as CommentEntity;

    comment.comments.updatePageInfo(pageInfo);
    comment.comments.addEntityItems(commentKeys);
  }

  void addReplyToCommentEntity(
    String commentId, {
    required CommentEntity comment,
  }) {
    String key = generateCommentNodeKey(commentId);
    String commentKey = generateCommentNodeKey(comment.id);

    addEntity(commentKey, comment);

    if (!containsKey(key)) return;

    final CommentEntity existingComment = getValueByKey(key) as CommentEntity;
    existingComment.showReplies = true;

    // adding at the end of visible replies
    existingComment.comments.addItemAtLast(commentKey);
    existingComment.updateCommentsCount(existingComment.commentsCount + 1);
  }

  void handleUserLikeActionForPostEntity(
    String postId, {
    required bool userLike,
    required int likesCount,
    required int commentsCount,
  }) {
    String key = generatePostNodeKey(postId);

    if (!containsKey(key)) return;

    final post = getValueByKey(key) as PostEntity;
    post.updateUserLikes(userLike, likesCount);
    post.updateCommentsCount(commentsCount);
  }

  void handleUserLikeActionForCommentEntity(
    String commentId, {
    required bool userLike,
    required int likesCount,
    required int commentsCount,
  }) {
    String key = generateCommentNodeKey(commentId);

    if (!containsKey(key)) return;

    final comment = getValueByKey(key) as CommentEntity;
    comment.updateUserLikes(userLike, likesCount);
    comment.updateCommentsCount(commentsCount);
  }

  @override
  String toString() {
    return _graph.toString();
  }

  List<String> addUserSearchEntry(List<UserEntity> searchResults) {
    Map<String, GraphEntity> tempMap = HashMap();

    List<String> userKeys = searchResults.map((userItem) {
      String userKey = generateUserNodeKey(userItem.username);

      /// check if its complete user entity
      /// if complete just update user relation
      /// and user entity values and rest same
      /// if user entity or null just add it
      if (containsKey(userKey) &&
          getValueByKey(userKey)! is CompleteUserEntity) {
        final completeUser = getValueByKey(userKey)! as CompleteUserEntity;
        tempMap[userKey] = completeUser.updateUserEntityValues(userItem);
      } else {
        tempMap[userKey] = userItem;
      }

      return userKey;
    }).toList();

    _addEntityMap(tempMap);

    return userKeys;
  }

  /// instant messaging methods
  void _reorderUserInbox(String inboxItemKey) {
    // update user inbox
    InboxEntity inbox;
    String inboxKey = generateInboxKey();
    if (containsKey(inboxKey)) {
      inbox = getValueByKey(inboxKey)! as InboxEntity;
      inbox.reorder(inboxItemKey);
    } else {
      // create inbox
      inbox = InboxEntity.empty();
      inbox.addItems([inboxItemKey]);
    }

    addEntity(inboxKey, inbox);
  }

  void addNewMessage(ChatMessage message, String username) {
    // add new message
    String messageKey = generateMessageKey(message.id);
    MessageEntity messageEntity = MessageEntity(
      message: message,
    );

    addEntity(messageKey, messageEntity);

    String archiveUser = getUsernameFromMessageParams(
      username,
      to: message.to,
      from: message.from,
    );

    // update archive
    String archiveKey = generateArchiveKey(archiveUser);
    ArchiveEntity archiveEntity;
    if (!containsKey(archiveKey)) {
      archiveEntity = ArchiveEntity(
        archiveMessages: Nodes.empty(),
        currentSessionMessages: {messageKey},
      );
    } else {
      archiveEntity = getValueByKey(archiveKey)! as ArchiveEntity;
      archiveEntity.addCurrentSessionMessages(messageKey);
    }

    addEntity(archiveKey, archiveEntity);

    // update inbox item entity
    String inboxItemKey = generateInboxItemKey(archiveUser);

    InboxItemEntity inboxItem;
    if (!containsKey(inboxItemKey)) {
      // create inbox item entity
      inboxItem = InboxItemEntity(
        messages: Queue<String>(),
        activity: LatestActivity.empty(),
      );
    } else {
      inboxItem = getValueByKey(inboxItemKey)! as InboxItemEntity;
    }

    inboxItem.addNewMessage(messageKey, message.sendAt);
    addEntity(inboxItemKey, inboxItem);

    _reorderUserInbox(inboxItemKey);
  }

  void editMessage(EditMessage message, String username) {
    String archiveUser = getUsernameFromMessageParams(
      username,
      to: message.to,
      from: message.from,
    );
    bool self = username == message.from;

    // update inbox item entity
    String inboxItemKey = generateInboxItemKey(archiveUser);

    InboxItemEntity inboxItem;
    if (!containsKey(inboxItemKey)) {
      // create inbox item entity
      inboxItem = InboxItemEntity(
        messages: Queue<String>(),
        activity: LatestActivity.empty(),
      );
    } else {
      inboxItem = getValueByKey(inboxItemKey)! as InboxItemEntity;
    }

    InboxLastActivity activity =
        self ? InboxLastActivity.selfEdit : InboxLastActivity.remoteEdit;
    inboxItem.activity.updateLatestActivity(
      activity: activity,
      lastActivityTime: message.editedOn,
    );
    addEntity(inboxItemKey, inboxItem);

    // update inbox order
    _reorderUserInbox(inboxItemKey);

    // update message entity
    String messageKey = generateMessageKey(message.id);
    if (!containsKey(messageKey)) return;

    final messageEntity = getValueByKey(messageKey)! as MessageEntity;
    messageEntity.editMessage(message);

    addEntity(messageKey, messageEntity);
  }

  void deleteMessage(DeleteMessage message, String username) {
    String archiveUser = getUsernameFromMessageParams(
      username,
      to: message.to,
      from: message.from,
    );
    bool self = username == message.from;
    // if delete for everyone update inbox status too
    if (message.everyone) {
      // update inbox item entity
      String inboxItemKey = generateInboxItemKey(archiveUser);

      InboxItemEntity inboxItem;
      InboxLastActivity activity = self
          ? InboxLastActivity.selfDeleteAll
          : InboxLastActivity.remoteDeleteAll;
      if (!containsKey(inboxItemKey)) {
        // create inbox item entity
        inboxItem = InboxItemEntity(
          messages: Queue<String>(),
          activity: LatestActivity.empty(),
        );
      } else {
        inboxItem = getValueByKey(inboxItemKey)! as InboxItemEntity;
      }

      inboxItem.activity.updateLatestActivity(
        activity: activity,
      );
      addEntity(inboxItemKey, inboxItem);

      // update inbox order
      _reorderUserInbox(inboxItemKey);
    }

    for (String messageId in message.id) {
      String messageKey = generateMessageKey(messageId);
      if (!containsKey(messageKey)) continue;

      final messageEntity = getValueByKey(messageKey)! as MessageEntity;
      messageEntity.deleteMessage();

      addEntity(messageKey, messageEntity);

      // remove from list too
      String archiveKey = generateArchiveKey(archiveUser);
      if (!containsKey(archiveKey)) return;

      final archiveEntity = getValueByKey(archiveKey)! as ArchiveEntity;
      archiveEntity.removeMessage(messageKey);
    }
  }
}

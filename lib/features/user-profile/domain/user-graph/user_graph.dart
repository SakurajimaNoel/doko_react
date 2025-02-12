import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
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

  /// returns a singleton instance during lifecycle of application
  factory UserGraph() {
    _instance ??= UserGraph._internal();
    return _instance!;
  }

  /// used to check if the given entity exists or not
  bool containsKey(String key) {
    return _graph.containsKey(key);
  }

  /// reset graph during exist and sign out
  void reset() {
    _graph.clear();
  }

  /// this will be used to get the instance in widgets
  /// to display information
  /// keys are user:username, post:post_id, comment:comment_id
  GraphEntity? getValueByKey(String key) {
    return _graph[key];
  }

  /// basic function to add any entity by key
  void addEntity(String key, GraphEntity entity) {
    _graph[key] = entity;
  }

  /// basic function to add map to userGraph
  /// this is used where list of items are added to the graph
  /// like user root nodes list, root nodes comments and comments replies
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
        existsPost.updateLikeCount(postItem.likesCount);
        existsPost.updateUserLikeStatus(postItem.userLike);

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

    final friend = getValueByKey(key);
    if (friend is UserEntity) {
      friend.updateRelationInfo(relationInfo);
    }
  }

  /// used when sending request
  void sendRequest(
    String username, {
    required String friendUsername,
    UserRelationInfo? relationInfo,
  }) {
    // add to outgoing req
    _addOutgoingRequest(friendUsername);
    _updateFriendRelation(friendUsername, relationInfo);

    // remove from friend list
    _removeFromFriendList(username, friendUsername);
  }

  /// used with remote friend request received
  void receiveRequest(
    String username, {
    required String friendUsername,
    UserRelationInfo? relationInfo,
  }) {
    // add to incoming req
    _addIncomingRequest(friendUsername);
    _updateFriendRelation(friendUsername, relationInfo);

    // remove from friend list
    _removeFromFriendList(username, friendUsername);
  }

  // newly added friend when accepting request or when remote accepting request
  void addFriendToUser(
    String username, {
    required String friendUsername,
    required UserRelationInfo? relationInfo,
  }) {
    String key = generateUserNodeKey(username);
    String friendKey = generateUserNodeKey(friendUsername);

    // remove from pending req
    _removeIncomingRequest(friendUsername);
    _removeOutgoingRequest(friendUsername);

    _updateFriendRelation(friendUsername, relationInfo);

    final user = getValueByKey(key)!;
    if (user is CompleteUserEntity) {
      // update user
      user.friends.addItem(friendKey);
      user.updateFriendsCount(user.friendsCount + 1);
    }

    final friend = getValueByKey(friendKey)!;
    if (friend is CompleteUserEntity) {
      // update friend
      friend.friends.addItem(key);
      friend.updateFriendsCount(friend.friendsCount + 1);
    }
  }

  // remove friend
  void removeFriend(String username, String friendUsername) {
    // remove from incoming and outgoing if present
    _removeIncomingRequest(friendUsername);
    _removeOutgoingRequest(friendUsername);
    _removeFromFriendList(username, friendUsername);

    _updateFriendRelation(friendUsername, null);
  }

  /// add user to outgoing friend request list
  void _addOutgoingRequest(String friendUsername) {
    String key = generateUserNodeKey(friendUsername);

    // if user is not present user widget will handle fetching of user
    // if (!containsKey(key)) return;

    String outgoingReqKey = generatePendingOutgoingReqKey();
    final outgoingReq = getValueByKey(outgoingReqKey);

    if (outgoingReq is Nodes) {
      outgoingReq.addItem(key);
    }
  }

  /// add user to incoming friend request list
  void _addIncomingRequest(String friendUsername) {
    String key = generateUserNodeKey(friendUsername);

    // if user is not present user widget will handle fetching of user
    // if (!containsKey(key)) return;

    String incomingReqKey = generatePendingIncomingReqKey();
    final incomingReq = getValueByKey(incomingReqKey);

    if (incomingReq is Nodes) {
      incomingReq.addItem(key);
    }
  }

  /// remove friend from users friend list and friends friend list
  void _removeFromFriendList(String username, String friendUsername) {
    String userKey = generateUserNodeKey(username);
    String friendKey = generateUserNodeKey(friendUsername);

    final userEntity = getValueByKey(userKey);
    final friendEntity = getValueByKey(friendKey);

    if (userEntity is CompleteUserEntity) {
      if (userEntity.friends.items.contains(friendKey)) {
        userEntity.updateFriendsCount(userEntity.friendsCount - 1);
      }
      userEntity.friends.removeItem(friendKey);
    }

    if (friendEntity is CompleteUserEntity) {
      if (friendEntity.friends.items.contains(userKey)) {
        friendEntity.updateFriendsCount(friendEntity.friendsCount - 1);
      }
      friendEntity.friends.removeItem(userKey);
    }
  }

  /// remove outgoing friend request from outgoing friend list
  void _removeOutgoingRequest(String friendUsername) {
    String friendKey = generateUserNodeKey(friendUsername);
    String outgoingReqKey = generatePendingOutgoingReqKey();

    final outgoingReq = getValueByKey(outgoingReqKey);
    if (outgoingReq is Nodes) {
      outgoingReq.removeItem(friendKey);
    }
  }

  /// remove incoming friend request from incoming friend list
  void _removeIncomingRequest(String friendUsername) {
    String friendKey = generateUserNodeKey(friendUsername);
    String incomingReqKey = generatePendingIncomingReqKey();

    final incomingReq = getValueByKey(incomingReqKey);
    if (incomingReq is Nodes) {
      incomingReq.removeItem(friendKey);
    }
  }

  /// used when fetching user incoming request
  /// in pending requests page
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

  /// used to fetch users outgoing requests
  /// used in pending requests page
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

  /// adding comment list to post
  /// used when fetching post comments
  void addCommentListToPostEntity(
    String postId, {
    required List<CommentEntity> comments,
    required PageInfo pageInfo,
  }) {
    String key = generatePostNodeKey(postId);

    Map<String, GraphEntity> tempMap = HashMap();
    List<String> commentKeys = comments.map((commentItem) {
      String commentKey = generateCommentNodeKey(commentItem.id);
      CommentEntity commentToAdd;

      if (containsKey(commentKey)) {
        final existsComment = getValueByKey(commentKey)! as CommentEntity;

        existsComment.updateCommentsCount(commentItem.commentsCount);
        existsComment.updateLikeCount(commentItem.likesCount);
        existsComment.updateUserLikeStatus(commentItem.userLike);

        commentToAdd = existsComment;
      } else {
        commentToAdd = commentItem;
      }

      // adding comment entity
      tempMap[commentKey] = commentToAdd;
      return commentKey;
    }).toList();

    _addEntityMap(tempMap);

    PostEntity post = getValueByKey(key)! as PostEntity;

    post.comments.updatePageInfo(pageInfo);
    post.comments.addEntityItems(commentKeys);
  }

  /// used to add single comment to post entity
  /// used when creating new comment
  void addCommentToPostEntity(
    String postId, {
    required CommentEntity comment,
  }) {
    String key = generatePostNodeKey(postId);
    String commentKey = generateCommentNodeKey(comment.id);

    addEntity(commentKey, comment);

    final post = getValueByKey(key);

    if (post is! PostEntity) return;

    post.comments.addItem(commentKey);
    post.updateCommentsCount(post.commentsCount + 1);
  }

  /// this is used by remote secondary node create payload
  void addCommentIdToPostEntity(
    String postId, {
    required String commentId,
  }) {
    String key = generatePostNodeKey(postId);
    String commentKey = generateCommentNodeKey(commentId);

    final post = getValueByKey(key);

    if (post is! PostEntity) return;

    post.updateCommentsCount(post.commentsCount + 1);

    /// no need to add comment if not fetched
    if (post.comments.isEmpty) return;

    post.comments.addItem(commentKey);
  }

  /// used to add comments replies when fetching it in comment's page
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

  /// used to add new reply to the comment
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

  /// used by remote create secondary node
  void addReplyIdToCommentEntity(
    String commentId, {
    required String replyId,
  }) {
    String key = generateCommentNodeKey(commentId);
    String replyKey = generateCommentNodeKey(replyId);

    final comment = getValueByKey(key);

    if (comment is! CommentEntity) return;

    comment.updateCommentsCount(comment.commentsCount + 1);

    /// no need to add it if no replies are fetched
    /// or not reached end of page
    if (comment.comments.isEmpty || comment.comments.pageInfo.hasNextPage) {
      return;
    }

    comment.comments.addItemAtLast(replyKey);
  }

  /// used update post like status and post stats
  void handleUserLikeActionForPostEntity(
    String postId, {
    bool? userLike,
    required int likesCount,
    required int commentsCount,
  }) {
    String key = generatePostNodeKey(postId);

    if (!containsKey(key)) return;

    final post = getValueByKey(key) as PostEntity;
    post.updateLikeCount(likesCount);
    if (userLike != null) {
      post.updateUserLikeStatus(userLike);
    }
    post.updateCommentsCount(commentsCount);
  }

  /// used to update comment like status and comment stats
  void handleUserLikeActionForCommentEntity(
    String commentId, {
    bool? userLike,
    required int likesCount,
    required int commentsCount,
  }) {
    String key = generateCommentNodeKey(commentId);

    if (!containsKey(key)) return;

    final comment = getValueByKey(key) as CommentEntity;
    if (userLike != null) comment.updateUserLikeStatus(userLike);
    comment.updateLikeCount(likesCount);
    comment.updateCommentsCount(commentsCount);
  }

  @override
  String toString() {
    return _graph.toString();
  }

  /// add fetched users to graph based on search query
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

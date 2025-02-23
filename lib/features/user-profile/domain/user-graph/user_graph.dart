import 'dart:collection';

import 'package:doki_websocket_client/doki_websocket_client.dart';
import 'package:doko_react/core/global/entity/node-type/doki_node_type.dart';
import 'package:doko_react/core/global/entity/page-info/nodes.dart';
import 'package:doko_react/core/global/entity/page-info/page_info.dart';
import 'package:doko_react/core/global/entity/user-relation-info/user_relation_info.dart';
import 'package:doko_react/features/user-profile/domain/entity/comment/comment_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/discussion/discussion_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/archive_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/archive/message_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/instant-messaging/inbox/inbox_item_entity.dart';
import 'package:doko_react/features/user-profile/domain/entity/poll/poll_entity.dart';
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

  void addContentEntityToUser(
    String username, {
    required PageInfo pageInfo,
    required List<String> content,
  }) {
    String key = generateUserNodeKey(username);
    final CompleteUserEntity user = getValueByKey(key)! as CompleteUserEntity;

    user.timeline.updatePageInfo(pageInfo);
    user.timeline.addEntityItems(content);
  }

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
    if (user is CompleteUserEntity) {
      // update user
      user.updatePostCount(user.postsCount + 1);
      user.posts.addItem(postKey);

      user.timeline.addItem(postKey);
    }

    addPostToTaggedUser(
      newPost.usersTagged,
      postKey: postKey,
    );
  }

  void addPostToTaggedUser(
    List<UsersTagged> usersTagged, {
    required String postKey,
  }) {
    // add to tagged user timeline
    for (UsersTagged user in usersTagged) {
      final username = user.username;

      String userKey = generateUserNodeKey(username);
      final userEntity = getValueByKey(userKey);

      if (userEntity is CompleteUserEntity) {
        userEntity.timeline.addItem(postKey);
      }
    }
  }

  void addDiscussionEntityListToUser(
    String username, {
    required List<DiscussionEntity> newDiscussions,
    required PageInfo pageInfo,
  }) {
    String key = generateUserNodeKey(username);

    final CompleteUserEntity user = getValueByKey(key)! as CompleteUserEntity;

    Map<String, GraphEntity> tempMap = HashMap();

    List<String> discussionKeys = newDiscussions.map((discussionItem) {
      String discussionKey = generateDiscussionNodeKey(discussionItem.id);
      DiscussionEntity discussionToAdd;
      if (containsKey(discussionKey)) {
        final existsDiscussion =
            getValueByKey(discussionKey)! as DiscussionEntity;

        existsDiscussion.updateCommentsCount(discussionItem.commentsCount);
        existsDiscussion.updateLikeCount(discussionItem.likesCount);
        existsDiscussion.updateUserLikeStatus(discussionItem.userLike);

        discussionToAdd = existsDiscussion;
      } else {
        discussionToAdd = discussionItem;
      }

      // adding post entity
      tempMap[discussionKey] = discussionToAdd;

      return discussionKey;
    }).toList();

    // adding all posts to map
    _addEntityMap(tempMap);

    // updating user
    user.discussions.addEntityItems(discussionKeys);
    user.discussions.updatePageInfo(pageInfo);
  }

  // add  new discussion
  void addDiscussionEntityToUser(
      String username, DiscussionEntity newDiscussion) {
    String key = generateUserNodeKey(username);

    String discussionKey = generateDiscussionNodeKey(newDiscussion.id);
    addEntity(discussionKey, newDiscussion);

    final user = getValueByKey(key)!;
    if (user is CompleteUserEntity) {
      // update user
      user.updateDiscussionCount(user.discussionCount + 1);
      user.discussions.addItem(discussionKey);

      user.timeline.addItem(discussionKey);
    }

    addDiscussionToTaggedUser(
      newDiscussion.usersTagged,
      discussionKey: discussionKey,
    );
  }

  void addDiscussionToTaggedUser(
    List<UsersTagged> usersTagged, {
    required String discussionKey,
  }) {
    // add to tagged user timeline
    for (UsersTagged user in usersTagged) {
      final username = user.username;
      String userKey = generateUserNodeKey(username);
      final userEntity = getValueByKey(userKey);

      if (userEntity is CompleteUserEntity) {
        userEntity.timeline.addItem(discussionKey);
      }
    }
  }

  void addPollEntityListToUser(
    String username, {
    required List<PollEntity> newPolls,
    required PageInfo pageInfo,
  }) {
    String key = generateUserNodeKey(username);

    final CompleteUserEntity user = getValueByKey(key)! as CompleteUserEntity;

    Map<String, GraphEntity> tempMap = HashMap();

    List<String> pollKeys = newPolls.map((pollItem) {
      String pollKey = generatePollNodeKey(pollItem.id);
      PollEntity pollToAdd;
      if (containsKey(pollKey)) {
        final existsPoll = getValueByKey(pollKey)! as PollEntity;

        existsPoll.updateCommentsCount(pollItem.commentsCount);
        existsPoll.updateLikeCount(pollItem.likesCount);
        existsPoll.updateUserLikeStatus(pollItem.userLike);

        pollToAdd = existsPoll;
      } else {
        pollToAdd = pollItem;
      }

      // adding post entity
      tempMap[pollKey] = pollToAdd;

      return pollKey;
    }).toList();

    // adding all posts to map
    _addEntityMap(tempMap);

    // updating user
    user.polls.addEntityItems(pollKeys);
    user.polls.updatePageInfo(pageInfo);
  }

  // add  new poll
  void addPollEntityToUser(String username, PollEntity newPoll) {
    String key = generateUserNodeKey(username);

    String pollKey = generatePollNodeKey(newPoll.id);
    addEntity(pollKey, newPoll);

    final user = getValueByKey(key)!;
    if (user is CompleteUserEntity) {
      // update user
      user.updatePollCount(user.pollCount + 1);
      user.polls.addItem(pollKey);

      user.timeline.addItem(pollKey);
    }

    addPollToTaggedUser(
      newPoll.usersTagged,
      pollKey: pollKey,
    );
  }

  void addPollToTaggedUser(
    List<UsersTagged> usersTagged, {
    required String pollKey,
  }) {
    // add to tagged user timeline
    for (UsersTagged user in usersTagged) {
      final username = user.username;
      String userKey = generateUserNodeKey(username);
      final userEntity = getValueByKey(userKey);

      if (userEntity is CompleteUserEntity) {
        userEntity.timeline.addItem(pollKey);
      }
    }
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

  /// adding comment list to post, discussion, polls
  /// used when fetching post comments
  void addCommentListToPrimaryNode(
    String key, {
    required List<CommentEntity> comments,
    required PageInfo pageInfo,
  }) {
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

    final node = getValueByKey(key);

    if (node is! GraphEntityWithUserAction) return;

    node.comments.updatePageInfo(pageInfo);
    node.comments.addEntityItems(commentKeys);
  }

  /// used to add single comment to post, discussion, polls
  /// used when creating new comment
  void addCommentToPrimaryNode(
    String key, {
    required CommentEntity comment,
    bool isReply = false,
  }) {
    String commentKey = generateCommentNodeKey(comment.id);

    addEntity(commentKey, comment);

    final node = getValueByKey(key);

    if (node is! GraphEntityWithUserAction) return;

    if (isReply) {
      node.comments.addItemAtLast(commentKey);
    } else {
      node.comments.addItem(commentKey);
    }
    node.updateCommentsCount(node.commentsCount + 1);
  }

  /// this is used by remote secondary node create payload
  void addCommentIdToPrimaryNode(
    String key, {
    required String commentId,
    bool isReply = false,
  }) {
    String commentKey = generateCommentNodeKey(commentId);

    final node = getValueByKey(key);

    if (node is! GraphEntityWithUserAction) return;

    if (!node.comments.items.contains(commentKey)) {
      node.updateCommentsCount(node.commentsCount + 1);
    }

    /// no need to add comment if not fetched
    if (node.comments.isEmpty) return;

    if (isReply) {
      node.comments.addItemAtLast(commentKey);
    } else {
      node.comments.addItem(commentKey);
    }
  }

  /// used update node like status and node stats
  void handleUserLikeAction({
    required String nodeKey,
    bool? userLike,
    required int likesCount,
    required int commentsCount,
  }) {
    final node = getValueByKey(nodeKey);

    if (node is! GraphEntityWithUserAction) return;

    node.updateCommentsCount(commentsCount);
    if (userLike != null) node.updateUserLikeStatus(userLike);
    node.updateLikeCount(likesCount);
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

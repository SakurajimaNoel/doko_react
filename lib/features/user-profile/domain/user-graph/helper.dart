part of "user_graph.dart";

// functions to generate keys
// user
String generateUserNodeKey(String username) {
  return "user:$username";
}

String getUsernameFromUserKey(String userKey) {
  return userKey.substring(5);
}

// post
String generatePostNodeKey(String postId) {
  return "post:$postId";
}

String getPostIdFromPostKey(String postKey) {
  return postKey.substring(5);
}

// comment
String generateCommentNodeKey(String commentId) {
  return "comment:$commentId";
}

String getCommentIdFromCommentKey(String commentKey) {
  return commentKey.substring(8);
}

// discussion
String generateDiscussionNodeKey(String discussionId) {
  return "discussion:$discussionId";
}

String getDiscussionIdFromDiscussionKey(String discussionKey) {
  return discussionKey.substring(11);
}

// polls
String generatePollNodeKey(String pollId) {
  return "poll:$pollId";
}

String getPollIdFromPollKey(String pollKey) {
  return pollKey.substring(5);
}

// inbox
String generatePendingIncomingReqKey() {
  return "pending-incoming-request";
}

String generatePendingOutgoingReqKey() {
  return "pending-outgoing-request";
}

String generateInboxKey() {
  return "user-inbox";
}

String generateInboxItemKey(String username) {
  return "inbox:$username";
}

String getUsernameFromInboxItemKey(String inboxKey) {
  return inboxKey.substring(6);
}

String generateArchiveKey(String username) {
  return "archive:$username";
}

String getUsernameFromArchiveKey(String archiveKey) {
  return archiveKey.substring(8);
}

String generateMessageKey(String messageId) {
  return "message:$messageId";
}

String getMessageIdFromMessageKey(String messageKey) {
  return messageKey.substring(8);
}

String generateUserFeedKey() {
  return "user-feed";
}

/// function to get inbox item key from message
String getUsernameFromMessageParams(
  String username, {
  required String to,
  required String from,
}) {
  return username == from ? to : from;
}

// function to get key from nodeType and identifier
String generateGraphKey(NodeType type, String identifier) {
  DokiNodeType dokiNodeType = DokiNodeType.fromNodeType(type);
  return dokiNodeType.keyGenerator(identifier);
}

DokiNodeType? getNodeTypeFromKey(String key) {
  if (key.startsWith("post")) return DokiNodeType.post;
  if (key.startsWith("poll")) return DokiNodeType.poll;
  if (key.startsWith("comment")) return DokiNodeType.comment;
  if (key.startsWith("discussion")) return DokiNodeType.discussion;
  if (key.startsWith("user")) return DokiNodeType.user;
  return null;
  // if(key.startsWith("page")) return DokiNodeType.page;
}

// helper function to create message archive from sender and recipient
String createMessageArchiveKey(String userA, String userB) {
  if (userA.compareTo(userB) <= 0) {
    return '$userA@$userB';
  } else {
    return '$userB@$userA';
  }
}

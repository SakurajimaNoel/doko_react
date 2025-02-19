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

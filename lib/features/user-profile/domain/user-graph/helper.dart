part of "user_graph.dart";

// functions to generate keys
String generateUserNodeKey(String username) {
  return "user:$username";
}

String getUsernameFromUserKey(String userKey) {
  return userKey.substring(5);
}

String generatePostNodeKey(String postId) {
  return "post:$postId";
}

String getPostIdFromPostKey(String postKey) {
  return postKey.substring(5);
}

String generateCommentNodeKey(String commentId) {
  return "comment:$commentId";
}

String getCommentIdFromCommentKey(String commentKey) {
  return commentKey.substring(8);
}

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

String generateArchiveItemKey(String username) {
  return "archive:$username";
}

String getUsernameFromArchiveKey(String archiveKey) {
  return archiveKey.substring(8);
}

import 'package:doko_react/features/user-profile/input/user_profile_input.dart';

abstract class UserProfileRepository {
  Future<bool> userAddPostLike(String postId, String username);

  Future<bool> userRemovePostLike(String postId, String username);

  Future<bool> userAddDiscussionLike(String nodeId, String username);

  Future<bool> userRemoveDiscussionLike(String nodeId, String username);

  Future<bool> userAddPollLike(String nodeId, String username);

  Future<bool> userRemovePollLike(String nodeId, String username);

  Future<bool> userCreateFriendRelation(
      UserToUserRelationDetails relationDetails);

  Future<bool> userAcceptFriendRelation(
      UserToUserRelationDetails relationDetails);

  Future<bool> userRemoveFriendRelation(
      UserToUserRelationDetails relationDetails);

  Future<bool> userAddCommentLike(String commentId, String username);

  Future<bool> userRemoveCommentLike(String commentId, String username);

  Future<bool> getUserByUsername(String username, String currentUser);

  Future<bool> getPostById(String postId, String username);

  Future<bool> getDiscussionById(String discussionId, String username);

  Future<bool> getPollById(String pollId, String username);

  Future<bool> getCommentById(String commentId, String username);
}

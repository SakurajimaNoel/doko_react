import 'package:doko_react/core/validation/input.dart';

// class UserProfileNodesInput extends Input {
//   UserProfileNodesInput({
//     required this.username,
//     required this.currentUsername,
//   });
//
//   final String username;
//   final String currentUsername;
//
//   @override
//   String invalidateReason() {
//     return "";
//   }
//
//   @override
//   bool validate() {
//     return true;
//   }
// }

class EditProfileInput extends Input {
  EditProfileInput({
    required this.username,
    required this.userId,
    required this.name,
    required this.bio,
    required this.currentProfile,
    required this.newProfile,
  });

  final String username;
  final String userId;
  final String name;
  final String bio;
  final String currentProfile;
  final String? newProfile;

  @override
  String invalidateReason() {
    return validate() ? "" : "Invalid name";
  }

  @override
  bool validate() {
    if (name.isEmpty) return false;
    return true;
  }
}

class UserProfileNodesInput {
  const UserProfileNodesInput({
    required this.username,
    this.cursor = "",
    required this.currentUsername,
  });

  final String username;
  final String currentUsername;
  final String cursor;

  @override
  String toString() {
    return "Username: $username\n Current user: $currentUsername \n Cursor: $cursor";
  }
}

class UserSearchInput {
  const UserSearchInput({
    required this.username,
    required this.query,
  });

  final String query;
  final String username;
}

class UserFriendsSearchInput {
  const UserFriendsSearchInput({
    required this.username,
    required this.query,
    required this.currentUsername,
  });

  final String query;
  final String username;
  final String currentUsername;
}

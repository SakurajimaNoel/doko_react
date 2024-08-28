class UserModel {
  final String name;
  final String username;
  final String profilePicture;

  const UserModel({
    required this.name,
    required this.username,
    required this.profilePicture,
  });

  static UserModel createModel({required Map map}) {
    return UserModel(
      name: map["name"],
      username: map["username"],
      profilePicture: map["profilePicture"],
    );
  }
}

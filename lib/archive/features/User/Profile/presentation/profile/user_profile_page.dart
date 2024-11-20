import 'package:doko_react/archive/features/User/Profile/widgets/profile/profile_widget.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String username;

  const UserProfilePage({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileWidget(
      username: username,
    );
  }
}

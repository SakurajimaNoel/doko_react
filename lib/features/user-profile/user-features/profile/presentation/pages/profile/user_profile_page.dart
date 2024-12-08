import 'package:doko_react/features/user-profile/user-features/profile/presentation/widgets/profile/profile_widget.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  Widget build(BuildContext context) {
    return ProfileWidget(
      username: username,
    );
  }
}

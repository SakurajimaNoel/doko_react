import 'package:doko_react/features/User/widgets/profile_widget.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileWidget(
      userId: userId,
    );
  }
}

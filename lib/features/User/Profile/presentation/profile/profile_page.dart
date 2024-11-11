import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/features/User/Profile/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var username = context.select((UserProvider user) => user.username);

    return ProfileWidget(
      username: username,
    );
  }
}

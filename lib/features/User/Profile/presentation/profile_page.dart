import 'package:doko_react/core/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/profile_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var userId = context.select((UserProvider user) => user.id);

    return ProfileWidget(
      userId: userId,
      self: true,
    );
  }
}

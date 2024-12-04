import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/features/user-profile/user-features/profile/presentation/widgets/profile/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;

    return ProfileWidget(
      username: username,
    );
  }
}

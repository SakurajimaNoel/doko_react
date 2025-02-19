import 'package:flutter/material.dart';

class UserPollsListPage extends StatefulWidget {
  const UserPollsListPage({
    super.key,
    required this.username,
  });

  final String username;
  @override
  State<UserPollsListPage> createState() => _UserPollsListPageState();
}

class _UserPollsListPageState extends State<UserPollsListPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

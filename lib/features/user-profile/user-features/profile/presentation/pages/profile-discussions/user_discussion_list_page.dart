import 'package:flutter/material.dart';

class UserDiscussionListPage extends StatefulWidget {
  const UserDiscussionListPage({
    super.key,
    required this.username,
  });

  final String username;
  @override
  State<UserDiscussionListPage> createState() => _UserDiscussionListPageState();
}

class _UserDiscussionListPageState extends State<UserDiscussionListPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

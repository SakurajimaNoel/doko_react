import 'package:flutter/material.dart';

class UserPostsListPage extends StatefulWidget {
  const UserPostsListPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<UserPostsListPage> createState() => _UserPostsListPageState();
}

class _UserPostsListPageState extends State<UserPostsListPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

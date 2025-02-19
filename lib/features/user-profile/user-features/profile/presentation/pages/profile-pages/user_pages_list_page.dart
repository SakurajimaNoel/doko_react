import 'package:flutter/material.dart';

class UserPagesListPage extends StatefulWidget {
  const UserPagesListPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<UserPagesListPage> createState() => _UserPagesListPageState();
}

class _UserPagesListPageState extends State<UserPagesListPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

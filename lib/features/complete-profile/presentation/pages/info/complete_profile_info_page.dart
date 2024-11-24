import 'package:flutter/material.dart';

class CompleteProfileInfoPage extends StatefulWidget {
  const CompleteProfileInfoPage({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<CompleteProfileInfoPage> createState() =>
      _CompleteProfileInfoPageState();
}

class _CompleteProfileInfoPageState extends State<CompleteProfileInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.username),
      ),
    );
  }
}

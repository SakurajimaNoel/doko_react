import 'package:doko_react/features/authentication/presentation/widgets/heading.dart';
import 'package:flutter/material.dart';

class ConfirmMfaPage extends StatefulWidget {
  const ConfirmMfaPage({super.key});

  @override
  State<ConfirmMfaPage> createState() => _ConfirmMfaPageState();
}

class _ConfirmMfaPageState extends State<ConfirmMfaPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Heading("Code")),
    );
  }
}

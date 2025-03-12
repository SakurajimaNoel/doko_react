import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/heading/heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doki"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(Constants.padding),
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: Constants.gap,
                children: [
                  Center(
                    child: Heading(
                      Constants.errorMessage,
                      size: Constants.heading4,
                      color: currTheme.error,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        context.read<UserBloc>().add(UserInitEvent());
                      },
                      child: const Text("Go to login page."))
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

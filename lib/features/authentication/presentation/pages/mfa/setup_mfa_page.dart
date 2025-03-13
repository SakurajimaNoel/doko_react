import 'package:doko_react/core/config/router/router_constants.dart';
import 'package:doko_react/core/constants/constants.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/core/widgets/constrained-box/compact_box.dart';
import 'package:doko_react/core/widgets/loading/loading_widget.dart';
import 'package:doko_react/core/widgets/text/styled_text.dart';
import 'package:doko_react/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SetupMfaPage extends StatefulWidget {
  const SetupMfaPage({super.key});

  @override
  State<SetupMfaPage> createState() => _SetupMfaPageState();
}

class _SetupMfaPageState extends State<SetupMfaPage> {
  @override
  Widget build(BuildContext context) {
    final username =
        (context.read<UserBloc>().state as UserCompleteState).username;
    final currTheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MFA setup"),
      ),
      body: CompactBox(
        child: Padding(
          padding: const EdgeInsets.all(Constants.padding),
          child: BlocProvider(
            create: (context) => serviceLocator<AuthenticationBloc>()
              ..add(SetupMFAEvent(
                username: username,
              )),
            child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
              buildWhen: (previousState, state) {
                return previousState != state;
              },
              builder: (context, state) {
                if (state is AuthenticationInitial) {
                  return const SizedBox.shrink();
                }

                if (state is AuthenticationLoading) {
                  return const Center(
                    child: LoadingWidget(),
                  );
                }

                if (state is AuthenticationError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StyledText.error(state.message),
                      const SizedBox(
                        height: Constants.gap,
                      ),
                      OutlinedButton(
                        onPressed: () {
                          context.read<AuthenticationBloc>().add(SetupMFAEvent(
                                username: username,
                              ));
                        },
                        child: const Text("Try again."),
                      )
                    ],
                  );
                }

                final setupDetails =
                    (state as AuthenticationMFASetupSuccess).setupData;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        "To enable extra security, scan the QR code with your authenticator app"),
                    const SizedBox(
                      height: Constants.gap,
                    ),
                    Center(
                      child: QrImageView(
                        data: setupDetails.setupUri.toString(),
                        version: QrVersions.auto,
                        size: 225.0,
                        backgroundColor: currTheme.surface,
                        eyeStyle: QrEyeStyle(
                          color: currTheme.onSurface,
                          eyeShape: QrEyeShape.square,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          color: currTheme.onSurface,
                          dataModuleShape: QrDataModuleShape.square,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: Constants.gap * 1.5,
                    ),
                    RichText(
                      text: TextSpan(
                        text: "or manually enter the secret key ",
                        style: TextStyle(
                          color: currTheme.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: setupDetails.sharedSecret,
                            style: TextStyle(
                              color: currTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(
                            text:
                                " into the authenticator app to set up multi-factor authentication for your account.",
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: const ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.zero),
                      ),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: setupDetails.sharedSecret));
                      },
                      child: const Text("Copy secret code"),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        context.pushNamed(RouterConstants.verifyMfa);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          Constants.buttonWidth,
                          Constants.buttonHeight,
                        ),
                      ),
                      child: const Text("Continue"),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

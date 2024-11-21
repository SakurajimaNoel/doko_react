import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:doko_react/archive/core/widgets/error/error_text.dart';
import 'package:doko_react/core/config/router/app_router_config.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'aws/amplifyconfiguration.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await _configureAmplify();
    await initHiveForFlutter();
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getApplicationDocumentsDirectory(),
    );

    runApp(
      MultiBlocProvider(
        providers: [
          // global user bloc
          BlocProvider(
            create: (BuildContext context) => UserBloc()..add(UserInitEvent()),
          ),
          // global theme bloc
          // BlocProvider(
          //   create: (BuildContext context) => ThemeBloc(),
          // ),
        ],
        child: const Doki(),
      ),
    );
  } on AmplifyException catch (e) {
    runApp(
      MaterialApp(
        home: Center(
          child: ErrorText("Error configuring Amplify: ${e.message}"),
        ),
      ),
    );
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.addPlugin(AmplifyStorageS3());
    await Amplify.configure(amplifyconfig);

    safePrint("Successfully configured amplify");
  } on Exception catch (e) {
    safePrint("Error configuring Amplify: $e");
  }
}

class Doki extends StatefulWidget {
  const Doki({super.key});

  @override
  State<Doki> createState() => _DokiState();
}

class _DokiState extends State<Doki> {
  @override
  void initState() {
    super.initState();

    // listen for auth events fired by amplify
    Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          context.read<UserBloc>().add(UserAuthenticatedEvent());
          break;
        case AuthHubEventType.signedOut:
          context.read<UserBloc>().add(UserSignOutEvent());
          break;
        case AuthHubEventType.sessionExpired:
          context.read<UserBloc>().add(UserSignOutEvent());
          break;
        case AuthHubEventType.userDeleted:
          context.read<UserBloc>().add(UserSignOutEvent());
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoRouter router = AppRouterConfig.router;

    return BlocListener<UserBloc, UserState>(
      listenWhen: (previousState, state) {
        return previousState != state;
      },
      listener: (context, state) {
        router.refresh();
      },
      child: MaterialApp.router(
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        title: 'Doki',
      ),
    );
  }
}

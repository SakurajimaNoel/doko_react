import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/archive/core/widgets/error/error_text.dart';
import 'package:doko_react/core/config/router/app_router_config.dart';
import 'package:doko_react/core/config/theme/theme_data.dart';
import 'package:doko_react/core/global/bloc/user/user_bloc.dart';
import 'package:doko_react/init_dependency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await initDependency();

    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }

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
        themeMode: ThemeMode.light,
        darkTheme: GlobalThemeData.darkCustomThemeData(Colors.deepPurple),
        theme: GlobalThemeData.lightCustomThemeData(Colors.deepPurple),
      ),
    );
  }
}

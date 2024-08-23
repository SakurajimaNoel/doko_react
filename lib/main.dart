import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/aws/amplifyconfiguration.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/provider/theme_provider.dart';
import 'package:doko_react/core/router/router_config.dart';
import 'package:doko_react/core/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance();
    await _configureAmplify();

    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthenticationProvider(),
      )
    ], child: const MyApp()));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured');
  } on Exception catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthenticationProvider _authProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = Provider.of<AuthenticationProvider>(context, listen: false);

    fetchAuthSession();
    Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          _changeAuthStatus(AuthenticationStatus.signedIn);
          break;
        case AuthHubEventType.signedOut:
          _changeAuthStatus(AuthenticationStatus.signedOut);
          break;
        case AuthHubEventType.sessionExpired:
          _changeAuthStatus(AuthenticationStatus.signedOut);
          break;
        case AuthHubEventType.userDeleted:
          _changeAuthStatus(AuthenticationStatus.signedOut);
          break;
      }
    });
  }

  Future<void> fetchAuthSession() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      AuthenticationStatus status = result.isSignedIn
          ? AuthenticationStatus.signedIn
          : AuthenticationStatus.signedOut;

      _changeAuthStatus(status);
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');

      _changeAuthStatus(AuthenticationStatus.signedOut);
    }
  }

  void _changeAuthStatus(AuthenticationStatus status) {
    _authProvider.setAuthStatus(status);

    // if (status == AuthenticationStatus.signedIn) {
    //   GoRouter.of(context).goNamed(RouterConstants.userFeed);
    // } else if (status == AuthenticationStatus.signedOut) {
    //   GoRouter.of(context).goNamed(RouterConstants.login);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    ThemeMode themeMode;
    switch (theme.themeMode) {
      case UserTheme.light:
        themeMode = ThemeMode.light;
        break;
      case UserTheme.dark:
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return Consumer<AuthenticationProvider>(
      builder: (context, authProvider, child) {
        GoRouter router;
        if (authProvider.authStatus == AuthenticationStatus.loading) {
          router = loadingConfig;
        } else if (authProvider.authStatus == AuthenticationStatus.signedIn) {
          router = homeRouterConfig;
        } else {
          router = authRouterConfig;
        }

        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          title: 'Dokii',
          themeMode: themeMode,
          theme: GlobalThemeData.lightThemeData,
          darkTheme: GlobalThemeData.darkThemeData,
        );
      },
    );
  }
}

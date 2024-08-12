import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:doko_react/aws/amplifyconfiguration.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/provider/theme_provider.dart';
import 'package:doko_react/core/theme/theme_data.dart';
import 'package:doko_react/features/User/Feed/presentation/user_feed.dart';
import 'package:doko_react/features/authentication/presentation/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/widgets/loader.dart';

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
          _authProvider.setAuthStatus(AuthenticationStatus.signedIn);
          break;
        case AuthHubEventType.signedOut:
          _authProvider.setAuthStatus(AuthenticationStatus.signedOut);
          break;
        case AuthHubEventType.sessionExpired:
          _authProvider.setAuthStatus(AuthenticationStatus.signedOut);
          // snack bar with message user needs to login again
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(const SnackBar(
                content: Text(
              "Your session has expired. Please log in again.",
              textAlign: TextAlign.center,
            )));
          break;
        case AuthHubEventType.userDeleted:
          _authProvider.setAuthStatus(AuthenticationStatus.signedOut);
          // snack bar with message user is deleted
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(const SnackBar(
                content: Text(
              "The user account you are trying to access no longer exists.",
              textAlign: TextAlign.center,
            )));
          break;
      }
    });
  }

  Future<void> fetchAuthSession() async {
    try {
      final result = await Amplify.Auth.fetchAuthSession();
      safePrint('User is signed in: ${result.isSignedIn}');

      AuthenticationStatus status = result.isSignedIn
          ? AuthenticationStatus.signedIn
          : AuthenticationStatus.signedOut;

      _authProvider.setAuthStatus(status);
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');

      _authProvider.setAuthStatus(AuthenticationStatus.signedOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthenticationProvider>(context);

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

    Widget home;
    switch (authProvider.authStatus) {
      case AuthenticationStatus.loading:
        home = const Loader();
        break;
      case AuthenticationStatus.signedIn:
        home = const UserFeedPage();
        break;
      default:
        home = const LoginPage();
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dokii',
        themeMode: themeMode,
        theme: GlobalThemeData.lightThemeData,
        darkTheme: GlobalThemeData.darkThemeData,
        home: home);
  }
}

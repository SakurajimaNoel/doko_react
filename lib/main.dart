import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:doko_react/aws/amplifyconfiguration.dart';
import 'package:doko_react/core/configs/router/app_router_config.dart';
import 'package:doko_react/core/data/auth.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/provider/theme_provider.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/configs/graphql/graphql_config.dart';
import 'core/helpers/enum.dart';
import 'features/User/data/services/user_graphql_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedPreferences.getInstance();
    await _configureAmplify();
    await initHiveForFlutter();

    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => AuthenticationProvider(),
      ),
      ChangeNotifierProvider(
        create: (context) => UserProvider(),
      ),
    ], child: const MyApp()));
  } on AmplifyException catch (e) {
    runApp(Text("Error configuring Amplify: ${e.message}"));
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.addPlugin(AmplifyStorageS3());
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
  late final UserProvider _userProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<AuthenticationProvider>();
    _userProvider = context.read<UserProvider>();

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
    } catch (e) {
      safePrint(e.toString());
      _changeAuthStatus(AuthenticationStatus.error);
    }
  }

  Future<void> _fetchMfaStatus() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final currentPreference = await cognitoPlugin.fetchMfaPreference();

    AuthenticationMFAStatus mfaStatus = currentPreference.preferred != null
        ? AuthenticationMFAStatus.setUpped
        : AuthenticationMFAStatus.notSetUpped;
    _authProvider.setMFAStatus(mfaStatus);
  }

  Future<void> _getCompleteUser() async {
    var result = await AuthenticationActions.getUserId();
    if (result.status == AuthStatus.error) {
      _userProvider.apiError();
      return;
    }

    String userId = result.message!;
    final UserGraphqlService graphqlService = UserGraphqlService();
    var userDetails = await graphqlService.getUser(userId);

    if (userDetails.status == ResponseStatus.error) {
      _userProvider.apiError();
      return;
    }

    var user = userDetails.user;
    if (user == null) {
      _userProvider.incompleteUser();
      return;
    }

    _userProvider.addUser(
      user: user,
    );
  }

  Future<void> _changeAuthStatus(AuthenticationStatus status) async {
    if (status == AuthenticationStatus.signedIn) {
      _fetchMfaStatus();
      _getCompleteUser();
      _authProvider.setAuthStatus(status);
    } else {
      await GraphqlConfig.clearCache();
      _authProvider.setAuthStatus(status);
      _authProvider.setMFAStatus(AuthenticationMFAStatus.undefined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus =
        context.select((AuthenticationProvider auth) => auth.authStatus);
    final userStatus = context.select((UserProvider user) => user.status);

    GoRouter router;

    if (authStatus == AuthenticationStatus.loading) {
      router = AppRouterConfig.loadingConfig();
    } else if (authStatus == AuthenticationStatus.signedOut) {
      router = AppRouterConfig.authConfig();
    } else if (authStatus == AuthenticationStatus.signedIn) {
      switch (userStatus) {
        case ProfileStatus.loading:
          router = AppRouterConfig.loadingConfig();
          break;
        case ProfileStatus.incomplete:
          router = AppRouterConfig.completeProfile();
          break;
        case ProfileStatus.complete:
          router = AppRouterConfig.homeConfig();
          break;
        default:
          router = AppRouterConfig.errorConfig();
          break;
      }
    } else {
      router = AppRouterConfig.errorConfig();
    }

    return Consumer<ThemeProvider>(
      builder: (context, theme, child) {
        ThemeMode themeMode;
        Color accent = theme.accent;
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

        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          title: 'Dokii',
          themeMode: themeMode,
          theme: GlobalThemeData.lightCustomThemeData(accent),
          darkTheme: GlobalThemeData.darkCustomThemeData(accent),
        );
      },
    );
  }
}

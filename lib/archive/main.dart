import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:doko_react/archive/core/configs/graphql/graphql_config.dart';
import 'package:doko_react/archive/core/configs/router/app_router_config.dart';
import 'package:doko_react/archive/core/data/auth.dart';
import 'package:doko_react/archive/core/helpers/enum.dart';
import 'package:doko_react/archive/core/provider/authentication_provider.dart';
import 'package:doko_react/archive/core/provider/theme_provider.dart';
import 'package:doko_react/archive/core/provider/user_preferences_provider.dart';
import 'package:doko_react/archive/core/provider/user_provider.dart';
import 'package:doko_react/archive/core/theme/theme_data.dart';
import 'package:doko_react/archive/core/widgets/error/error.dart';
import 'package:doko_react/archive/features/User/data/services/user_graphql_service.dart';
import 'package:doko_react/aws/amplifyconfiguration.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    MediaKit.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _configureAmplify();
    await initHiveForFlutter();

    final ImagePickerPlatform imagePickerImplementation =
        ImagePickerPlatform.instance;
    if (imagePickerImplementation is ImagePickerAndroid) {
      imagePickerImplementation.useAndroidPhotoPicker = true;
    }

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => ThemeProvider(prefs),
          ),
          ChangeNotifierProvider(
            create: (context) => AuthenticationProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserProvider(),
          ),
          ChangeNotifierProvider(
            create: (context) => UserPreferencesProvider(prefs),
          ),
        ],
        child: GraphQLProvider(
          client: GraphqlConfig.client,
          child: const MyApp(),
        ),
      ),
    );
  } on AmplifyException catch (e) {
    runApp(
      Text("Error configuring Amplify: ${e.message}"),
    );
  }
}

Future<void> _configureAmplify() async {
  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.addPlugin(AmplifyStorageS3());
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured amplify');
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
  late final AuthenticationProvider authProvider;
  late final UserProvider userProvider;
  final AuthenticationActions auth = AuthenticationActions(auth: Amplify.Auth);

  @override
  void initState() {
    super.initState();
    authProvider = context.read<AuthenticationProvider>();
    userProvider = context.read<UserProvider>();

    // fetch user auth status on application startup
    fetchAuthSession();

    // listen for auth events fired by amplify
    Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) {
      switch (event.type) {
        case AuthHubEventType.signedIn:
          changeAuthStatus(AuthenticationStatus.signedIn);
          break;
        case AuthHubEventType.signedOut:
          changeAuthStatus(AuthenticationStatus.signedOut);
          break;
        case AuthHubEventType.sessionExpired:
          changeAuthStatus(AuthenticationStatus.signedOut);
          break;
        case AuthHubEventType.userDeleted:
          changeAuthStatus(AuthenticationStatus.signedOut);
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

      changeAuthStatus(status);
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');

      changeAuthStatus(AuthenticationStatus.signedOut);
    } catch (e) {
      safePrint(e.toString());
      changeAuthStatus(AuthenticationStatus.error);
    }
  }

  Future<void> fetchMfaStatus() async {
    final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
    final currentPreference = await cognitoPlugin.fetchMfaPreference();

    AuthenticationMFAStatus mfaStatus = currentPreference.preferred != null
        ? AuthenticationMFAStatus.setUpped
        : AuthenticationMFAStatus.notSetUpped;
    authProvider.setMFAStatus(mfaStatus);
  }

  Future<void> getCompletedUser() async {
    var result = await auth.getUserId();
    if (result.status == AuthStatus.error) {
      userProvider.apiError();
      return;
    }

    String userId = result.message!;
    final UserGraphqlService graphqlService = UserGraphqlService(
      client: GraphqlConfig.getGraphQLClient(),
    );
    var userDetails = await graphqlService.getUser(userId);

    if (userDetails.status == ResponseStatus.error) {
      userProvider.apiError();
      return;
    }

    var user = userDetails.user;
    if (user == null) {
      userProvider.incompleteUser();
      return;
    }

    userProvider.addUser(
      user: user,
    );
  }

  Future<void> changeAuthStatus(AuthenticationStatus status) async {
    if (status == AuthenticationStatus.signedIn) {
      fetchMfaStatus();

      /*
        when signed in get user details based on cognito user id
        if no node is present than user profile is incomplete
      */
      getCompletedUser();
      authProvider.setAuthStatus(status);
    } else {
      authProvider.setAuthStatus(status);
      authProvider.setMFAStatus(AuthenticationMFAStatus.undefined);
      userProvider.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus =
        context.select((AuthenticationProvider auth) => auth.authStatus);
    final userStatus = context.select((UserProvider user) => user.status);

    bool authLoading = authStatus == AuthenticationStatus.loading;
    bool error = authStatus == AuthenticationStatus.error ||
        userStatus == ProfileStatus.error;
    bool userProfileLoading = authStatus != AuthenticationStatus.signedOut &&
        userStatus == ProfileStatus.loading;

    GoRouter router = AppRouterConfig.router;

    // when auth status or user status change refresh the router to trigger redirect
    router.refresh();

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

        if (authLoading || userProfileLoading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Dokii",
            themeMode: themeMode,
            theme: GlobalThemeData.lightCustomThemeData(accent),
            darkTheme: GlobalThemeData.darkCustomThemeData(accent),
            home: const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (error) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "Dokii",
            themeMode: themeMode,
            theme: GlobalThemeData.lightCustomThemeData(accent),
            darkTheme: GlobalThemeData.darkCustomThemeData(accent),
            home: Error(),
          );
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

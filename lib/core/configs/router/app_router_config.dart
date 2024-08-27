import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/widgets/loader.dart';
import 'package:doko_react/features/User/Feed/presentation/user_feed_page.dart';
import 'package:doko_react/features/User/Nearby/presentation/nearby_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile_page.dart';
import 'package:doko_react/features/User/user_layout.dart';
import 'package:doko_react/features/application/settings/presentation/change_password_page.dart';
import 'package:doko_react/features/application/settings/presentation/mfa_setup_page.dart';
import 'package:doko_react/features/application/settings/presentation/settings_page.dart';
import 'package:doko_react/features/application/settings/presentation/verify_mfa_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/confirm_mfa_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/login_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/password_reset_confirm_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/password_reset_page.dart';
import 'package:doko_react/features/authentication/presentation/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouterConfig {
  static GoRouter loadingConfig() {
    return GoRouter(
      initialLocation: "/",
      routes: [
        GoRoute(
          path: "/",
          name: "loading",
          builder: (context, state) => const Loader(),
        ),
      ],
    );
  }

  static GoRouter authConfig() {
    final authRouterRootNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: authRouterRootNavigatorKey,
      initialLocation: "/login",
      routes: [
        GoRoute(
          name: RouterConstants.login,
          path: "/login",
          builder: (context, state) {
            return const LoginPage();
          },
          routes: [
            GoRoute(
              name: RouterConstants.mfa,
              path: "mfa",
              builder: (context, state) {
                return const ConfirmMfaPage();
              },
            ),
            GoRoute(
              name: RouterConstants.signUp,
              path: "signUp",
              builder: (context, state) {
                return const SignupPage();
              },
            ),
            GoRoute(
              name: RouterConstants.passwordReset,
              path: "password-reset",
              builder: (context, state) {
                return const PasswordResetPage();
              },
              routes: [
                GoRoute(
                  name: RouterConstants.passwordResetConfirm,
                  path: "password-reset-confirm/:email",
                  builder: (context, state) {
                    final emailValue = state.pathParameters["email"]!;
                    return PasswordResetConfirmPage(email: emailValue);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static GoRouter homeConfig() {
    final homeRouterRootNavigatorKey = GlobalKey<NavigatorState>();
    final homeRouterSectionNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: homeRouterRootNavigatorKey,
      initialLocation: "/user-feed",
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return UserLayout(navigationShell);
          },
          branches: [
            StatefulShellBranch(
              navigatorKey: homeRouterSectionNavigatorKey,
              routes: [
                GoRoute(
                  name: RouterConstants.userFeed,
                  path: "/user-feed",
                  builder: (context, state) => const UserFeedPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: RouterConstants.nearby,
                  path: "/nearby",
                  builder: (context, state) => const NearbyPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  name: RouterConstants.profile,
                  path: "/profile",
                  builder: (context, state) => const ProfilePage(),
                  routes: [
                    GoRoute(
                      parentNavigatorKey: homeRouterRootNavigatorKey,
                      name: RouterConstants.settings,
                      path: "settings",
                      builder: (context, state) => const SettingsPage(),
                      routes: [
                        GoRoute(
                          parentNavigatorKey: homeRouterRootNavigatorKey,
                          name: RouterConstants.mfaSetup,
                          path: "mfa-setup",
                          builder: (context, state) => const MfaSetupPage(),
                          routes: [
                            GoRoute(
                              parentNavigatorKey: homeRouterRootNavigatorKey,
                              name: RouterConstants.verifyMfa,
                              path: "verify-mfa",
                              builder: (context, state) =>
                                  const VerifyMfaPage(),
                            ),
                          ],
                        ),
                        GoRoute(
                          parentNavigatorKey: homeRouterRootNavigatorKey,
                          name: RouterConstants.changePassword,
                          path: "change-password",
                          builder: (context, state) =>
                              const ChangePasswordPage(),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/user_preferences_provider.dart';
import 'package:doko_react/core/widgets/error/error.dart';
import 'package:doko_react/core/widgets/loader/loader.dart';
import 'package:doko_react/features/User/CompleteProfile/Presentation/complete_profile_info_page.dart';
import 'package:doko_react/features/User/CompleteProfile/Presentation/complete_profile_picture_page.dart';
import 'package:doko_react/features/User/CompleteProfile/Presentation/complete_profile_username_page.dart';
import 'package:doko_react/features/User/Feed/presentation/search/user_search_page.dart';
import 'package:doko_react/features/User/Feed/presentation/user_feed_page.dart';
import 'package:doko_react/features/User/Nearby/presentation/nearby_page.dart';
import 'package:doko_react/features/User/Profile/presentation/friends/friends_page.dart';
import 'package:doko_react/features/User/Profile/presentation/friends/pending_request_page.dart';
import 'package:doko_react/features/User/Profile/presentation/post/create_post_page.dart';
import 'package:doko_react/features/User/Profile/presentation/post/create_post_publish_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile/edit_profile_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile/profile_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile/user_profile_page.dart';
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
import 'package:provider/provider.dart';

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

  static GoRouter errorConfig() {
    return GoRouter(
      initialLocation: "/error",
      routes: [
        GoRoute(
          path: "/error",
          name: "error",
          builder: (context, state) => Error(),
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
                    return PasswordResetConfirmPage(
                      email: emailValue,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static GoRouter completeProfile() {
    final rootNavigatorKey = GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: "/complete-profile-username",
      routes: [
        GoRoute(
          name: RouterConstants.completeProfileUsername,
          path: "/complete-profile-username",
          builder: (context, state) => const CompleteProfileUsernamePage(),
          routes: [
            GoRoute(
              name: RouterConstants.completeProfileInfo,
              path: "complete-profile-info/:username",
              builder: (context, state) {
                final usernameValue = state.pathParameters["username"]!;
                return CompleteProfileInfoPage(
                  username: usernameValue,
                );
              },
              routes: [
                GoRoute(
                  name: RouterConstants.completeProfilePicture,
                  path: "complete-profile-picture/:name/:dob",
                  builder: (context, state) {
                    final usernameValue = state.pathParameters["username"]!;
                    final nameValue = state.pathParameters["name"]!;
                    final dobValue = state.pathParameters["dob"]!;

                    return CompleteProfilePicturePage(
                      username: usernameValue,
                      name: nameValue,
                      dob: dobValue,
                    );
                  },
                )
              ],
            )
          ],
        )
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
                  routes: [
                    GoRoute(
                      name: RouterConstants.userSearch,
                      path: "search",
                      builder: (context, state) => const UserSearchPage(),
                    )
                  ],
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
                  builder: (context, state) {
                    final needsRefresh = context.select(
                        (UserPreferencesProvider preferences) =>
                            preferences.profileRefresh);

                    return ProfilePage(
                      key: ObjectKey(needsRefresh),
                    );
                  },
                  routes: [
                    GoRoute(
                      name: RouterConstants.pendingRequests,
                      path: "pending-requests",
                      builder: (context, state) => const PendingRequestPage(),
                    ),
                    GoRoute(
                      parentNavigatorKey: homeRouterRootNavigatorKey,
                      name: RouterConstants.createPost,
                      path: "create-post",
                      builder: (context, state) => const CreatePostPage(),
                      routes: [
                        GoRoute(
                          parentNavigatorKey: homeRouterRootNavigatorKey,
                          name: RouterConstants.postPublish,
                          path: "publish",
                          builder: (context, state) {
                            final Map<String, dynamic> data =
                                state.extra as Map<String, dynamic>;
                            final List<PostContent> postContent =
                                data["postContent"];

                            return CreatePostPublishPage(
                              postContent: postContent,
                            );
                          },
                        ),
                      ],
                    ),
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
                    GoRoute(
                      parentNavigatorKey: homeRouterRootNavigatorKey,
                      name: RouterConstants.editProfile,
                      path: "edit-profile",
                      builder: (context, state) {
                        final Map<String, dynamic> data =
                            state.extra as Map<String, dynamic>;
                        final String bio = data["bio"];
                        return EditProfilePage(
                          bio: bio,
                        );
                      },
                    ),
                    GoRoute(
                        name: RouterConstants.userProfile,
                        path: ":userId",
                        builder: (context, state) {
                          String userId = state.pathParameters["userId"]!;
                          return UserProfilePage(userId: userId);
                        },
                        routes: [
                          GoRoute(
                            name: RouterConstants.profileFriends,
                            path: "friends",
                            builder: (context, state) {
                              var extra = state.extra ??
                                  {
                                    "name": "user",
                                  };

                              final Map<String, dynamic> data =
                                  extra as Map<String, dynamic>;

                              String name = data["name"];
                              String userId = state.pathParameters["userId"]!;
                              return FriendsPage(
                                userId: userId,
                                name: name,
                              );
                            },
                          ),
                        ]),
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

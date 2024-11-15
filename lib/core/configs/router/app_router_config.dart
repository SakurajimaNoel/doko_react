import 'package:doko_react/core/configs/router/router_constants.dart';
import 'package:doko_react/core/helpers/media_type.dart';
import 'package:doko_react/core/provider/authentication_provider.dart';
import 'package:doko_react/core/provider/user_preferences_provider.dart';
import 'package:doko_react/core/provider/user_provider.dart';
import 'package:doko_react/core/widgets/error/error_unknown_route.dart';
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
import 'package:doko_react/features/User/Profile/presentation/post/post_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile/edit_profile_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile/profile_page.dart';
import 'package:doko_react/features/User/Profile/presentation/profile/user_profile_page.dart';
import 'package:doko_react/features/User/data/model/post_model.dart';
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
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _sectionNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: "/",
    redirect: (BuildContext context, GoRouterState state) {
      var userProvider = context.read<UserProvider>();
      var authProvider = context.read<AuthenticationProvider>();

      String authRoute = "/auth/login";
      String home = "/";
      String completeProfile = "/complete-profile-username";

      bool isUserAuthenticated =
          authProvider.authStatus == AuthenticationStatus.signedIn;
      bool isUserProfileComplete =
          userProvider.status == ProfileStatus.complete;

      bool onAuthPages = state.uri.toString().startsWith("/auth");
      bool onProfileCompletePages =
          state.uri.toString().startsWith("/complete");

      // user is logged in
      if (isUserAuthenticated) {
        // user is still on auth pages
        if (onAuthPages) {
          return isUserProfileComplete ? home : completeProfile;
        }

        // profile is complete
        if (isUserProfileComplete) {
          return onProfileCompletePages ? home : null;
        }

        // user profile is incomplete and not on complete profile routes
        return onProfileCompletePages ? null : completeProfile;
      }

      // user not logged in
      return onAuthPages ? null : authRoute;
    },
    errorBuilder: (BuildContext context, GoRouterState state) {
      return const ErrorUnknownRoute();
    },
    routes: [
      // auth routes
      GoRoute(
        name: RouterConstants.login,
        path: "/auth/login",
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
        ],
      ),
      GoRoute(
        name: RouterConstants.signUp,
        path: "/auth/sign-up",
        builder: (context, state) {
          return const SignupPage();
        },
      ),
      GoRoute(
        name: RouterConstants.passwordReset,
        path: "/auth/password-reset",
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
      // incomplete-profile routes
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
      ),
      // complete profile routes
      StatefulShellRoute.indexedStack(
        // parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return UserLayout(navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _sectionNavigatorKey,
            routes: [
              GoRoute(
                name: RouterConstants.userFeed,
                path: "/",
                builder: (context, state) => const UserFeedPage(),
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
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
                  // todo: handle this in a better way
                  final needsRefresh = context.select(
                      (UserPreferencesProvider preferences) =>
                          preferences.profileRefresh);

                  return ProfilePage(
                    key: ObjectKey(needsRefresh),
                  );
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.userPost,
                    path: "post/:postId",
                    builder: (context, state) {
                      Map<String, dynamic>? data;
                      if (state.extra != null) {
                        data = state.extra as Map<String, dynamic>;
                      }

                      final PostModel? post = data?["post"];
                      String postId = state.pathParameters["postId"]!;

                      return PostPage(
                        postId: postId,
                        post: post,
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.pendingRequests,
                    path: "pending-requests",
                    builder: (context, state) => const PendingRequestPage(),
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.createPost,
                    path: "create-post",
                    builder: (context, state) => const CreatePostPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.postPublish,
                        path: "publish",
                        builder: (context, state) {
                          final Map<String, dynamic> data =
                              state.extra as Map<String, dynamic>;
                          final List<PostContent> postContent =
                              data["postContent"];
                          final String postId = data["postId"];

                          return CreatePostPublishPage(
                            postContent: postContent,
                            postId: postId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.settings,
                    path: "settings",
                    builder: (context, state) => const SettingsPage(),
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.mfaSetup,
                        path: "mfa-setup",
                        builder: (context, state) => const MfaSetupPage(),
                        routes: [
                          GoRoute(
                            parentNavigatorKey: _rootNavigatorKey,
                            name: RouterConstants.verifyMfa,
                            path: "verify-mfa",
                            builder: (context, state) => const VerifyMfaPage(),
                          ),
                        ],
                      ),
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.changePassword,
                        path: "change-password",
                        builder: (context, state) => const ChangePasswordPage(),
                      ),
                    ],
                  ),
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
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
                    parentNavigatorKey: _rootNavigatorKey,
                    name: RouterConstants.userProfile,
                    path: "user/:username",
                    builder: (context, state) {
                      String username = state.pathParameters["username"]!;
                      return UserProfilePage(username: username);
                    },
                    routes: [
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        name: RouterConstants.profileFriends,
                        path: "friends",
                        builder: (context, state) {
                          String username = state.pathParameters["username"]!;
                          return FriendsPage(
                            username: username,
                          );
                        },
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
